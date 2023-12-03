import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'package:ensemble_llama/llama_ffi.dart';
import 'package:ensemble_llama/src/llama.dart' as pub;
import 'package:ensemble_llama/src/message_control.dart';
import 'package:ensemble_llama/src/message_response.dart';
import 'package:ensemble_llama/src/sampling.dart';

import 'package:ensemble_llama/src/isolate_models.dart';
import 'package:ensemble_llama/src/isolate_param_extensions.dart';
import 'package:ensemble_llama/src/isolate_state.dart';

extension on ResponseMessage {
  void send() => _response.send(this);
}

/// Samples the next token randomly, using the probabilities in [cands].
///
/// This is called last, after any [Sampler] have been called, unless
/// an alternative [TerminalSampler] is supplied. This does not modify any
/// probabilities in [cands].
final class _DefaultLastSampler implements Sampler {
  const _DefaultLastSampler();
  @override
  Token? sample(Context ctx, Candidates cands, TokenBuf _) =>
      Token.fromId(ctx, llama_sample_token(ctx.pointer, cands.pointer));
}

late final SendPort _log;
late final SendPort _response;

final ReceivePort _controlPort = ReceivePort();
final Stream<ControlMessage> _control = _controlPort.cast<ControlMessage>();

void init(({SendPort log, SendPort response}) args) {
  _log = args.log;
  _response = args.response;

  _control.listen(_onControl);
  HandshakeResp(_controlPort.sendPort).send();

  llama_backend_init(false);
  llama_log_set(
    Pointer.fromFunction(_onLlamaLog),
    Pointer.fromAddress(0), // not used
  );
}

void _onLlamaLog(int level, Pointer<Char> text, Pointer<Void> userData) =>
    _log.send(pub.LogMessage(
        level: level, text: text.cast<Utf8>().toDartString().trimRight()));

void _onModelLoadProgress(double progress, Pointer<Void> id) =>
    LoadModelProgressResp(id.address, progress).send();

void _onControl(ControlMessage ctl) {
  switch (ctl) {
    case ExitCtl():
      _exit(ctl);
    case LoadModelCtl():
      _loadModel(ctl);
    case FreeModelCtl():
      _freeModel(ctl);
    case NewContextCtl():
      _newContext(ctl);
    case FreeContextCtl():
      _freeContext(ctl);
    case TokenizeCtl():
      _tokenize(ctl);
    case GenerateCtl():
      _generate(ctl);
  }
}

void _exit(ExitCtl ctl) {
  _controlPort.close();
  llama_backend_free();
  Isolate.exit(_response, ctl.done());
}

void _loadModel(LoadModelCtl ctl) {
  Pointer<Char>? pathStrC;
  try {
    final params = llama_model_default_params()..setSimpleFrom(ctl.params);

    params.progress_callback = Pointer.fromFunction(_onModelLoadProgress);
    // use the pointer value itself to store ctl.id, so we don't need to malloc
    params.progress_callback_user_data = Pointer.fromAddress(ctl.id);

    pathStrC = ctl.path.toNativeUtf8(allocator: calloc).cast<Char>();
    final rawModel = llama_load_model_from_file(pathStrC, params).address;
    if (rawModel == 0) {
      ctl.error(Exception("failed loading model: ${ctl.path}")).send();
      return;
    }

    ctl.done(state.addModel(rawModel)).send();
  } catch (e) {
    ctl.error(e).send();
  } finally {
    if (pathStrC != null) calloc.free(pathStrC);
  }
}

void _freeModel(FreeModelCtl ctl) {
  try {
    final model = state.removeModel(ctl.model);
    final ctxs = state.contextsForModel[ctl.model];
    if (ctxs != null && ctxs.isNotEmpty) {
      throw StateError(
          "${ctxs.length} contexts are still active for this model");
    }

    llama_free_model(model.pointer);
    // nothing to dispose... yet

    ctl.done().send();
  } catch (e) {
    ctl.error(e).send();
  }
}

void _newContext(NewContextCtl ctl) {
  try {
    final params = llama_context_default_params()..setSimpleFrom(ctl.params);
    final model = state.getModel(ctl.model);
    final rawCtx = llama_new_context_with_model(model.pointer, params).address;
    if (rawCtx == 0) throw Exception("failed creating context");

    ctl.done(state.addContext(rawCtx, model, ctl.params)).send();
  } catch (e) {
    ctl.error(e).send();
  }
}

void _freeContext(FreeContextCtl ctl) {
  try {
    final ctx = state.removeContext(ctl.ctx);
    if (!state.models.containsKey(ctx.model.id)) {
      throw StateError(
          "found Context#${ctl.ctx}, but missing Model#{${ctx.model.id}");
    }

    final ctxSet = state.contextsForModel[ctx.model.id];
    if (ctxSet == null || !ctxSet.remove(ctl.ctx)) {
      throw StateError(
          "found Context#{ctl.ctx}, but missing from _contextsForModel");
    }

    llama_free(ctx.pointer);
    ctx.dispose();

    ctl.done().send();
  } catch (e) {
    ctl.error(e).send();
  }
}

