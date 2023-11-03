import 'dart:ffi';
import 'dart:isolate';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:ensemble_llama/ensemble_llama_cpp.dart';
import 'package:ensemble_llama/src/ensemble_llama_base.dart'
    show ModelParams, ContextParams, SamplingParams;

// 4294967295 (32 bit unsigned)
// -1 (32 bit signed)
const int32Max = 0xFFFFFFFF;

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

class Model {
  final int _rawPointer;
  const Model._(this._rawPointer);
  Pointer<llama_model> get _ffiPointer =>
      Pointer.fromAddress(_rawPointer).cast<llama_model>();
  @override
  String toString() => "Model{$_rawPointer}";
}

class Context {
  final int _rawPointer;
  final Model model;
  final ContextParams params;
  const Context._(this._rawPointer, this.model, this.params);
  Pointer<llama_context> get _ffiPointer =>
      Pointer.fromAddress(_rawPointer).cast<llama_context>();
}

class Token {
  final int id;
  final String _str;
  const Token(this.id, this._str);

  factory Token.fromId(Context ctx, int id) => Token(
        id,
        libllama
            .llama_token_get_text(ctx._ffiPointer, id)
            .cast<Utf8>()
            .toDartString()
            .replaceAll("▁", " "), // replace U+2581 with a space
      );

  @override
  String toString() {
    return _str;
  }
}

class LogMessage {
  final int level;
  final String text;
  const LogMessage({
    required this.level,
    required this.text,
  });

  @override
  String toString() {
    String levelStr = switch (level) {
      ggml_log_level.GGML_LOG_LEVEL_ERROR => 'ERROR',
      ggml_log_level.GGML_LOG_LEVEL_WARN => 'WARN',
      ggml_log_level.GGML_LOG_LEVEL_INFO => 'INFO',
      _ => throw Exception("Unknown log level: $level"),
    };

    return "$levelStr: $text";
  }
}

sealed class ControlMessage {
  final id = Random().nextInt(int32Max);
  ControlMessage();
}

class ExitCtl extends ControlMessage {
  ExitResp done() => ExitResp(id);
}

class LoadModelCtl extends ControlMessage {
  final String path;
  final ModelParams params;
  LoadModelCtl(this.path, this.params);

  LoadModelResp done(Model model) => LoadModelResp(id, model: model);
  LoadModelResp error(Object err) => LoadModelResp(id, err: err);
  LoadModelProgressResp progress(double progress) =>
      LoadModelProgressResp(id, progress);
}

class FreeModelCtl extends ControlMessage {
  final Model model;
  FreeModelCtl(this.model);

  FreeModelResp done() => FreeModelResp(id);
}

class NewContextCtl extends ControlMessage {
  final Model model;
  final ContextParams params;
  NewContextCtl(this.model, this.params);

  NewContextResp done(Context ctx) => NewContextResp(id, ctx: ctx);
  NewContextResp error(Object err) => NewContextResp(id, err: err);
}

class FreeContextCtl extends ControlMessage {
  final Context ctx;
  FreeContextCtl(this.ctx);

  FreeContextResp done() => FreeContextResp(id);
}

class GenerateCtl extends ControlMessage {
  final Context ctx;
  final String prompt;
  final SamplingParams sparams;
  GenerateCtl(this.ctx, this.prompt, this.sparams);

  GenerateResp done() => GenerateResp(id);
  GenerateResp error(Object err) => GenerateResp(id, err: err);
  GenerateTokenResp token(Token tok) => GenerateTokenResp(id, tok);
}

sealed class ResponseMessage {
  final int id;
  final Object? err;
  const ResponseMessage(this.id, {this.err}) : assert(id <= int32Max);
  void throwIfErr() {
    if (err != null) {
      throw err!;
    }
  }
}

class HandshakeResp extends ResponseMessage {
  final SendPort controlPort;
  const HandshakeResp(this.controlPort, [super.id = 0]);
}

class ExitResp extends ResponseMessage {
  const ExitResp(super.id);
}

// TODO: include mem used, model details?
class LoadModelResp extends ResponseMessage {
  final Model? model;
  const LoadModelResp(super.id, {super.err, this.model});
}

class LoadModelProgressResp extends ResponseMessage {
  final double progress;
  const LoadModelProgressResp(super.id, this.progress);
}

class FreeModelResp extends ResponseMessage {
  const FreeModelResp(super.id);
}

class NewContextResp extends ResponseMessage {
  final Context? ctx;
  const NewContextResp(super.id, {super.err, this.ctx});
}

class FreeContextResp extends ResponseMessage {
  const FreeContextResp(super.id);
}

class GenerateResp extends ResponseMessage {
  const GenerateResp(super.id, {super.err});
}

