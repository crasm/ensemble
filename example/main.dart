import 'package:ensemble_llama/ensemble_llama.dart' as llama;
import 'package:ensemble_llama/src/ensemble_llama_base.dart' as base;

import 'dart:ffi';
import 'package:ffi/ffi.dart';

void mycb(Float progress, Pointer<Void> ctx) {
  print(progress);
}

void main() {
  var params = llama.contextDefaultParams();
  params.progress_callback = Pointer.fromFunction(mycb);
}
