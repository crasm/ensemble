import 'dart:io';

import 'package:llamacpp/llamacpp.dart';

void main() async {
  final genStream = LlamaCpp.generate(
    modelPath:
        '/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf',
    prompt: 'A chat.\nUser: How can I make my own peanut butter?\nAssistant:',
    onModelLoadProgress: (p) {
      stderr.write('\r');
      stderr.write((p * 100).truncate());
    },
    modelParams: Model.defaultParams..use_mmap = false,
    contextParams: Context.defaultParams..n_ctx = 256,
    samplers: const [
      RepetitionPenalty(lastN: -1, penalty: 1.1),
      MinP(0.15),
      Temperature(1.0),
    ],
  );

  await for (final event in genStream) {
    final (progress, token) = event;
    if (progress != null) {
      stderr.writeln(progress);
    } else if (token != null) {
      stdout.write(token.text);
    }
  }
}
