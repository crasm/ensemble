import 'dart:ffi';
import 'package:async/async.dart';
import 'package:ffi/ffi.dart';
import 'package:llamacpp/llamacpp_ffi.dart';
import 'package:llamacpp/src/sampling.dart';
import 'package:llamacpp/src/disposable.dart';
import 'package:llamacpp/src/llama.dart';
import 'package:llamacpp/src/samplers.dart';
import 'package:logging/logging.dart';

// TODO(crasm): document how to use progress callback
Model loadModel(String path, {llama_model_params? params}) {
  final utf = path.toNativeUtf8(allocator: calloc).cast<Char>();
  final model = llama_load_model_from_file(utf, params ?? Model.defaultParams);
  calloc.free(utf);
  return Model(model);
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
        ingest();
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
