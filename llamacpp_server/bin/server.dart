import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:ensemble_protos/llamacpp.dart' as proto;
import 'package:ensemble_llamacpp/ensemble_llamacpp.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:logging/logging.dart';

late final String modelFilePath;

final _noContextFoundException =
    (id) => Exception('no context with id=$id found');

class LlamaCppService extends proto.LlamaCppServiceBase with Disposable {
  final _log = Logger('LlamaCppService');

  final Model _model;
  LlamaCppService._(this._model);

  static Future<LlamaCppService> create() async {
    final _log = Logger('LlamaCppService.create');
    // TODO(crasm): make this a command-line arg
    final model = LlamaCpp.loadModel(
      modelFilePath,
      params: Model.defaultParams..n_gpu_layers = 100000,
      progressCallback: (p) {
        if (p == 1.0) {
          _log.info('Loaded model');
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
    _log.info('Freeing context #${args.ctx}');

    final ctx = _contexts.remove(args.ctx);
    if (ctx == null) throw _noContextFoundException(args.ctx);
    ctx.dispose();
    return proto.Void();
  }

  @override
  Future<proto.AddTextResp> addText(
      grpc.ServiceCall call, proto.AddTextArgs args) async {
    checkDisposed();
    _log.info('Adding text: ```${args.text}```');

    final ctx = _contexts[args.ctx];
    if (ctx == null) throw _noContextFoundException(args.ctx);

    final toks = ctx.add(args.text);
    _log.info(() {
      final buf = StringBuffer('Added ${toks.length} tokens: [\n');
      for (var i = 0; i < toks.length; i++) {
        buf.writeln(toks[i].toString(i));
      }
      buf.write(']');
      return buf.toString();
    });

    return proto.AddTextResp(
      toks: toks.map(
        (e) => proto.Token(
          id: e.id,
          text: e.text,
          rawText: e.rawText,
        ),
      ),
    );
  }

  @override
  Future<proto.Void> trim(grpc.ServiceCall call, proto.TrimArgs args) async {
    checkDisposed();
    _log.info('Trimming to ${args.length} tokens');

    final ctx = _contexts[args.ctx];
    if (ctx == null) throw _noContextFoundException(args.ctx);

    ctx.trim(args.length);
    return proto.Void();
  }

  @override
  Stream<proto.IngestProgressResp> ingest(
      grpc.ServiceCall call, proto.IngestArgs args) {
    checkDisposed();
    _log.info('Ingesting context');

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
    _log.info('Generating started');

    final ctx = _contexts[args.ctx];
    if (ctx == null) throw _noContextFoundException(args.ctx);

    final sl = <Sampler>[];
    for (final s in args.samplers) {
      if (s.hasTemperature()) {
        sl.add(Temperature(s.temperature.temp));
      } else if (s.hasTopK()) {
        sl.add(TopK(s.topK.topK));
      } else if (s.hasTopP()) {
        sl.add(TopP(s.topP.topP));
      } else if (s.hasMinP()) {
        sl.add(MinP(s.minP.minP));
      } else if (s.hasTailFree()) {
        sl.add(TailFree(s.tailFree.z));
      } else if (s.hasLocallyTypical()) {
        sl.add(LocallyTypical(s.locallyTypical.p));
      } else if (s.hasRepetitionPenalty()) {
        sl.add(RepetitionPenalty(
          lastN: s.repetitionPenalty.lastN,
          penalty: s.repetitionPenalty.penalty,
          frequencyPenalty: s.repetitionPenalty.frequencyPenalty,
          presencePenalty: s.repetitionPenalty.presencePenalty,
          penalizeNewline: s.repetitionPenalty.penalizeNewline,
        ));
      } else if (s.hasMirostatV1()) {
        sl.add(MirostatV1(s.mirostatV1.tau, s.mirostatV1.eta));
      } else if (s.hasMirostatV2()) {
        sl.add(MirostatV2(s.mirostatV2.tau, s.mirostatV2.eta));
      } else if (s.hasLogitBias()) {
        sl.add(LogitBias(s.logitBias.bias));
      } else {
        assert(false, 'Invalid sampler received');
      }
    }

    final tokStream = ctx.generate(samplers: sl);
    await for (final tok in tokStream) {
      // Needed so gRPC has a chance to get the call cancellation
      await Future.delayed(const Duration());

      // When the call is canceled on the client using gRPC, one token will be
      // 'wasted' after generation. However, if generation is resumed from this
      // point, this token will only have to be sampled again from the
      // candidates, not decoded.
      if (call.isCanceled) {
        _log.info('Generating canceled by client');
        break;
      }

      _log.fine('Generated token: $tok');
      yield proto.Token(id: tok.id, text: tok.text, rawText: tok.rawText);
    }
  }
}

void main(List<String> args) async {
  final startTime = DateTime.now();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((e) {
    final diff = e.time.difference(startTime);
    stderr.writeln(
      '${e.level.name.padRight(7)}: '
      '${diff.inMilliseconds.toString().padLeft(6, '0')}: '
      '${e.loggerName}: '
      '${e.message}',
    );
  });

  final _log = Logger('main');

  final parser = ArgParser(usageLineLength: 80);
  late final String host;
  late final int port;
  parser.addOption(
    'host',
    help: 'The hostname or IP address to listen on.',
    defaultsTo: 'localhost',
    callback: (a) => host = a!,
  );
  parser.addOption(
    'port',
    help: 'The port to listen on.',
    defaultsTo: '8227',
    callback: (a) => port = int.parse(a!),
  );
  parser.addOption(
    'model',
    help: 'The model file to use for inference.',
    callback: (a) => modelFilePath = a!,
    mandatory: true,
  );

  final argResults = parser.parse(args);
  if (argResults.rest.isNotEmpty) {
    stderr.writeln(parser.usage);
    exit(1);
  }

  final server = grpc.Server.create(services: [await LlamaCppService.create()]);
  await server.serve(address: host, port: port);
  _log.info('listening on $host:$port');
}
