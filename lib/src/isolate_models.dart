import 'dart:ffi';
import 'package:llamacpp/src/sampling.dart';

import 'package:llamacpp/llamacpp_ffi.dart';
import 'package:llamacpp/src/disposable.dart';

final class Model {
  static int _nextId = 1;
  final int id = _nextId++;
  final int rawPointer;

  Model(this.rawPointer);

  Pointer<llama_model> get pointer =>
      Pointer.fromAddress(rawPointer).cast<llama_model>();

  @override
  String toString() => 'Model#$id';
}

final class Context with Disposable {
  static int _nextId = 1;
  final int id = _nextId++;
  final int rawPointer;
  final Model model;
  final llama_context_params params;

  Context(this.rawPointer, this.model, this.params) {
    final vocabSize = llama_n_vocab(model.pointer);
    tokens = TokenBuf.allocate(params.n_ctx);
    logits = Logits(params.n_ctx, vocabSize);
    candidates = Candidates(vocabSize);
    batch = llama_batch_init(params.n_batch, 0, 1);
  }

  late final TokenBuf tokens;
  late final Logits logits;
  late final Candidates candidates;
  late final llama_batch batch;

  bool get needsIngesting => logits.length < tokens.length;

  Pointer<llama_context> get pointer =>
      Pointer.fromAddress(rawPointer).cast<llama_context>();

  @override
  void dispose() {
    super.dispose();
    tokens.dispose();
    logits.dispose();
    candidates.dispose();
    llama_batch_free(batch);
  }

  @override
  String toString() => 'Context#$id';
}
