import 'dart:io';

import 'package:logging/logging.dart';
import 'package:ensemble_llama/llama.dart';

void main() async {
  IOSink? file;
  Llama? llama;
  Model? model;
  Context? ctx;
  try {
    file = File('./main.log').openWrite();

    final startTime = DateTime.now();
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((e) {
      final diff = e.time.difference(startTime);
      file?.writeln(
          '${e.level.name}: ${diff.inMilliseconds.toString().padLeft(6, '0')}: ${e.message}');
    });

    llama = await Llama.create(disableGgmlLog: true);

    final modelParams = ModelParams(gpuLayers: 1, useMmap: false);
    model = await llama.loadModel(
      // "/Users/vczf/llm/models/airoboros-l2-70b-gpt4-1.4.1.Q6_K.gguf",
      "/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf",
      params: modelParams,
      // progressCallback: (p) {
      //   stderr.write('\r');
      //   stderr.write((p * 100).truncate());
      // },
    );

    final ctxParams = ContextParams(contextSizeTokens: 256);
    ctx = await llama.newContext(model, params: ctxParams);

    final tokStream = llama.generate(
      ctx,
      prompt: "A chat.\nUser: How can I make my own peanut butter?\nAssistant:",
      samplers: [
        RepetitionPenalty(lastN: 256, penalty: 1.1),
        Temperature(0.45),
        MirostatV2(),
      ],
    );

    await for (final tok in tokStream) {
      stdout.write(tok.text);
    }
  } finally {
    if (ctx != null) await llama?.freeContext(ctx);
    if (model != null) await llama?.freeModel(model);
    llama?.dispose();
    await file?.flush();
    file?.close();
    file = null;
  }
}
