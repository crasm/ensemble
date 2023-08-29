import 'package:ensemble_llama/ensemble_llama.dart';
import 'package:ensemble_llama/src/ensemble_llama_base.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

void mycb(double progress, Pointer<Void> ctx) {
  print(progress);
}

void main() {
  var params = contextDefaultParams();
  params.progress_callback = Pointer.fromFunction(mycb);
  print(params.progress_callback);
  Pointer<NativeFunction<LlamaProgressCallback>> foo = params.progress_callback;
  print(foo);
}
