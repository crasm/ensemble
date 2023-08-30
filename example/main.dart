import 'dart:ffi';
import 'package:ensemble_llama/llama_cpp.dart';
import 'package:console/console.dart';

final _pbar = ProgressBar(complete: 100);
void onModelLoadProgress(double progress, Pointer<Void> ctx) {
  _pbar.update((progress * 100).floor());
}

void main() {
  Console.init();
  Console.write("hello, ensemble_llama");

  LlamaContextParams params = contextDefaultParams();
  params.n_ctx = 8192;
  params.n_gpu_layers = 1;
  params.rope_freq_scale = 0.5;
  params.progress_callback = Pointer.fromFunction(onModelLoadProgress);
  params.use_mmap = false;
  loadModelFromFile(
      "/Users/vczf/llm/models/airoboros-l2-70b-2.1.Q5_K_M.gguf", params);

  Console.write("done!");
}
