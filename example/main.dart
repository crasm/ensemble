import 'dart:ffi';

import 'package:ensemble_llama/ensemble_llama_cpp.dart';
import 'package:ffi/ffi.dart';
import 'package:console/console.dart';

final _pbar = ProgressBar(complete: 100);
void onModelLoadProgress(double progress, Pointer<Void> ctx) {
  _pbar.update((progress * 100).floor());
}

void main() {
  Console.init();
  Console.write("hello, ensemble_llama");

  var params = libllama.llama_context_default_params();
  params.n_ctx = 8192;
  params.n_gpu_layers = 1;
  params.rope_freq_scale = 0.5;
  params.progress_callback = Pointer.fromFunction(onModelLoadProgress);
  params.use_mmap = false;

  libllama.llama_load_model_from_file(
      "/Users/vczf/llm/models/airoboros-l2-70b-2.1.Q5_K_M.gguf"
          .toNativeUtf8()
          .cast<Char>(),
      params);

  Console.write("done!");
}
