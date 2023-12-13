import 'dart:async';
import 'dart:ffi';

import 'package:async/async.dart';
import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';
import 'package:logging/logging.dart';

import 'package:llamacpp/src/libllama.dart';
import 'package:llamacpp/src/disposable.dart';
import 'package:llamacpp/src/samplers.dart';
import 'package:llamacpp/src/sampling.dart';

final _log = Logger('LlamaCpp');

void _onLlamaLog(int levelGgml, Pointer<Char> text, Pointer<Void> userData) {
  final level = switch (levelGgml) {
    ggml_log_level.GGML_LOG_LEVEL_ERROR => Level.SEVERE,
    ggml_log_level.GGML_LOG_LEVEL_WARN => Level.WARNING,
    ggml_log_level.GGML_LOG_LEVEL_INFO => Level.FINEST,
    _ => throw Exception('Unknown log level: $levelGgml'),
  };

  _log.log(level, () => text.cast<Utf8>().toDartString().trimRight());
}

typedef ModelLoadProgressCallback = void Function(double progress);
ModelLoadProgressCallback? _userModelLoadProgressCallback;
void _onLlamaModelLoadProgress(double progress, Pointer<Void> userData) {
  _userModelLoadProgressCallback?.call(progress);
}

final class LlamaCpp {
  static bool _isInitialized = false;
  static void _init() {
    if (_isInitialized) return;

    // We don't currently call llama_backend_free since it's only used for MPI.
    // This should be revisited in the future.
    llama_backend_init(false);
    llama_log_set(Pointer.fromFunction(_onLlamaLog), Pointer.fromAddress(0));

    _isInitialized = true;
  }

  static Model loadModel(
    String path, {
    llama_model_params? params,
    ModelLoadProgressCallback? callback,
  }) {
    _init();
    Pointer<Utf8>? utf;
    try {
      final utf = path.toNativeUtf8(allocator: calloc);
      params = params ?? Model.defaultParams;
      if (callback != null) {
        _userModelLoadProgressCallback = callback;
        params.progress_callback =
            Pointer.fromFunction(_onLlamaModelLoadProgress);
      }

      final model = llama_load_model_from_file(
        utf.cast<Char>(),
        params,
      );
      return Model(model);
    } finally {
      // ignore: unnecessary_null_comparison
      if (utf != null) calloc.free(utf);
      _userModelLoadProgressCallback = null;
    }
  }

  static Stream<Token> generate({
    required String modelPath,
    required String prompt,
    llama_model_params? modelParams,
    llama_context_params? contextParams,
    ModelLoadProgressCallback? onModelLoadProgress,
    List<Sampler> samplers = const [Temperature(0.0)],
  }) async* {
    Model? model;
    Context? ctx;
    try {
      model = loadModel(
        modelPath,
        params: modelParams,
        callback: onModelLoadProgress,
      );
      ctx = model.newContext(contextParams)..add(prompt);

      final completer = Completer<void>();
      ctx.ingest().then(
            (_) => completer.complete(null),
            onError: completer.completeError,
          );
      await completer.future;
      yield* ctx.generate(samplers: samplers);
    } finally {
      ctx?.dispose();
      model?.dispose();
    }
  }
}

final class Model with Disposable {
  static llama_model_params get defaultParams => llama_model_default_params();

  final Pointer<llama_model> pointer;
  Model(this.pointer);

  @override
  void dispose() {
    super.dispose();
    llama_free_model(pointer);
  }

  Context newContext([llama_context_params? params]) {
    params ??= Context.defaultParams;
    return Context(this, params);
  }
}

final class Context with Disposable {
  static final _log = Logger('Context');
  static llama_context_params get defaultParams =>
      llama_context_default_params();

  final Model model;
  final llama_context_params params;
  late final Pointer<llama_context> pointer;

  late final TokenBuf tokens;
  late final Logits logits;
  late final Candidates candidates;
  late final llama_batch batch;

  bool get needsIngesting => logits.length < tokens.length;

  Context(this.model, this.params) {
    pointer = llama_new_context_with_model(model.pointer, params);

    // TODO(crasm): sanity check _params for these allocations
    final vocabSize = llama_n_vocab(model.pointer);
    tokens = TokenBuf.allocate(params.n_ctx);
    logits = Logits(params.n_ctx, vocabSize);
    candidates = Candidates(vocabSize);
    batch = llama_batch_init(params.n_batch, 0, 1);
  }

  @override
  void dispose() {
    super.dispose();
    llama_free(pointer);
  }

  List<Token> add(String text) {
    checkDisposed();
    final numToks = tokens.addFromString(model.pointer, text);
    return tokens.toList(model.pointer, numToks);
  }

  void _trimKvCache(int length) {
    llama_kv_cache_seq_rm(pointer, 1, length, -1);
  }