void _tokenize(TokenizeCtl ctl) {
  try {
    final ctx = state.getContext(ctl.ctx);
    final numToks = ctx.toks.addFromString(ctx, ctl.text, ctl.addBos);
    ctl.done(ctx.toks.toList(ctx, numToks)).send();
  } catch (e) {
    ctl.error(e).send();
  }
}

void _generate(GenerateCtl ctl) async {
  llama_batch? batch;
  Candidates? candidates;
  TokenBuf? tokens;
  ReceivePort handle = ReceivePort();
  try {
    bool mustCancel = false;
    handle.listen((_) => mustCancel = true);
    ctl.handshake(handle.sendPort).send();

    final ctx = state.getContext(ctl.ctx);
    final contextSize = ctx.params.contextSizeTokens;
    final batchSize = ctx.params.batchSizeTokens;

    candidates = Candidates(llama_n_vocab(ctx.model.pointer));
    tokens = TokenBuf.fromString(ctx, ctl.prompt);

    final promptSize = tokens.length;

    for (final s in ctl.samplers) {
      if (s is NativeMemoryUser) (s as NativeMemoryUser).alloc();
    }

    //
    // Evaluate prompt.
    //
    // To do so, we fill up a llama_batch with tokens, call llama_decode()
    // to load those tokens into the model, and repeat until we run out of
    // prompt tokens.

    batch = llama_batch_init(batchSize, 0, 1);

    var i = 0; // index into context window
    var j = 0; // index into current batch
    while (i + j < promptSize) {
      final promptTokensRemaining = promptSize - i;
      final isLastBatch = promptTokensRemaining <= batchSize;
      final fillCount = isLastBatch ? promptTokensRemaining : batchSize;

      batch.n_tokens = fillCount;
      for (j = 0; j < fillCount; j++) {
        batch.token[j] = tokens[i + j];
        batch.pos[j] = i + j; // is just j sufficient? small numbers anyhow
        batch.n_seq_id[j] = 1;
        batch.seq_id[j][0] = 1;
        batch.logits[j] = isLastBatch ? 1 : 0;
      }

      final status = llama_decode(ctx.pointer, batch);
      if (status != 0) {
        throw Exception("llama_decode failed with $status");
      }

      assert(j <= batchSize);
      if (j == batchSize) {
        i += batchSize;
        j = 0;
      }
    }

    //
    // Generate tokens to fill context
    //

    i += j; // index into the context for all tokens so far

    while (i < contextSize) {
      int logitsIndex;
      if (j != 0) {
        // on first iteration, the batch is almost always partially filled,
        // so we need to use the index of the last token in the batch
        logitsIndex = j - 1;
        j = 0;
      } else {
        // on future iterations, we use only the first slot in the batch
        logitsIndex = 0;
      }

      final logits = llama_get_logits_ith(ctx.pointer, logitsIndex);
      candidates.load(logits);

      // Apply each sampler in turn. If we receive a token back, it should
      // be the last sampler. If there are samplers remaining and we already
      // have a token, it is an error.
      Token? tok;
      final samplerCount = ctl.samplers.length;
      for (var i = 0; i < samplerCount; i++) {
        final samp = ctl.samplers[i];
        tok = samp.sample(ctx, candidates, tokens);

        if (tok != null) {
          if (samplerCount > i + 1) {
            final unused = ctl.samplers.skip(i + 1).toList(growable: false);
            final buf = StringBuffer()..writeAll(unused);
            throw ArgumentError.value(unused,
                "Unexpected token from $samp. Unable to process these additional samplers: $buf");
          }

          break;
        }
      }

      tok ??= _DefaultLastSampler().sample(ctx, candidates, tokens);

      // Yield to this isolate's event loop
      await Future.delayed(Duration.zero);
      if (mustCancel) return;

      tokens.add(tok!.id);
      ctl.token((id: tok.id, text: tok.text)).send();

      // Check if end of stream
      if (tok.id == llama_token_eos(ctx.model.pointer)) {
        break;
      }

      //
      // Decode next token
      //

      batch.n_tokens = 1;

      batch.token[0] = tok.id;
      batch.pos[0] = i++;
      batch.n_seq_id[0] = 1;
      batch.seq_id[0][0] = 1;
      batch.logits[0] = 1; // enable logits for this token

      final status = llama_decode(ctx.pointer, batch);
      if (status != 0) {
        throw Exception("llama_decode failed with $status");
      }
    }

    ctl.done().send();
  } catch (e) {
    // rethrow; // for debugging
    ctl.error(e).send();
  } finally {
    for (final s in ctl.samplers) {
      if (s is NativeMemoryUser) (s as NativeMemoryUser).free();
    }

    if (batch != null) llama_batch_free(batch);
    candidates?.dispose();
    tokens?.dispose();
    handle.close();
  }
}
