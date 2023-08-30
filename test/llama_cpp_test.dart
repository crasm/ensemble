import 'dart:ffi';

import 'package:ensemble_llama/src/llama_cpp_base.dart';
import 'package:test/test.dart' as t;

void mycb(double progress, Pointer<Void> ctx) {
  print(progress);
}

void main() {
  t.group('A group of tests', () {
    t.setUp(() {
      // Additional setup goes here.
    });

    t.test('systemInfo', () {
      String info = systemInfo();
      t.expect(info.substring(0, 3), 'AVX');
    });

    t.test('load model', () {
      LlamaContextParams params = contextDefaultParams();
      params.progress_callback = Pointer.fromFunction(mycb);
      loadModelFromFile(
          "/Users/vczf/models/default/ggml-model-f16.gguf", params);
    });
  });
}
