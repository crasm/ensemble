import 'dart:ffi';

import 'dart:io' show Directory;
import 'package:ensemble_llama/ensemble_llama_cpp.dart';
import 'package:test/test.dart' as t;
import 'package:path/path.dart' as path;
import 'package:ffi/ffi.dart';

void mycb(double progress, Pointer<Void> ctx) {
  print(progress);
}

void main() {
  t.group('A group of tests', () {
    t.setUp(() {
      // Additional setup goes here.
    });

    t.test('systemInfo', () {
      String info =
          libllama.llama_print_system_info().cast<Utf8>().toDartString();
      t.expect(info.substring(0, 3), 'AVX');
    });

    t.test('load model', () {
      var params = libllama.llama_context_default_params();
      params.progress_callback = Pointer.fromFunction(mycb);

      libllama.llama_load_model_from_file(
          "/Users/vczf/models/default/ggml-model-f16.gguf"
              .toNativeUtf8()
              .cast<Char>(),
          params);
    });
  });
}
