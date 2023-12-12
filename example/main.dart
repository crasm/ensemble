import 'dart:io';

import 'package:logging/logging.dart';
import 'package:llamacpp/llamacpp.dart';

void main() async {
  final disposables = <Disposable>[];
  T add<T extends Disposable>(T d) {
    disposables.add(d);
    return d;
  }

  var isClosing = false;
  IOSink? file;
  try {
    file = File('./main.log').openWrite();

    final startTime = DateTime.now();
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((e) {
      if (!isClosing) {
        final diff = e.time.difference(startTime);
        file?.writeln(
          '${e.level.name.padRight(7)}: '
          '${diff.inMilliseconds.toString().padLeft(6, '0')}: '
          '${e.message}',
        );
      }
    });

    final llama = add(Llama(disableGgmlLog: true));

    final model = add(await llama.initModel(
      '/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf',
      params: Model.params..n_gpu_layers = 0,
    ));

    final ctx = add(await llama.initContext(
      model,
      params: Context.params
        ..n_ctx = 128
        ..n_batch = 1,
    ));

    await ctx
        .add('A chat.\nUser: How can I make my own peanut butter?\nAssistant:');
    await ctx.ingest();
    final tokStream = ctx.generate(samplers: [const Temperature(0.0)]);

    await for (final tok in tokStream) {
      stdout.write(tok.text);
    }
  } finally {
    for (final d in disposables.reversed) {
      d.dispose();
    }
    isClosing = true;
    await file?.flush();
    await file?.close();
  }
}
