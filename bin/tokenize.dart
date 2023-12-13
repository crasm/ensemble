import 'dart:io';

import 'package:llamacpp/llamacpp.dart';

Future<void> _tokenize(String text) async {
  Model? model;
  Context? ctx;
  try {
    model = LlamaCpp.loadModel(
      '/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf',
    );
    ctx = model.newContext();

    final tokens = ctx.add(text);
    for (var i = 0; i < tokens.length; i++) {
      stdout.writeln(tokens[i].toString(i));
    }
  } finally {
    ctx?.dispose();
    model?.dispose();
  }
}

void main(List<String> args) async {
  await _tokenize(args[0]);
}
