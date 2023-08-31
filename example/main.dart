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
      "/Users/vczf/llm/models/airoboros-l2-70b-2.1.Q5_K_M.gguf"
          .toNativeUtf8()
          .cast<Char>(),
      params);

  var ctx = libllama.llama_new_context_with_model(model, params);

  var maxTokens = 10;
  Pointer<Int> tokens = calloc.allocate(maxTokens * sizeOf<Int>());
  int n = libllama.llama_tokenize(
      ctx,
      "My name is Slim Shady ".toNativeUtf8().cast<Char>(),
      tokens,
      maxTokens,
      true);

  if (n < 1) throw Exception();

  for (var i = 0; i < n; i++) {
    Pointer<Char> tokPiece = calloc.allocate(10 * sizeOf<Char>());
    int n2 = libllama.llama_token_to_piece(
        ctx, tokens.elementAt(i).value, tokPiece, 10);
    if (n2 < 0) throw Exception();
    print(tokPiece.cast<Utf8>().toDartString(length: n2));
  }

  // libllama.llama_eval(ctx, tokens, n_tokens, n_past, n_threads)

  Console.write("done!");
}
