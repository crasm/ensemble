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

  var modelParams = libllama.llama_model_default_params();
  modelParams.n_gpu_layers = 1;
  modelParams.progress_callback = Pointer.fromFunction(onModelLoadProgress);

  libllama.llama_log_set(
      Pointer.fromFunction(onLlamaLog), Pointer.fromAddress(0));

  var model = libllama.llama_load_model_from_file(
      "/Users/vczf/models/default/ggml-model-f16.gguf"
          .toNativeUtf8()
          .cast<Char>(),
      modelParams);

  var ctxParams = libllama.llama_context_default_params();
  var ctx = libllama.llama_new_context_with_model(model, ctxParams);

  var maxTokens = 10;
  Pointer<Int32> tokens = calloc.allocate(maxTokens * sizeOf<Int32>());
  int numTokenized = libllama.llama_tokenize(
    model,
    "We".toNativeUtf8().cast<Char>(),
    "We".length,
    tokens,
    maxTokens,
    true,
  );

  if (numTokenized < 1) throw Exception();

  var batch = libllama.llama_batch_init(10, 0);
  batch.n_tokens = numTokenized;
  for (var i = 0; i < numTokenized; i++) {
    print("prompt token: ${tokens[i]}");

    batch.token[i] = tokens[i];
    batch.pos[i] = i;
    batch.seq_id[i] = 0;
    batch.logits[i] = 0; // = false;
  }

  batch.logits[batch.n_tokens - 1] = 1; // = true;

  if (libllama.llama_decode(ctx, batch) != 0) throw Exception();
  //TODO

  int nVocab = libllama.llama_n_vocab(model);
  Pointer<Float> logits = libllama.llama_get_logits_ith(ctx, numTokenized - 1);

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
  var err = libllama.llama_token_to_piece(model, token, tokenStr, 10);
  Console.write("sample_token_greedy: $err\n");
  Console.write("first token is: ${tokenStr.cast<Utf8>().toDartString()}\n");

  libllama.llama_batch_free(batch);

  calloc.free(data);
  calloc.free(candidates);
}
