import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:ensemble_llama/src/params.dart' show ContextParams;
import 'package:ensemble_llama/llama_ffi.dart';
import 'package:ensemble_llama/src/llama.dart' as pub;

final class Model {
  final pub.Model id;
  final int rawPointer;

  const Model(this.id, this.rawPointer);

  Pointer<llama_model> get pointer =>
      Pointer.fromAddress(rawPointer).cast<llama_model>();

  @override
  String toString() => "Model{$rawPointer}";
}

final class Context {
  final pub.Context id;
  final int rawPointer;
  final Model model;
  final ContextParams params;

  // TODO: does Context really need a reference to model?
  const Context(this.id, this.rawPointer, this.model, this.params);

  Pointer<llama_context> get pointer =>
      Pointer.fromAddress(rawPointer).cast<llama_context>();
}

final class Token {
  final int id;
  final String text;
  final String rawText;

  const Token(this.id, this.text, this.rawText);

  factory Token.fromId(Context ctx, int id) {
    final str =
        llama_token_get_text(ctx.model.pointer, id).cast<Utf8>().toDartString();
    return Token(
      id,
      str
          .replaceAll("▁", " ") // replace U+2581 with a space
          // TODO: is this the right approach here? What about other cases?
          .replaceAll("<0x0A>", "\n"),
      str,
    );
  }

  static pub.Token record(Token tok) => (id: tok.id, text: tok.text);

  @override
  bool operator ==(Object other) => other is Token && other.id == id;

  @override
  int get hashCode => id;

  @override
  String toString() => text;
  String toStringForLogging() => "${id.toString().padLeft(5)} = $rawText\n";
}

// Stores an array of candidate tokens and their logit probabilities.
final class Candidates {
  final int vocabSize;
  int get size => pointer.ref.size;
  late final Pointer<llama_token_data> _candidates;
  late final Pointer<llama_token_data_array> pointer;

  Candidates(this.vocabSize) {
    _candidates = calloc.allocate(vocabSize * sizeOf<llama_token_data>());
    pointer = calloc.allocate(sizeOf<llama_token_data_array>());

    pointer.ref.data = _candidates;
    pointer.ref.size = vocabSize;
    pointer.ref.sorted = false;
  }

  void load(Pointer<Float> logits) {
    pointer.ref.size = vocabSize;
    pointer.ref.sorted = false;

    for (var i = 0; i < size; i++) {
      _candidates[i].id = i;
      _candidates[i].logit = logits[i];
      _candidates[i].p = 0.0;
    }
  }

  double getLogit(int tokId) => _candidates[tokId].logit;
  void setLogit(int tokId, double logit) => _candidates[tokId].logit = logit;

  String toStringContext(Context ctx) {
    final List<llama_token_data> copy = [];
    for (var i = 0; i < size; i++) {
      copy.add(_candidates[i]);
    }
    copy.sort((a, b) => b.logit.compareTo(a.logit));

    final strb = StringBuffer("cands = ");
    for (var i = 0; i < 8; i++) {
      strb.write(Token.fromId(ctx, _candidates[i].id));
      strb.write("=");
      strb.write(_candidates[i].logit.toStringAsFixed(2));
      strb.write(" ");
    }
    strb.write("...");
    return strb.toString();
  }

  void dispose() {
    calloc.free(_candidates);
    calloc.free(pointer);
  }
}

final class TokenBuf {
  int _length;
  int get length => _length;

  final Pointer<Int32> buf;
  final int capacity;
  TokenBuf._(this._length, this.buf, this.capacity);

  int operator [](int index) {
    RangeError.checkValidIndex(index, this);
    return buf[index];
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    buf[index] = value;
  }

  void add(int tokId) {
    assert(length <= capacity);
    if (_length == capacity) {
      throw Exception(
          "tried to store $_length tokens in $capacity token buffer");
    }
    buf[_length++] = tokId;
  }

  String toStringContext(Context ctx) {
    final strb = StringBuffer("buf[0:${length - 1}] = ");
    for (var i = 0; i < length; i++) {
      strb.write(Token.fromId(ctx, buf[i]));
    }
    return strb.toString();
  }

  factory TokenBuf.fromString(Context ctx, String text) {
    final contextSize = ctx.params.contextSizeTokens;
    final model = ctx.model;
    Pointer<Char>? textC;
    try {
      textC = text.toNativeUtf8(allocator: calloc).cast<Char>();
      final buf = calloc.allocate(contextSize * sizeOf<Int32>()).cast<Int32>();

      final numTokens = llama_tokenize(
        model.pointer,
        textC,
        text.length,
        buf,
        contextSize,
        true, // add Beginning-Of-Stream token
        false, // tokenize meta tokens (like BOS/EOS)
      );

      if (numTokens < 0) {
        throw Exception("llama_tokenize failed with $numTokens");
      } else if (numTokens >= contextSize) {
        throw Exception("prompt too large: $numTokens >= $contextSize tokens");
      }

      return TokenBuf._(numTokens, buf, contextSize);
    } finally {
      if (textC != null) calloc.free(textC);
    }
  }

  List<Token> toList(Context ctx) {
    final List<Token> list = [];
    for (var i = 0; i < length; i++) {
      list.add(Token.fromId(ctx, buf[i]));
    }
    return list;
  }

  void dispose() {
    calloc.free(buf);
  }
}