  void trim(int length) {
    checkDisposed();
    tokens.length = length;
    if (logits.length > length) {
      logits.length = length;
      _trimKvCache(length);
    }
  }

  CancelableOperation<void> ingest() {
    checkDisposed();
    final completer = CancelableCompleter<void>();
    completer.complete(_ingest(completer)); // ignore: discarded_futures
    return completer.operation;
  }

  Future<void> _ingest(CancelableCompleter<void> completer) async {
    try {
      final batchSize = params.n_batch;
      var i = logits.length; // index of the next token to be decoded
      var j = 0; // start batch at zero tokens on every ingest()

      int tokensToDecode() => tokens.length - i;

      _log.info('Ingesting ${tokensToDecode()} tokens');

      while ((i = logits.length) + j < tokens.length) {
        final isLastBatch = tokensToDecode() <= batchSize;
        final fillCount = isLastBatch ? tokensToDecode() : batchSize;

        batch.n_tokens = fillCount;
        for (j = 0; j < fillCount; j++) {
          batch.token[j] = tokens[i + j];
          batch.pos[j] = i + j;
          batch.n_seq_id[j] = 1;
          batch.seq_id[j][0] = 1;
          batch.logits[j] = 1;
        }

        // ignore: inference_failure_on_instance_creation
        await Future.delayed(Duration.zero);
        if (completer.isCanceled) return;
        final status = llama_decode(pointer, batch);
        if (status != 0) {
          throw Exception('llama_decode failed with $status');
        }
        logits.add(llama_get_logits(pointer), batch.n_tokens);

        assert(j <= batchSize);
        if (j == batchSize) j = 0;
      }
    } finally {
      _trimKvCache(logits.length);
    }
  }

  Stream<Token> generate({
    List<Sampler> samplers = const [Temperature(0.0)],
  }) async* {
    checkDisposed();
    final contextSize = params.n_ctx;

    try {
      for (final s in samplers) {
        if (s is NativeMemoryUser) {
          (s as NativeMemoryUser).alloc();
        }
      }

      if (needsIngesting) {
        throw StateError('must call ingest before generate');
      }

      //
      // Generate tokens to fill context
      //

      while (logits.length < contextSize) {
        candidates.load(logits.last);

        // Apply each sampler in turn. If we receive a token back, it should
        // be the last sampler. If there are samplers remaining and we already
        // have a token, it is an error.
        Token? tok;
        final samplerCount = samplers.length;
        for (var i = 0; i < samplerCount; i++) {
          final samp = samplers[i];
          tok = samp.sample(this);

          if (tok != null) {
            if (samplerCount > i + 1) {
              final unused = samplers.skip(i + 1).toList(growable: false);
              final buf = StringBuffer()..writeAll(unused);
              throw ArgumentError.value(
                unused,
                'Unexpected token from $samp. '
                'Unable to process these additional samplers: $buf',
              );
            }

            break;
          }
        }

        tok ??= const DefaultLastSampler().sample(this);

        tokens.add(tok!.id);
        yield tok;

        // Check if end of stream
        if (tok.id == llama_token_eos(model.pointer)) {
          break;
        }

        //
        // Decode next token
        //

        batch.n_tokens = 1;

        batch.token[0] = tok.id;
        batch.pos[0] = logits.length;
        batch.n_seq_id[0] = 1;
        batch.seq_id[0][0] = 1;
        batch.logits[0] = 1;

        final status = llama_decode(pointer, batch);
        if (status != 0) {
          throw Exception('llama_decode failed with $status');
        }

        logits.add(llama_get_logits(pointer), batch.n_tokens);
      }
    } finally {
      for (final s in samplers) {
        if (s is NativeMemoryUser) {
          (s as NativeMemoryUser).free();
        }
      }
    }
  }
}

@immutable
final class Token {
  final int id;
  final String text;
  final String rawText;

  const Token(this.id, this.text, this.rawText);

  factory Token.fromId(Pointer<llama_model> modelPointer, int id) {
    final rawText =
        llama_token_get_text(modelPointer, id).cast<Utf8>().toDartString();
    // replace U+2581 with a space
    final text = rawText.replaceAll('▁', ' ').replaceAll('<0x0A>', '\n');
    return Token(id, text, rawText);
  }

  @override
  String toString([int? i]) {
    final buf = StringBuffer();
    if (i != null) {
      buf.write(i.toString().padLeft(4));
      buf.write(':');
    }
    buf.write(id.toString().padLeft(6));
    buf.write(' = ');
    buf.write(rawText);
    return buf.toString();
  }

  @override
  bool operator ==(Object? other) =>
      other is Token && other.id == id && other.rawText == rawText;
  @override
  int get hashCode => id.hashCode + rawText.hashCode;
}
