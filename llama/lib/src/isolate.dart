import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:ensemble_llama/llama_ffi.dart';

import 'package:ensemble_llama/src/params.dart';
import 'package:ensemble_llama/src/message_response.dart';
import 'package:ensemble_llama/src/message_control.dart';
import 'package:ensemble_llama/src/llama.dart'
    show Model, Context, Token, LogMessage;
import 'package:ensemble_llama/src/sampling.dart';

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
    n_threads = p.threads;
    n_threads_batch = p.batchThreads;

    rope_scaling_type = p.rope?.llamaRopeScalingType() ??
        llama_rope_scaling_type.LLAMA_ROPE_SCALING_UNSPECIFIED;
    if (p.rope is RopeLinear) {
      final rope = p.rope as RopeLinear;
      rope_freq_base = rope.freqBase;
      rope_freq_scale = rope.freqScale;
    } else if (p.rope is RopeYarn) {
      final yarn = p.rope as RopeYarn;
      yarn_ext_factor = yarn.extrapolFactor;
      yarn_beta_fast = yarn.betaFast;
      yarn_beta_slow = yarn.betaSlow;
      yarn_orig_ctx = yarn.origCtx;
    }

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
final class Candidates {
  final int vocabSize;
  int get size => pointer.ref.size;
  late final Pointer<llama_token_data> _candidates;
  late final Pointer<llama_token_data_array> pointer;

  Candidates(this.vocabSize) {
    _candidates = calloc.allocate(vocabSize * sizeOf<llama_token_data>());
    pointer = calloc.allocate(sizeOf<llama_token_data_array>());

    pointer.ref.data = _candidates;
    pointer.ref.size = vocabSize;
    pointer.ref.sorted = false;
  }

  void load(Pointer<Float> logits) {
    pointer.ref.size = vocabSize;
    pointer.ref.sorted = false;

    for (var i = 0; i < size; i++) {
      _candidates[i].id = i;
      _candidates[i].logit = logits[i];
      _candidates[i].p = 0.0;
    }
  }

  double getLogit(int tokId) => _candidates[tokId].logit;
  void setLogit(int tokId, double logit) => _candidates[tokId].logit = logit;

  String toStringContext(Context ctx) {
    final List<llama_token_data> copy = [];
    for (var i = 0; i < size; i++) {
      copy.add(_candidates[i]);
    }
    copy.sort((a, b) => b.logit.compareTo(a.logit));

    final strb = StringBuffer("cands = ");
    for (var i = 0; i < 8; i++) {
      strb.write(Token.fromId(ctx, _candidates[i].id));
      strb.write("=");
      strb.write(_candidates[i].logit.toStringAsFixed(2));
      strb.write(" ");
    }
    strb.write("...");
    return strb.toString();
  }

  void dispose() {
    calloc.free(_candidates);
    calloc.free(pointer);
  }
}

final class TokenBuf {
  int _length;
  int get length => _length;

  final Pointer<Int32> buf;
  final int capacity;
  TokenBuf._(this._length, this.buf, this.capacity);

  int operator [](int index) {
    RangeError.checkValidIndex(index, this);
    return buf[index];
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    buf[index] = value;
  }

  void add(int tokId) {
    assert(length <= capacity);
    if (_length == capacity) {
      throw Exception(
          "tried to store $_length tokens in $capacity token buffer");
    }
    buf[_length++] = tokId;
  }

  String toStringContext(Context ctx) {
    final strb = StringBuffer("buf[0:${length - 1}] = ");
    for (var i = 0; i < length; i++) {
      strb.write(Token.fromId(ctx, buf[i]));
    }
    return strb.toString();
  }

