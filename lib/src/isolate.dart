import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:ensemble_llama/llama_ffi.dart';

import 'package:ensemble_llama/src/params.dart';
import 'package:ensemble_llama/src/message_response.dart';
import 'package:ensemble_llama/src/message_control.dart';
import 'package:ensemble_llama/src/llama.dart'
    show Model, Context, Token, LogMessage;

extension on llama_model_params {
  void setSimpleFrom(ModelParams p) {
    n_gpu_layers = p.gpuLayers;
    main_gpu = p.cudaMainGpu;
    // Skipping: tensor_split
    // Skipping: progress_callback{,_user_data}
    vocab_only = p.loadOnlyVocabSkipTensors;
    use_mmap = p.useMmap;
    use_mlock = p.useMlock;
  }
}

extension on llama_context_params {
  void setSimpleFrom(ContextParams p) {
    seed = p.seed;
    n_ctx = p.contextSizeTokens;
    n_batch = p.batchSizeTokens;

    rope_freq_base = p.ropeFreqBase;
    rope_freq_scale = p.ropeFreqScale;

    mul_mat_q = p.cudaUseMulMatQ;
    f16_kv = p.useFloat16KVCache;
    logits_all = p.computeAllLogits;
    embedding = p.embeddingModeOnly;
  }
}

extension on ResponseMessage {
  void send() {
    _response.send(this);
  }
}

// Stores an array of candidate tokens and their logit probabilities.
class _Candidates {
  final int length;
  late final Pointer<llama_token_data> _candidates;
  late final Pointer<llama_token_data_array> pointer;

  _Candidates(this.length) {
    _candidates = calloc.allocate(length * sizeOf<llama_token_data>());
    pointer = calloc.allocate(sizeOf<llama_token_data_array>());

    pointer.ref.data = _candidates;
    pointer.ref.size = length;
    pointer.ref.sorted = false;
  }

  void load(Pointer<Float> logits) {
    for (var i = 0; i < length; i++) {
      _candidates[i].id = i;
      _candidates[i].logit = logits[i];
      _candidates[i].p = 0.0;
    }
  }

  void dispose() {
    calloc.free(_candidates);
    calloc.free(pointer);
  }
}

class EntryArgs {
  final SendPort log, response;
  const EntryArgs({required this.log, required this.response});
}

late final SendPort _log;
late final SendPort _response;

final ReceivePort _controlPort = ReceivePort();
final Stream<ControlMessage> _control = _controlPort.cast<ControlMessage>();

void init(EntryArgs args) {
  _log = args.log;
  _response = args.response;

  _control.listen(_onControl);
  HandshakeResp(_controlPort.sendPort).send();

  libllama.llama_backend_init(false);
  libllama.llama_log_set(
    Pointer.fromFunction(_onLlamaLog),
    Pointer.fromAddress(0), // not used
  );
}

void _onLlamaLog(int level, Pointer<Char> text, Pointer<Void> userData) =>
    _log.send(LogMessage(
        level: level, text: text.cast<Utf8>().toDartString().trimRight()));

void _onModelLoadProgress(double progress, Pointer<Void> id) =>
    LoadModelProgressResp(id.address, progress).send();

