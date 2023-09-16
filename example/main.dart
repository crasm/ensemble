import 'dart:ffi';

import 'package:console/console.dart';
import 'package:ffi/ffi.dart';

import 'package:ensemble_llama/ensemble_llama_cpp.dart';

final _pbar = ProgressBar(complete: 100);
void onModelLoadProgress(double progress, Pointer<Void> ctx) {
  _pbar.update((progress * 100).floor());
}

void onLlamaLog(int level, Pointer<Char> text, Pointer<Void> userData) {
  String msgText = text.cast<Utf8>().toDartString().trimRight();
  print("$level: $msgText");
}

void main() {
  Console.init();
  Console.write("hello, ensemble_llama");

  var params = libllama.llama_context_default_params();
  params.n_gpu_layers = 1;
  params.progress_callback = Pointer.fromFunction(onModelLoadProgress);

  libllama.llama_log_set(
      Pointer.fromFunction(onLlamaLog), Pointer.fromAddress(0));

  var model = libllama.llama_load_model_from_file(
      "/Users/vczf/models/default/ggml-model-f16.gguf"
          .toNativeUtf8()
          .cast<Char>(),
      params);

  var ctx = libllama.llama_new_context_with_model(model, params);

  var maxTokens = 10;
  Pointer<Int> tokens = calloc.allocate(maxTokens * sizeOf<Int>());
  int nTokens = libllama.llama_tokenize(
      ctx, "We".toNativeUtf8().cast<Char>(), tokens, maxTokens, true);

  if (nTokens < 1) throw Exception();

  for (var i = 0; i < nTokens; i++) {
    Pointer<Char> tokPiece = calloc.allocate(10 * sizeOf<Char>());
    int err = libllama.llama_token_to_piece(
        ctx, tokens.elementAt(i).value, tokPiece, 10);
    if (err < 0) throw Exception();
  }

  if (libllama.llama_eval(ctx, tokens, nTokens, 0, 1) != 0) throw Exception();

  Pointer<Float> logits = libllama.llama_get_logits(ctx);
  int nVocab = libllama.llama_n_vocab(ctx);

  Pointer<llama_token_data> data =
      calloc.allocate(nVocab * sizeOf<llama_token_data>());

  for (var i = 0; i < nVocab; i++) {
    data[i].id = i;
    data[i].logit = logits[i];
    data[i].p = 0.0;
  }

  Pointer<llama_token_data_array> candidates =
      calloc.allocate(sizeOf<llama_token_data_array>());

  candidates.ref.data = data;
  candidates.ref.size = nVocab;
  candidates.ref.sorted = false;

  int token = libllama.llama_sample_token_greedy(ctx, candidates);
  Console.write("token: $token\n");
  Pointer<Char> tokenStr = calloc(10);
  var err = libllama.llama_token_to_piece(ctx, token, tokenStr, 10);
  Console.write("sample_token_greedy: $err\n");
  Console.write("first token is: ${tokenStr.cast<Utf8>().toDartString()}\n");

  calloc.free(data);
  calloc.free(candidates);
}
