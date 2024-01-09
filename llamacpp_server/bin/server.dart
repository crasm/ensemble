import 'dart:convert';
import 'dart:io';

import 'package:ensemble_protos/llamacpp.dart' as proto;
import 'package:ensemble_llamacpp/ensemble_llamacpp.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:logging/logging.dart';

class LlamaCppService extends proto.LlamaCppServiceBase with Disposable {
  final _log = Logger('LlmService');

  final Model _model;
  final Context _ctx; // TODO(crasm): support multiple contexts
  LlamaCppService._(this._model, this._ctx);

  static Future<LlamaCppService> create() async {
    final model = LlamaCpp.loadModel(
      '/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf',
      params: Model.defaultParams..n_gpu_layers = 1,
      progressCallback: (p) {
        if (p == 1.0) {
          stderr.writeln('Done!');
        } else {
          stderr.writeAll([(100 * p).truncate(), '\r']);
        }
        return true;
      },
    );

    final ctx = model.newContext(Context.defaultParams..n_ctx = 2048);

    return LlamaCppService._(model, ctx);
  }

  @override
  void dispose() async {
    super.dispose();
    _ctx.dispose();
    _model.dispose();
  }

  @override
  Future<proto.Context> newContext(
      grpc.ServiceCall call, proto.NewContextRequest args) async {
    checkDisposed();
    return proto.Context(
        id: _ctx.hashCode); // TODO(crasm): actually create context
  }

  @override
  Future<proto.Void> freeContext(
      grpc.ServiceCall call, proto.Context ctx) async {
    checkDisposed();
    return proto.Void(); // TODO(crasm): actually free context
  }

  @override
  Future<proto.TokenList> addText(
      grpc.ServiceCall call, proto.AddTextRequest args) async {
    checkDisposed();
    assert(args.context.id == _ctx.hashCode);
    _log.fine('new text: ```\n${args.text}\n```');
    final toks = _ctx.add(args.text).map((e) {
      return proto.Token(id: e.id, text: e.text);
    });
    return proto.TokenList(toks: toks);
  }

  @override
  Future<proto.Void> trim(grpc.ServiceCall call, proto.TrimRequest args) async {
    _log.fine('trim');
    checkDisposed();
    assert(args.context.id == _ctx.hashCode);
    _ctx.trim(args.length);
    return proto.Void();
  }

  @override
  Future<proto.Void> ingest(grpc.ServiceCall call, proto.Context ctx) async {
    assert(ctx.id == _ctx.hashCode); // TODO(crasm): get real context
    await _ctx.ingest();
    return proto.Void();
  }

  @override
  Stream<proto.Token> generate(
      grpc.ServiceCall call, proto.Context context) async* {
    checkDisposed();
    _log.fine('Generate begin');

    final tokStream = _ctx.generate(samplers: [
      RepetitionPenalty(),
      MinP(0.18),
      Temperature(1.0),
    ]).map((tok) => proto.Token(id: tok.id, text: tok.text));

    await for (final tok in tokStream) {
      if (call.isCanceled) {
        _log.info('Client canceled generation');
        return;
      } else {
        stderr.write(tok.text);
        yield tok;
        await Future.delayed(const Duration());
      }
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
