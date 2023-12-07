import 'dart:io';

import 'package:logging/logging.dart';
import 'package:ensemble_llama/llama.dart';

void main() async {
  final disposables = <Disposable>[];
  T add<T extends Disposable>(T d) {
    disposables.add(d);
    return d;
  }

  IOSink? file;
  try {
    file = File('./main.log').openWrite();

    final startTime = DateTime.now();
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((e) {
      final diff = e.time.difference(startTime);
      file?.writeln(
          '${e.level.name}: ${diff.inMilliseconds.toString().padLeft(6, '0')}: ${e.message}');
    });

    final llama = add(Llama(disableGgmlLog: true));

    final model = add((await llama.initModel(
      // "/Users/vczf/llm/models/airoboros-l2-70b-gpt4-1.4.1.Q6_K.gguf",
      "/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf",
      params: ModelParams(gpuLayers: 1, useMmap: false),
      // progressCallback: (p) {
      //   stderr.write('\r');
      //   stderr.write((p * 100).truncate());
      // },
    )));

    final ctx = add(await llama.initContext(
      model,
      params: ContextParams(contextSizeTokens: 256),
    ));

    await ctx.add("A chat.\nUser: How can I make my own peanut butter?\nAssistant:");
    await ctx.ingest();
    final tokStream = ctx.generate(samplers: [
      RepetitionPenalty(lastN: 256, penalty: 1.1),
      Temperature(0.45),
      MirostatV2(),
    ]);

    await for (final tok in tokStream) {
      stdout.write(tok.text);
    }
  } finally {
    for (final d in disposables.reversed) {
      d.dispose();
    }
    await file?.flush();
    file?.close();
    file = null;
  }
}
