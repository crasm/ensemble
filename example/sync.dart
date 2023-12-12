import 'dart:io';
import 'package:llamacpp/llamacpp.dart';

void main(List<String> args) async {
  Model? model;
  Context? ctx;
  try {
    model = loadModel(
        '/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf');
    ctx = model.newContext(Context.defaultParams..n_ctx = 128);
    final toks = ctx
        .add('A chat.\nUser: How can I make my own peanut butter?\nAssistant:');
    await ctx.ingest().value;
    for (final tok in toks) {
      stdout.write(tok.text);
    }

    await for (final tok in ctx.generate(samplers: const [
      RepetitionPenalty(),
      MinP(0.10),
      Temperature(1.0),
    ])) {
      stdout.write(tok.text);
    }
  } finally {
    ctx?.dispose();
    model?.dispose();
  }
}
