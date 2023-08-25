import 'package:ensemble_llama/ensemble_llama.dart';

void main() {
  LlamaCpp llama = LlamaCpp();
  print(llama.systemInfo());
}
