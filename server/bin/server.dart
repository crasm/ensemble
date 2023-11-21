import 'dart:io';

import 'package:ensemble_common/common.dart' as c;
import 'package:ensemble_llama/llama.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:logging/logging.dart';

class LlmService extends c.LlmServiceBase {
  final _log = Logger('LlmService');

  final Llama _llama;
  final Model _model;
  LlmService._(this._llama, this._model);

  static Future<LlmService> create() async {
    final llama = await Llama.create();
    final model = await llama.loadModel(
        "/Users/vczf/llm/models/airoboros-l2-13b-gpt4-1.4.1.Q4_K_M.gguf",
        params: ModelParams(gpuLayers: 1));

    return LlmService._(llama, model);
  }

  @override
  Stream<c.Token> generate(grpc.ServiceCall call, c.Prompt prompt) async* {
    Context? ctx;
    try {
      final ctx = await _llama.newContext(_model);
      await for (final tok in _llama.generate(ctx, prompt.text,
          params: SamplingParams(
            minP: 0.18,
            repeatPenalty: 1.1,
            repeatPenaltyLastN: -1,
          ))) {
        final ct = c.Token(id: tok.id, text: tok.text);
        stderr.write(tok.text);
        // _log.fine(tok.toStringForLogging());
        yield ct;
      }
    } finally {
      // ignore: unnecessary_null_comparison
      if (ctx != null) _llama.freeContext(ctx);
    }
  }
}

void main(List<String> arguments) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) {
    stderr.writeln("${r.level.name}: ${r.time}: ${r.message}");
  });
  final server = grpc.Server.create(services: [await LlmService.create()]);
  await server.serve(
    // address: 'brick',
    port: 8888,
  );
  print('Server listening on port ${server.port}');
}