  factory TokenBuf.fromString(Context ctx, String text) {
    final contextSize = ctx.params.contextSizeTokens;
    final model = ctx.model;
    Pointer<Char>? textC;
    try {
      textC = text.toNativeUtf8(allocator: calloc).cast<Char>();
      final buf = calloc.allocate(contextSize * sizeOf<Int32>()).cast<Int32>();

      final numTokens = llama_tokenize(
        model.pointer,
        textC,
        text.length,
        buf,
        contextSize,
        true, // add Beginning-Of-Stream token
        false, // tokenize meta tokens (like BOS/EOS)
      );

      if (numTokens < 0) {
        throw Exception("llama_tokenize failed with $numTokens");
      } else if (numTokens >= contextSize) {
        throw Exception("prompt too large: $numTokens >= $contextSize tokens");
      }

      return TokenBuf._(numTokens, buf, contextSize);
    } finally {
      if (textC != null) calloc.free(textC);
    }
  }

  List<Token> toList(Context ctx) {
    final List<Token> list = [];
    for (var i = 0; i < length; i++) {
      list.add(Token.fromId(ctx, buf[i]));
    }
    return list;
  }

  void dispose() {
    calloc.free(buf);
  }
}

final class EntryArgs {
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

  llama_backend_init(false);
  llama_log_set(
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
      llama_backend_free();
      ctl.done().send();

    case LoadModelCtl():
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

        ctl.done(Model(rawModel)).send();
      } on ArgumentError catch (e) {
        ctl.error(e).send();
      } finally {
        if (pathStrC != null) calloc.free(pathStrC);
      }

    case FreeModelCtl():
      assert(ctl.model.rawPointer != 0);
      llama_free_model(ctl.model.pointer);
      ctl.done().send();

    case NewContextCtl():
      assert(ctl.model.rawPointer != 0);
      final params = llama_context_default_params()..setSimpleFrom(ctl.params);

      final rawCtx =
          llama_new_context_with_model(ctl.model.pointer, params).address;
      if (rawCtx == 0) {
        ctl.error(Exception("failed creating context")).send();
        return;
      }

      ctl.done(Context(rawCtx, ctl.model, ctl.params)).send();

    case FreeContextCtl():
      llama_free(ctl.ctx.pointer);
      ctl.done().send();

    case TokenizeCtl():
      TokenBuf? tokens;
      try {
        tokens = TokenBuf.fromString(ctl.ctx, ctl.prompt);
        ctl.done(tokens.toList(ctl.ctx)).send();
      } catch (e) {
        ctl.error(e).send();
      } finally {
        tokens?.dispose();
      }

    case GenerateCtl():
      Set<Pointer> allocs = {};
      llama_batch? batch;
      Candidates? candidates;
      TokenBuf? tokens;
      try {
        final ctx = ctl.ctx;
        final contextSize = ctx.params.contextSizeTokens;
        final batchSize = ctx.params.batchSizeTokens;

        candidates = Candidates(llama_n_vocab(ctx.model.pointer));
        tokens = TokenBuf.fromString(ctx, ctl.prompt);

        final promptSize = tokens.length;

        for (final s in [...ctl.samplers, ctl.terminalSampler]) {
          if (s is NativeMemoryUser) s.alloc();
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

          for (final s in ctl.samplers) {
            s.apply(ctx, candidates, tokens);
          }

          final tok =
              ctl.terminalSampler.applyAndSample(ctx, candidates, tokens);
          tokens.add(tok);
          ctl.token(Token.fromId(ctx, tok)).send();

          // Check if end of stream
          if (tok == llama_token_eos(ctx.model.pointer)) {
            break;
          }

          //
          // Decode next token
          //

          batch.n_tokens = 1;

          batch.token[0] = tok;
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
        ctl.error(e).send();
      } finally {
        for (final s in [...ctl.samplers, ctl.terminalSampler]) {
          if (s is NativeMemoryUser) s.free();
        }

        for (final p in allocs) {
          calloc.free(p);
        }

        if (batch != null) llama_batch_free(batch);
        candidates?.dispose();
        tokens?.dispose();
      }
  }
}
