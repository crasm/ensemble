import 'dart:async';
import 'dart:io';

import 'package:ensemble_protos/llamacpp.dart' as proto;
import 'package:ensemble_llamacpp/ensemble_llamacpp.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:logging/logging.dart';

final _noContextFoundException =
    (id) => Exception('no context with id=$id found');

class LlamaCppService extends proto.LlamaCppServiceBase with Disposable {
  final _log = Logger('LlmService');

  final Model _model;
  LlamaCppService._(this._model);

  static Future<LlamaCppService> create() async {
    final model = LlamaCpp.loadModel(
      // '/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf',
      '/Users/vczf/llm/models/airoboros-l2-70b-gpt4-1.4.1.Q6_K.gguf',
      params: Model.defaultParams..n_gpu_layers = 1,
      // ..use_mmap = false,
      progressCallback: (p) {
        if (p == 1.0) {
          stderr.writeln('Done!');
        } else {
          stderr.writeAll([(100 * p).truncate(), '\r']);
        }
        return true;
      },
    );

    return LlamaCppService._(model);
  }

  @override
  void dispose() async {
    super.dispose();
    _contexts.forEach((_, ctx) => ctx.dispose());
    _model.dispose();
  }

  Map<int, Context> _contexts = {};

  @override
  Future<proto.NewContextResp> newContext(
      grpc.ServiceCall call, proto.NewContextArgs args) async {
    checkDisposed();
    final p = Context.defaultParams;
    if (args.hasSeed()) p.seed = args.seed;
    if (args.hasNCtx()) p.n_ctx = args.nCtx;
    if (args.hasNBatch()) p.n_batch = args.nBatch;
    if (args.hasNThreads()) p.n_threads = args.nThreads;
    if (args.hasNThreadsBatch()) p.n_threads_batch = args.nThreadsBatch;
    if (args.hasRopeScalingType()) p.rope_scaling_type = args.ropeScalingType;
    if (args.hasRopeFreqBase()) p.rope_freq_base = args.ropeFreqBase;
    if (args.hasRopeFreqScale()) p.rope_freq_scale = args.ropeFreqScale;
    if (args.hasYarnExtFactor()) p.yarn_ext_factor = args.yarnExtFactor;
    if (args.hasYarnAttnFactor()) p.yarn_attn_factor = args.yarnAttnFactor;
    if (args.hasYarnBetaFast()) p.yarn_beta_fast = args.yarnBetaFast;
    if (args.hasYarnBetaSlow()) p.yarn_beta_slow = args.yarnBetaSlow;
    if (args.hasYarnOrigCtx()) p.yarn_orig_ctx = args.yarnOrigCtx;
    if (args.hasTypeK()) p.type_k = args.typeK;
    if (args.hasTypeV()) p.type_v = args.typeV;
    if (args.hasEmbedding()) p.embedding = args.embedding;
    if (args.hasOffloadKqv()) p.offload_kqv = args.offloadKqv;
    final ctx = _model.newContext(p);
    _contexts[ctx.id] = ctx;
    return proto.NewContextResp(ctx: ctx.id);
  }

  @override
  Future<proto.Void> freeContext(
      grpc.ServiceCall call, proto.FreeContextArgs args) async {
    checkDisposed();
    final ctx = _contexts.remove(args.ctx);
    if (ctx == null) throw _noContextFoundException(args.ctx);
    ctx.dispose();
    return proto.Void();
  }

  @override
  Future<proto.AddTextResp> addText(
      grpc.ServiceCall call, proto.AddTextArgs args) async {
    checkDisposed();

    final ctx = _contexts[args.ctx];
    if (ctx == null) throw _noContextFoundException(args.ctx);

    _log.fine('new text: ```\n${args.text}\n```');
    final toks = ctx.add(args.text).map((e) {
      return proto.Token(id: e.id, text: e.text);
    });
    return proto.AddTextResp(toks: toks);
  }

  @override
  Future<proto.Void> trim(grpc.ServiceCall call, proto.TrimArgs args) async {
    _log.fine('trim');
    checkDisposed();

    final ctx = _contexts[args.ctx];
    if (ctx == null) throw _noContextFoundException(args.ctx);

    ctx.trim(args.length);
    return proto.Void();
  }

  @override
  Stream<proto.IngestProgressResp> ingest(
      grpc.ServiceCall call, proto.IngestArgs args) {
    final ctx = _contexts[args.ctx];
    if (ctx == null) throw _noContextFoundException(args.ctx);
    return ctx.ingestWithProgress().map((a) {
      return proto.IngestProgressResp(
        done: a.done,
        total: a.total,
        batchSize: a.batchSize,
      );
    });
  }

  @override
  Stream<proto.Token> generate(
      grpc.ServiceCall call, proto.GenerateArgs args) async* {
    checkDisposed();
    _log.fine('Generate begin');

    final ctx = _contexts[args.ctx];
    if (ctx == null) throw _noContextFoundException(args.ctx);

    final tokStream = ctx.generate(samplers: [
      RepetitionPenalty(),
      MinP(0.18),
      Temperature(1.0),
    ]).map((tok) => proto.Token(id: tok.id, text: tok.text));

    await for (final proto.Token tok in tokStream) {
      // Needed so gRPC has a chance to get the call cancellation
      await Future.delayed(const Duration());

      // When the call is canceled on the client using gRPC, one token will be
      // 'wasted' after generation. However, if generation is resumed from this
      // point, this token will only have to be sampled again from the
      // candidates, not decoded.
      if (call.isCanceled) {
        _log.info('Client canceled generation');
        break;
      }

      yield tok;
    }
  }
}

void main(List<String> arguments) async {
  final startTime = DateTime.now();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((e) {
    final diff = e.time.difference(startTime);
    stderr.writeln(
      '${e.level.name.padRight(7)}: '
      '${diff.inMilliseconds.toString().padLeft(6, '0')}: '
      '${e.message}',
    );
  });

  final server = grpc.Server.create(services: [await LlamaCppService.create()]);
  await server.serve(address: 'brick', port: 8888);
  print('Server listening on port ${server.port}');
}
