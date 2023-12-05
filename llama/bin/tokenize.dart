import 'package:ensemble_llama/llama.dart';
import 'package:ensemble_llama/src/common.dart';

import 'dart:io';

void _tokenize(String text) async {
  Llama? llama;
  Model? model;
  Context? ctx;
  try {
    llama = await Llama.create();
    model = await llama.loadModel(
        "/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf");
    ctx = await llama.newContext(model);
    final tokens = await llama.tokenize(ctx, text);
    for (var i = 0; i < tokens.length; i++) {
      stdout.writeln(tokens[i].toLogString(i));
    }
  } finally {
    if (ctx != null) llama?.freeContext(ctx);
    if (model != null) llama?.freeModel(model);
    llama?.dispose();
  }
}

void main(List<String> args) {
  _tokenize(args[0]);
}
