import 'dart:io';
import 'package:ensemble_llama/llama.dart';

void main(List<String> arguments) async {
  final llama = await Llama.create();
  final model = await llama.loadModel(
      "/Users/vczf/llm/models/airoboros-l2-13b-gpt4-1.4.1.Q4_K_M.gguf",
      params: ModelParams(gpuLayers: 1));
  final ctx = await llama.newContext(model);

  final tokStream = llama.generate(ctx, "My name is", SamplingParams());
  await for (final tok in tokStream) {
    stdout.write(tok.text);
  }

  llama.dispose();
}
