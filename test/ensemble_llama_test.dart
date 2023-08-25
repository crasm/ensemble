import 'package:ensemble_llama/ensemble_llama.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final llamaCpp = LlamaCpp();

    setUp(() {
      // Additional setup goes here.
    });

    test('systemInfo', () {
      String info = llamaCpp.systemInfo();
      expect(info.substring(0, 3), 'AVX');
    });
  });
}
