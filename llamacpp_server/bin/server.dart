import 'dart:io';

import 'package:ensemble_protos/llamacpp.dart' as proto;
import 'package:ensemble_llamacpp/ensemble_llamacpp.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:logging/logging.dart';

class LlmService extends proto.LlamaCppServiceBase with Disposable {
  // final _log = Logger('LlmService');

  final Model _model;
  final Context _ctx;
  LlmService._(this._model, this._ctx);

  static Future<LlmService> create() async {
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

    return LlmService._(model, ctx);
  }

  @override
  void dispose() async {
    super.dispose();
    _ctx.dispose();
    _model.dispose();
  }

  @override
  Stream<proto.Token> generate(
      grpc.ServiceCall call, proto.Prompt prompt) async* {
    checkDisposed();
    try {
      _ctx.add(prompt.text);
      await _ctx.ingest();
      await for (final tok in _ctx.generate(samplers: [
        // RepetitionPenalty(),
        MinP(0.18),
        Temperature(1.0),
      ])) {
        yield proto.Token(id: tok.id, text: tok.text);
      }
    } finally {
      _ctx.clear();
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

  final server = grpc.Server.create(services: [await LlmService.create()]);
  await server.serve(
    address: 'brick',
    port: 8888,
  );
  print('Server listening on port ${server.port}');
}
