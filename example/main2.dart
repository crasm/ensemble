import 'dart:io';

import 'package:ensemble_llama/ensemble_llama.dart';

void main() async {
  var llama = await Llama.create();
  llama.log.listen((msg) {
    final msgText = msg.toString();
    if (!msgText.contains("llama_model_loader: - tensor")) {
      print(msgText);
    }
  });

  final params = ContextParams(gpuLayers: 1, useMmap: false);
  final model = await llama.loadModel(
    "/Users/vczf/models/default/ggml-model-f16.gguf",
    params: params,
    progressCallback: (p) => stdout.write("."),
  );

  print(model);

  final ctx = await llama.newContext(model, params);
  await llama.freeContext(ctx);

  await llama.freeModel(model);
  llama.dispose();
}