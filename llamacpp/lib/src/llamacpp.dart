import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';
import 'package:logging/logging.dart';

import 'package:ensemble_llamacpp/src/libllama.dart';
import 'package:ensemble_llamacpp/src/disposable.dart';

part 'range.dart';
part 'samplers.dart';
part 'sampling.dart';

/// Represents the progress of prompt ingestion (decoding).
@immutable
final class IngestProgressEvent {
  /// Number of tokens that have been ingested.
  final int done;

  /// Total number of tokens to be ingested, including those already [done].
  final int total;

  /// The batch size for ingesting, in tokens.
  final int batchSize;
  const IngestProgressEvent._(this.done, this.total, this.batchSize);

  @override
  String toString() =>
      'IngestProgressEvent{$done of $total, batchSize: $batchSize)';
}

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

/// Callback to receive the progress (from 0.0 to 1.0, inclusive) of loading the
/// model.
///
/// The [ModelLoadProgressCallback] must return true for the model loading to
/// continue. Returning false cancels loading the model.
typedef ModelLoadProgressCallback = bool Function(double progress);
ModelLoadProgressCallback? _userModelLoadProgressCallback;
bool _onLlamaModelLoadProgress(double progress, Pointer<Void> userData) {
  // ignore: avoid_bool_literals_in_conditional_expressions
  return _userModelLoadProgressCallback != null
      ? _userModelLoadProgressCallback!.call(progress)
      : true;
}

/// Entry point for the llamacpp-dart library, containing the static methods
/// [loadModel] and [generate].
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

  /// There is no reason to construct a [LlamaCpp].
  LlamaCpp._();

  /// Synchronously load a model from the file at [path] using [params].
  ///
  /// **This is a blocking call because it calls [llama_load_model_from_file].**
  ///
  /// You can cancel the model load by returning false from [progressCallback].
  /// Do not perform complex operations inside progressCallback, since it will
  /// block the model from loading. Async operations within progressCallback
  /// will likely not work as expected.
  ///
  /// Setting [llama_model_params.progress_callback] directly is an error.
  ///
  /// [llama_model_params.n_gpu_layers] and [llama_model_params.main_gpu] must
  /// be between 0 and [int32Max], inclusive.
  static Model loadModel(
    String path, {
    llama_model_params? params,
    ModelLoadProgressCallback? progressCallback,
  }) {
    _init();
    Pointer<Utf8>? utf;
    try {
      final utf = path.toNativeUtf8(allocator: calloc);
      params = params ?? Model.defaultParams;

      params.n_gpu_layers.checkIncInc(0, int32Max, 'n_gpu_layers');
      params.main_gpu.checkIncInc(0, int32Max, 'main_gpu');
      if (params.progress_callback.address != 0) {
        throw ArgumentError.value(
            params.progress_callback,
            'params.progress_callback',
            'you cannot set params.progress_callback, use progressCallback '
                'instead');
      }

      if (progressCallback != null) {
        _userModelLoadProgressCallback = progressCallback;
        params.progress_callback =
            Pointer.fromFunction(_onLlamaModelLoadProgress, false);
      }

      final model = llama_load_model_from_file(
        utf.cast<Char>(),
        params,
      );

      if (model.address == 0) throw Exception('model failed to load');
      return Model._(model);
    } finally {
      // ignore: unnecessary_null_comparison
      if (utf != null) calloc.free(utf);
      _userModelLoadProgressCallback = null;
    }
  }

  /// Convenience function for running inference with a single static call.
  ///
  /// The model is loaded from [modelPath] using [loadModel] with [modelParams]
  /// and an optional [onModelLoadProgress] callback. A context is created with
  /// [Model.newContext] using [contextParams].
  ///
  /// The return stream begins with `(IngestProgressEvent, null)` during prompt
  /// ingestion. (See [Context.ingest].) After prompt ingestion is complete, the
  /// stream events contain `(null, Token)`, where the token is generated and
  /// sampled according to [contextParams] and [samplers]. (See
  /// [Context.generate].)
  static Stream<(IngestProgressEvent? progress, Token? token)> generate({
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
        progressCallback: onModelLoadProgress,
      );
      ctx = model.newContext(contextParams)..add(prompt);

      yield* ctx.ingestWithProgress().map((progress) => (progress, null));
      yield* ctx.generate(samplers: samplers).map((token) => (null, token));
    } finally {
      ctx?.dispose();
      model?.dispose();
    }
  }
}

