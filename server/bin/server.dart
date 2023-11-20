import 'package:ensemble_common/common.dart' as c;
import 'package:ensemble_llama/llama.dart';
import 'package:grpc/grpc.dart' as grpc;

class LlmService extends c.LlmServiceBase {
  final Llama llama;
  final Model model;
  LlmService._(this.llama, this.model);

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
      final ctx =
          await llama.newContext(model, ContextParams(contextSizeTokens: 10));
      await for (final tok
          in llama.generate(ctx, prompt.text, SamplingParams())) {
        final ct = c.Token(id: tok.id, text: tok.text);
        yield ct;
      }
    } finally {
      // ignore: unnecessary_null_comparison
      if (ctx != null) llama.freeContext(ctx);
    }
  }
}

void main(List<String> arguments) async {
  final server = grpc.Server.create(services: [await LlmService.create()]);
  await server.serve(port: 9090);
  print('Server listening on port ${server.port}');
}
