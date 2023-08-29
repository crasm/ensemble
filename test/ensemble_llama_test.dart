import 'package:ensemble_llama/ensemble_llama.dart' as llama;
import 'package:ensemble_llama/src/ensemble_llama_base.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('systemInfo', () {
      String info = llama.systemInfo();
      expect(info.substring(0, 3), 'AVX');
    });

    test('load model', () {
      var llama7b = LlamaCppModel(
          ggufModelFilePath: '~/models/default/ggml-model-f16.gguf',
          contextWindowSize: 2048,
          gpuLayers: 1);
    });
  });
}