/// Handle to a model that was loaded into memory.
final class Model with Disposable {
  /// Default [llama_model_params] defined upstream by llama.cpp
  static llama_model_params get defaultParams => llama_model_default_params();

  /// The pointer to the [llama_model] returned from
  /// [llama_load_model_from_file] when this model was loaded.
  final Pointer<llama_model> pointer;
  Model._(this.pointer);

  @override
  void dispose() {
    super.dispose();
    llama_free_model(pointer);
  }

  /// Create a new context for this [Model] based on [params].
  ///
  /// Note that dart represents the base C struct number values as 64-bit int
  /// and double. Int and double values that cannot be represented in the
  /// parameters below may result in an [ArgumentError].
  ///
  /// Annotated [llama_context_params] from `llama.cpp/llama.h`:
  /// ```
  /// struct llama_context_params {
  ///     uint32_t seed;              // RNG seed, -1 for random
  ///                                    // dart: use [uint32Max] for random
  ///     uint32_t n_ctx;             // text context, 0 = from model
  ///     uint32_t n_batch;           // prompt processing maximum batch size
  ///     uint32_t n_threads;         // number of threads to use for generation
  ///     uint32_t n_threads_batch;   // number of threads to use for batch processing
  ///     int8_t   rope_scaling_type; // RoPE scaling type, from `enum llama_rope_scaling_type`
  ///
  ///     // ref: https://github.com/ggerganov/llama.cpp/pull/2054
  ///     float    rope_freq_base;   // RoPE base frequency, 0 = from model
  ///     float    rope_freq_scale;  // RoPE frequency scaling factor, 0 = from model
  ///     float    yarn_ext_factor;  // YaRN extrapolation mix factor, negative = from model
  ///     float    yarn_attn_factor; // YaRN magnitude scaling factor
  ///     float    yarn_beta_fast;   // YaRN low correction dim
  ///     float    yarn_beta_slow;   // YaRN high correction dim
  ///     uint32_t yarn_orig_ctx;    // YaRN original context size
  ///
  ///     enum ggml_type type_k; // data type for K cache
  ///     enum ggml_type type_v; // data type for V cache
  ///
  ///     // Keep the booleans together to avoid misalignment during copy-by-value.
  ///     bool mul_mat_q;   // if true, use experimental mul_mat_q kernels (DEPRECATED - always true)
  ///     bool logits_all;  // the llama_eval() call computes all logits, not just the last one (DEPRECATED - set llama_batch.logits instead)
  ///     bool embedding;   // embedding mode only
  ///     bool offload_kqv; // whether to offload the KQV ops (including the KV cache) to GPU
  /// };
  /// ```
  Context newContext([llama_context_params? params]) {
    params ??= Context.defaultParams;

    const lcp = 'llama_context_params';
    (llama_context_params p) {
      p.seed.checkIncInc(0, uint32Max, '$lcp.seed');
      p.n_ctx.checkIncInc(0, uint32Max, '$lcp.n_ctx');
      p.n_batch.checkIncInc(0, uint32Max, '$lcp.n_batch');
      p.n_threads.checkIncInc(0, uint32Max, '$lcp.n_threads');
      p.n_threads_batch.checkIncInc(0, uint32Max, '$lcp.n_threads_batch');

      p.rope_scaling_type.checkIncInc(
          llama_rope_scaling_type.LLAMA_ROPE_SCALING_UNSPECIFIED,
          llama_rope_scaling_type.LLAMA_ROPE_SCALING_MAX_VALUE,
          '$lcp.rope_scaling_type');

      p.rope_freq_base.checkIncInc(0.0, float32Max, '$lcp.rope_freq_base');
      p.rope_freq_scale.checkIncInc(0.0, float32Max, '$lcp.rope_freq_scale');
      /* llama.cpp uses negative values to represent "load from model" */
      // p.yarn_ext_factor.checkIncInc(0.0, float32Max, '$lcp.yarn_ext_factor');
      p.yarn_attn_factor.checkIncInc(0.0, float32Max, '$lcp.yarn_attn_factor');
      p.yarn_beta_fast.checkIncInc(0.0, float32Max, '$lcp.yarn_beta_fast');
      p.yarn_beta_slow.checkIncInc(0.0, float32Max, '$lcp.yarn_beta_slow');
      p.yarn_orig_ctx.checkIncInc(0.0, uint32Max, '$lcp.yarn_orig_ctx');

      p.type_k.checkIncInc(
          ggml_type.GGML_TYPE_F32, ggml_type.GGML_TYPE_COUNT, '$lcp.type_k');
      p.type_v.checkIncInc(
          ggml_type.GGML_TYPE_F32, ggml_type.GGML_TYPE_COUNT, '$lcp.type_v');
    }(params);

    return Context._(this, params);
  }
}

