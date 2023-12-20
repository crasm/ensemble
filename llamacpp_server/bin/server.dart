import 'dart:io';

import 'package:ensemble_common/common.dart' as c;
import 'package:ensemble_llama/llama.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:logging/logging.dart';

class LlmService extends c.LlmServiceBase with Disposable {
  final _log = Logger('LlmService');

  final Llama _llama;
  final Model _model;
  final Context _ctx;
  LlmService._(this._llama, this._model, this._ctx);

  static Future<LlmService> create() async {
    final llama = Llama();
    final model = await llama.initModel(
      '/Users/vczf/llm/models/airoboros-l2-13b-gpt4-1.4.1.Q4_K_M.gguf',
      params: ModelParams(gpuLayers: 1),
    );
    final ctx = await llama.initContext(model, params: ContextParams(contextSizeTokens: 4096));

    return LlmService._(llama, model, ctx);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _ctx.dispose();
    await _model.dispose();
    await _llama.dispose();
  }

  @override
  Stream<c.Token> generate(grpc.ServiceCall call, c.Prompt prompt) async* {
    checkDisposed();
    try {
      await _ctx.add(prompt.text);
      await _ctx.ingest();
      await for (final tok in _ctx.generate(samplers: [
        RepetitionPenalty(),
        MinP(0.18),
        Temperature(1.0),
      ])) {
        final ct = c.Token(id: tok.id, text: tok.text);
        _log.fine('received ${tok.toStringForLogging().trimRight()}');
        yield ct;
      }
    } finally {
      await _ctx.clear();
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
