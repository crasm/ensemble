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

typedef LlamaLogger = Void Function(Int32, Pointer<Char>, Pointer<Void>);

void main() {
  Console.init();
  Console.write("hello, ensemble_llama");

  var params = libllama.llama_context_default_params();
  params.n_gpu_layers = 1;
  params.progress_callback = Pointer.fromFunction(onModelLoadProgress);

  libllama.llama_log_set(
      Pointer.fromFunction(onLlamaLog), Pointer.fromAddress(0));

  libllama.llama_load_model_from_file(
      "/Users/vczf/llm/models/airoboros-l2-70b-2.1.Q5_K_M.gguf"
          .toNativeUtf8()
          .cast<Char>(),
      params);

  Console.write("done!");
}