/// Handle to a context created for a [Model].
final class Context with Disposable {
  static final _log = Logger('Context');

  /// Default [llama_context_params] defined upstream by llama.cpp.
  static llama_context_params get defaultParams =>
      llama_context_default_params();

  /// The [Model] this [Context] was created for.
  final Model model;

  /// The params for this context, such as n_ctx and rope_scaling_type.
  final llama_context_params params;

  /// The pointer to the [llama_context] returned from
  /// [llama_new_context_with_model] when this context was created.
  late final Pointer<llama_context> pointer;

  /// The current tokens in this context's window.
  late final ContextTokens tokens;

  /// The logit sets for potential tokens for each position of this context's
  /// window, pending decoding.
  late final ContextLogits logits;

  late final Candidates _candidates;
  late final llama_batch _batch;

  bool get _needsIngesting => logits.length < tokens.length;

  Context._(this.model, this.params)
      : assert(model.pointer.address != 0),
        assert(params.n_ctx >= 0),
        assert(params.n_batch >= 0) {
    final vocabSize = llama_n_vocab(model.pointer);
    pointer = llama_new_context_with_model(model.pointer, params);
    tokens = ContextTokens._(params.n_ctx);
    logits = ContextLogits._(params.n_ctx, vocabSize);
    _candidates = Candidates(vocabSize);
    _batch = llama_batch_init(params.n_batch, 0, 1);
  }

  @override
  void dispose() {
    super.dispose();
    llama_free(pointer);
  }

  /// Tokenize and add [text] to this context.
  ///
  /// When text is added to an empty context, the first token will be the BOS
  /// (Beginning-Of-Stream) token. Subsequent [add] calls will not begin with a
  /// BOS unless the context is cleared with [clear] or [trim].
  ///
  /// Adding tokens incrementally (and subsequently calling [ingest] to process
  /// them) is possible, but requires careful handling of where text is split.
  ///
  /// Leading spaces in [text] will be tokenized, even if the token itself has a
  /// leading space. For example (as of llama.cpp:55e87c3):
  /// * `ctx.add('Sam')` => `[ '<s>' '_Sam' ]`
  /// * `ctx.add(' Sam')` => `[ '<s>' '_' '_Sam' ]`
  List<Token> add(String text) {
    checkDisposed();
    final numToks = tokens.addFromString(model.pointer, text);
    final newToks = tokens.toList(model.pointer, numToks);
    _log.finest(() {
      if (newToks.isEmpty) {
        return "Context.add([ '' ])";
      }

      final buf = StringBuffer('Context.add([\n');
      newToks.forEach(buf.writeln);
      buf.write('])');
      return buf.toString();
    });
    return newToks;
  }

  void _trimKvCache(int length) {
    llama_kv_cache_seq_rm(pointer, 1, length, -1);
  }

  /// Resets and clears the context.
  void clear() => trim(0);

  /// Trims the context window to [length].
  ///
  /// For any tokens beyond [length], it will be as if they were never
  /// generated.
  void trim(int length) {
    checkDisposed();
    tokens.length = length;
    if (logits.length > length) {
      logits.length = length;
      _trimKvCache(length);
    }
  }

  /// Ingest added tokens.
  Future<void> ingest() async {
    await ingestWithProgress().drain<void>();
  }