class GenerateTokenResp extends ResponseMessage {
  final Token tok;
  const GenerateTokenResp(super.id, this.tok);
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
  _response.send(HandshakeResp(_controlPort.sendPort));

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
    _response.send(LoadModelProgressResp(id.address, progress));

void _onControl(ControlMessage ctl) {
  switch (ctl) {
    case ExitCtl():
      _controlPort.close();
      libllama.llama_backend_free();
      _response.send(ctl.done());

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
          _response
              .send(ctl.error(Exception("failed loading model: ${ctl.path}")));
          return;
        }

        _response.send(ctl.done(Model._(rawModel)));
      } on ArgumentError catch (e) {
        _response.send(ctl.error(e));
      } finally {
        if (pathStrC != null) calloc.free(pathStrC);
      }

    case FreeModelCtl():
      assert(ctl.model._rawPointer != 0);
      libllama.llama_free_model(ctl.model._ffiPointer);
      _response.send(ctl.done());

    case NewContextCtl():
      assert(ctl.model._rawPointer != 0);
      final params = libllama.llama_context_default_params()
        ..setSimpleFrom(ctl.params);

      final rawCtx = libllama
          .llama_new_context_with_model(ctl.model._ffiPointer, params)
          .address;
      if (rawCtx == 0) {
        _response.send(ctl.error(Exception("failed creating context")));
        return;
      }

      _response.send(ctl.done(Context._(rawCtx, ctl.model, ctl.params)));

    case FreeContextCtl():
      libllama.llama_free(ctl.ctx._ffiPointer);
      _response.send(ctl.done());

    case GenerateCtl():
      Set<Pointer> allocs = {};
      llama_batch? batch;
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

        //
        // Tokenize prompt
        //
        int promptTokenCount = libllama.llama_tokenize(
          ctx.model._ffiPointer,
          promptStrC,
          ctl.prompt.length,
          tokenBuf,
          batchSize,
          true,
        );

        if (promptTokenCount < 0) {
          ctl.error(Exception("llama_tokenize failed with $promptTokenCount"));
          return;
        } else if (promptTokenCount >= contextSize) {
          ctl.error(Exception(
              "prompt too large: $promptTokenCount >= $contextSize tokens"));
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
          final isLastBatch = promptTokensRemaining < batchSize;
          final fillCount = isLastBatch ? promptTokensRemaining : batchSize;

          batch.n_tokens = fillCount;
          for (j = 0; j < fillCount; j++) {
            batch.token[j] = tokenBuf[i + j];
            batch.pos[j] = i + j; // is just j sufficient? small numbers anyhow
            batch.seq_id[j] = 0;
            batch.logits[j] = isLastBatch ? 1 : 0;
          }

          final status = libllama.llama_decode(ctx._ffiPointer, batch);
          if (status != 0) {
            _response
                .send(ctl.error(Exception("llama_decode failed with $status")));
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

        final vocabSize = libllama.llama_n_vocab(ctx.model._ffiPointer);

        Pointer<llama_token_data> candidates =
            calloc.allocate(vocabSize * sizeOf<llama_token_data>());
        allocs.add(candidates);
        Pointer<llama_token_data_array> candidatesWrapper =
            calloc.allocate(sizeOf<llama_token_data_array>());
        allocs.add(candidatesWrapper);

        candidatesWrapper.ref.data = candidates;
        candidatesWrapper.ref.size = vocabSize;
        candidatesWrapper.ref.sorted = false;

        while (i + j < contextSize) {
          final logits = libllama.llama_get_logits_ith(ctx._ffiPointer, i);
          for (var k = 0; k < vocabSize; k++) {
            candidates[k].id = k;
            candidates[k].logit = logits[k];
            candidates[k].p = 0.0;
          }

          final tok = libllama.llama_sample_token_greedy(
              ctx._ffiPointer, candidatesWrapper);
          _response.send(ctl.token(Token.fromId(ctx, tok)));

          // Check if end of stream
          if (tok == libllama.llama_token_eos(ctx._ffiPointer)) {
            break;
          }

          //
          // Decode next token
          //

          assert(j <= batchSize);
          if (j == batchSize) {
            j = 0;
            i += batchSize;
          }

          if (j - 1 >= 0) {
            batch.logits[j - 1] = 0; // disable logits for the previous token
          }

          batch.n_tokens = j + 1;

          batch.token[j] = tok;
          batch.pos[j] = i + j;
          batch.seq_id[j] = 0;
          batch.logits[j] = 1; // enable logits for this token

          j++;

          final status = libllama.llama_decode(ctx._ffiPointer, batch);
          if (status != 0) {
            _response
                .send(ctl.error(Exception("llama_decode failed with $status")));
            return;
          }
        }

        _response.send(ctl.done());
      } finally {
        for (final p in allocs) {
          calloc.free(p);
        }
        if (batch != null) libllama.llama_batch_free(batch);
      }
  }
}