void _onControl(ControlMessage ctl) {
  switch (ctl) {
    case ExitCtl():
      _controlPort.close();
      libllama.llama_backend_free();
      ctl.done().send();

    case LoadModelCtl():
      Pointer<Char>? pathStrC;
      try {
        final params = libllama.llama_model_default_params()
          ..setSimpleFrom(ctl.params);

        params.progress_callback = Pointer.fromFunction(_onModelLoadProgress);
        // use the pointer value itself to store ctl.id, so we don't need to malloc
        params.progress_callback_user_data = Pointer.fromAddress(ctl.id);

        pathStrC = ctl.path.toNativeUtf8(allocator: calloc).cast<Char>();
        final rawModel =
            libllama.llama_load_model_from_file(pathStrC, params).address;
        if (rawModel == 0) {
          ctl.error(Exception("failed loading model: ${ctl.path}")).send();
          return;
        }

        ctl.done(Model(rawModel)).send();
      } on ArgumentError catch (e) {
        ctl.error(e).send();
      } finally {
        if (pathStrC != null) calloc.free(pathStrC);
      }

    case FreeModelCtl():
      assert(ctl.model.rawPointer != 0);
      libllama.llama_free_model(ctl.model.pointer);
      ctl.done().send();

    case NewContextCtl():
      assert(ctl.model.rawPointer != 0);
      final params = libllama.llama_context_default_params()
        ..setSimpleFrom(ctl.params);

      final rawCtx = libllama
          .llama_new_context_with_model(ctl.model.pointer, params)
          .address;
      if (rawCtx == 0) {
        ctl.error(Exception("failed creating context")).send();
        return;
      }

      ctl.done(Context(rawCtx, ctl.model, ctl.params)).send();

    case FreeContextCtl():
      libllama.llama_free(ctl.ctx.pointer);
      ctl.done().send();

    case GenerateCtl():
      Set<Pointer> allocs = {};
      llama_batch? batch;
      _Candidates? candidates;
      try {
        final ctx = ctl.ctx;
        final contextSize = ctx.params.contextSizeTokens;
        final batchSize = ctx.params.batchSizeTokens;

        final Pointer<Char> promptStrC =
            ctl.prompt.toNativeUtf8(allocator: calloc).cast<Char>();
        allocs.add(promptStrC);

        final Pointer<Int32> tokenBuf =
            calloc.allocate(contextSize * sizeOf<Int32>()).cast<Int32>();
        allocs.add(tokenBuf);

        candidates = _Candidates(libllama.llama_n_vocab(ctx.model.pointer));

        //
        // Tokenize prompt
        //
        int promptTokenCount = libllama.llama_tokenize(
          ctx.model.pointer,
          promptStrC,
          ctl.prompt.length,
          tokenBuf,
          contextSize,
          true, // add Beginning-Of-Stream token
        );

        if (promptTokenCount < 0) {
          ctl
              .error(Exception("llama_tokenize failed with $promptTokenCount"))
              .send();
          return;
        } else if (promptTokenCount >= contextSize) {
          ctl
              .error(Exception(
                  "prompt too large: $promptTokenCount >= $contextSize tokens"))
              .send();
          return;
        }

        //
        // Evaluate prompt.
        //
        // To do so, we fill up a llama_batch with tokens, call llama_decode()
        // to load those tokens into the model, and repeat until we run out of
        // prompt tokens.

        batch = libllama.llama_batch_init(batchSize, 0);

        var i = 0; // index into context window
        var j = 0; // index into current batch
        while (i + j < promptTokenCount) {
          final promptTokensRemaining = promptTokenCount - i;
          final isLastBatch = promptTokensRemaining <= batchSize;
          final fillCount = isLastBatch ? promptTokensRemaining : batchSize;

          batch.n_tokens = fillCount;
          for (j = 0; j < fillCount; j++) {
            print(
                "Adding token ${Token.fromId(ctx, tokenBuf[i + j])} to batch");
            batch.token[j] = tokenBuf[i + j];
            batch.pos[j] = i + j; // is just j sufficient? small numbers anyhow
            batch.seq_id[j] = 0;
            batch.logits[j] = isLastBatch ? 1 : 0;
          }

          final status = libllama.llama_decode(ctx.pointer, batch);
          if (status != 0) {
            ctl.error(Exception("llama_decode failed with $status")).send();
            return;
          }

          assert(j <= batchSize);
          if (j == batchSize) {
            i += batchSize;
            j = 0;
          }
        }

        print("i=$i; j=$j");

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

          final logits =
              libllama.llama_get_logits_ith(ctx.pointer, logitsIndex);
          candidates.load(logits);

          final tok = libllama.llama_sample_token_greedy(
              ctx.pointer, candidates.pointer);
          ctl.token(Token.fromId(ctx, tok)).send();

          // Check if end of stream
          if (tok == libllama.llama_token_eos(ctx.pointer)) {
            break;
          }

          //
          // Decode next token
          //

          batch.n_tokens = 1;

          batch.token[0] = tok;
          batch.pos[0] = i++;
          batch.seq_id[0] = 0;
          batch.logits[0] = 1; // enable logits for this token

          final status = libllama.llama_decode(ctx.pointer, batch);
          if (status != 0) {
            ctl.error(Exception("llama_decode failed with $status")).send();
            return;
          }
        }

        ctl.done().send();
      } finally {
        for (final p in allocs) {
          calloc.free(p);
        }
        if (batch != null) libllama.llama_batch_free(batch);
        candidates?.dispose();
      }
  }
}
