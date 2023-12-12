import 'package:ffi/ffi.dart';
import 'package:test/test.dart' as t;

import 'package:llamacpp/llamacpp_ffi.dart';

void main() {
  t.group('A group of tests', () {
    t.setUp(() {
      // Additional setup goes here.
    });

    t.test('systemInfo', () {
      final info = llama_print_system_info().cast<Utf8>().toDartString();
      t.expect(info.substring(0, 3), 'AVX');
    });
  });
}
