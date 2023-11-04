import 'dart:io';

import 'package:test/test.dart';

import 'package:ensemble_llama/ensemble_llama.dart';
import 'package:ensemble_llama/src/llama_cpp_isolate_wrapper.dart';

void main() {
  group('A group of tests', () {
    late Llama llama;
    late Model model;
    late Context ctx;
    setUp(() async {
      llama = await Llama.create();
      model = await llama.loadModel(
          "/Users/vczf/models/default/ggml-model-f16.gguf",
          params: ModelParams(gpuLayers: 1));
    });
    tearDown(() async {
      await llama.freeContext(ctx);
      await llama.freeModel(model);
      llama.dispose();
    });

    test('happy path batch and context size', () async {
      ctx = await llama.newContext(
          model, ContextParams(contextSizeTokens: 20, batchSizeTokens: 20));
      final tokStream = llama.generate(
          ctx, "It's the end of the world as we know", SamplingParams());
      await for (final tok in tokStream) {
        print("id: ${tok.id}\t\ttok: $tok");
      }
    });
  });
}
