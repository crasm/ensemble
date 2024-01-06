import 'dart:io';

import 'package:ensemble_llamacpp/ensemble_llamacpp.dart';
import 'package:logging/logging.dart';

final _log = Logger('main');

void main(List<String> args) async {
  Model? model;
  Context? ctx;
  try {
    final startTime = DateTime.now();
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((e) {
      final diff = e.time.difference(startTime);
      stderr.writeln(
        '${e.level.name.padRight(7)}: '
        '${diff.inMilliseconds.toString().padLeft(6, '0')}: '
        '${e.message}',
      );
    });

    model = LlamaCpp.loadModel(
      '/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf',
      params: Model.defaultParams..use_mmap = false,
      progressCallback: (progress) {
        stderr.write('.');
        return true;
      },
    );

    const prompt = 'Four score';
    ctx = model.newContext(
      Context.defaultParams
        ..n_ctx = 256
        ..n_batch = 64,
    );
    ctx.add(prompt);
    await for (final progress in ctx.ingestWithProgress()) {
      _log.fine(progress);
    }

    stdout.write(prompt);
    await for (final tok in ctx.generate(samplers: [
      RepetitionPenalty(),
      MinP(0.2),
      Temperature(1.00),
    ])) {
      stdout.write(tok.text);
    }
  } finally {
    ctx?.dispose();
    model?.dispose();
  }
}
