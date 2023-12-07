import 'dart:io';

import 'package:ensemble_llama/llama.dart';

void main() async {
  final llama = Llama();
  final tokStream = llama.generateFromPrompt(
    modelPath: "/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf",
    prompt: "A chat.\nUser: How can I make my own peanut butter?\nAssistant:",
    progressCallback: (p) {
      stderr.write('\r');
      stderr.write((p * 100).truncate());
    },
    modelParams: ModelParams(gpuLayers: 1, useMmap: false),
    contextParams: ContextParams(contextSizeTokens: 256),
    samplers: [
      RepetitionPenalty(lastN: 256, penalty: 1.1),
      Temperature(0.45),
      MirostatV2(),
    ],
  );

  await for (final tok in tokStream) {
    stdout.write(tok.text);
  }

  llama.dispose();
}
