import 'package:ensemble_llama/ensemble_llama.dart';

void main() {
  _LlamaCpp llama = _LlamaCpp();
  print(llama.systemInfo());
}