  /// Ingest added tokens, controlled by a stream.
  ///
  /// The returned stream produces a value on the completion of every batch of
  /// tokens that have been decoded. You can cancel the stream to abort ingestion.
  Stream<IngestProgressEvent> ingestWithProgress() async* {
    checkDisposed();
    try {
      final batchSize = params.n_batch;
      var i = logits.length; // index of the next token to be decoded
      var j = 0; // start batch at zero tokens on every ingest()

      final initialLength = logits.length;
      final finalLength = tokens.length;

      int tokensToDecode() => tokens.length - i;

      _log.info('Ingesting ${tokensToDecode()} tokens');

      while ((i = logits.length) + j < tokens.length) {
        final isLastBatch = tokensToDecode() <= batchSize;
        final fillCount = isLastBatch ? tokensToDecode() : batchSize;

        _batch.n_tokens = fillCount;
        for (j = 0; j < fillCount; j++) {
          _batch.token[j] = tokens[i + j];
          _batch.pos[j] = i + j;
          _batch.n_seq_id[j] = 1;
          _batch.seq_id[j][0] = 1;
          _batch.logits[j] = 1;
        }

        final status = llama_decode(pointer, _batch);
        if (status != 0) {
          throw Exception('llama_decode failed with $status');
        }
        logits.add(llama_get_logits(pointer), _batch.n_tokens);
        yield IngestProgressEvent._(
          i - initialLength + j,
          finalLength,
          batchSize,
        );

        assert(j <= batchSize);
        if (j == batchSize) j = 0;
      }
    } finally {
      _trimKvCache(logits.length);
    }
  }

  /// Generate text where the token candidates are processed in-order by
  /// [samplers].
  ///
  /// A typical sampler list is: ```
  /// samplers: const [
  ///   RepetitionPenalty(lastN: 256, penalty: 1.1),
  ///   TopP(0.95),
  ///   TopK(40),
  ///   Temperature(0.70)
  ///  ]
  /// ```
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

      if (_needsIngesting) {
        throw StateError('must call ingest before generate');
      }

      //
      // Generate tokens to fill context
      //

      while (logits.length < contextSize) {
        _candidates._load(logits.last);

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

        tok ??= const _DefaultLastSampler().sample(this);

        // // ignore: inference_failure_on_instance_creation
        // await Future.delayed(Duration.zero);
        tokens.add(tok!.id);
        _log.finer('generated token: $tok');
        yield tok;

        // Check if end of stream
        if (tok.id == llama_token_eos(model.pointer)) {
          break;
        }

        //
        // Decode next token
        //

        _batch.n_tokens = 1;

        _batch.token[0] = tok.id;
        _batch.pos[0] = logits.length;
        _batch.n_seq_id[0] = 1;
        _batch.seq_id[0][0] = 1;
        _batch.logits[0] = 1;

        final status = llama_decode(pointer, _batch);
        if (status != 0) {
          throw Exception('llama_decode failed with $status');
        }

        logits.add(llama_get_logits(pointer), _batch.n_tokens);
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

/// A token, which represents a piece of text ranging from a single character to
/// a word.
@immutable
final class Token {
  /// The id of the token in the model's vocabulary.
  final int id;

  /// The text this token represents.
  final String text;

  /// The raw text produced by the model for this token.
  ///
  /// Anything that uses e.g. SentencePiece for tokenization represents spaces
  /// with '▁' (U+2581) and sequences like '<0x0A>' to encode '\n'.
  final String rawText;

  const Token._(this.id, this.text, this.rawText);

  factory Token._fromId(Pointer<llama_model> modelPointer, int id) {
    final rawText =
        llama_token_get_text(modelPointer, id).cast<Utf8>().toDartString();
    // replace U+2581 with a space
    final text = rawText.replaceAll('▁', ' ').replaceAll('<0x0A>', '\n');
    return Token._(id, text, rawText);
  }

  /// Construct a string representation of this token.
  ///
  /// Parameter [i] is an optional token index that will be placed at the
  /// beginning of the string.
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
  bool operator ==(Object other) =>
      other is Token && other.id == id && other.rawText == rawText;
  @override
  int get hashCode => id.hashCode + rawText.hashCode;
}
