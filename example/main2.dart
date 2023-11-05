import 'dart:io';

import 'package:ensemble_llama/llama.dart';

void main() async {
  var llama = await Llama.create();
  llama.log.listen((msg) {
    final msgText = msg.toString();
    if (!msgText.contains("llama_model_loader: - tensor")) {
      print(msgText);
    }
  });

  final modelParams = ModelParams(gpuLayers: 1);
  final model = await llama.loadModel(
    "/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf",
    params: modelParams,
    progressCallback: (p) => stdout.write("."),
  );

  print(model);

  final ctxParams = ContextParams(contextSizeTokens: 256);
  final ctx = await llama.newContext(model, ctxParams);

  final tokStream = llama.generate(ctx, "peanut", SamplingParams());
  await for (final tok in tokStream) {
    stdout.write(tok);
  }

  await llama.freeContext(ctx);
  await llama.freeModel(model);
  llama.dispose();
}
