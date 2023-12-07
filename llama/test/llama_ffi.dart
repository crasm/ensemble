import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart' as t;

import 'package:ensemble_llama/llama_ffi.dart';

void mycb(double progress, Pointer<Void> ctx) {
  print(progress);
}

void main() {
  t.group('A group of tests', () {
    t.setUp(() {
      // Additional setup goes here.
    });

    t.test('systemInfo', () {
      String info = llama_print_system_info().cast<Utf8>().toDartString();
      t.expect(info.substring(0, 3), 'AVX');
    });
  });
}
