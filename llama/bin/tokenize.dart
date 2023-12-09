import 'package:ensemble_llama/llama.dart';
import 'package:ensemble_llama/src/common.dart';

import 'dart:io';

Future<void> _tokenize(String text) async {
  final disposables = <Disposable>[];
  try {
    final llama = Llama();
    disposables.add(llama);

    final model = await llama.initModel(
      '/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf',
    );
    disposables.add(model);

    final ctx = await llama.initContext(model);
    disposables.add(ctx);

    final tokens = await ctx.add(text);
    for (var i = 0; i < tokens.length; i++) {
      stdout.writeln(tokens[i].toLogString(i));
    }
  } finally {
    for (final d in disposables.reversed) {
      d.dispose();
    }
  }
}

void main(List<String> args) async {
  await _tokenize(args[0]);
}
