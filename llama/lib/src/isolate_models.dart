import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:ensemble_llama/llama_ffi.dart';
import 'package:ensemble_llama/src/disposable.dart';
import 'package:ensemble_llama/src/llama.dart' as pub;
import 'package:ensemble_llama/src/params.dart' show ContextParams;

final class Model {
  static pub.Model _nextModel = 1;
  final pub.Model id = _nextModel++;
  final int rawPointer;

  Model(this.rawPointer);

  Pointer<llama_model> get pointer =>
      Pointer.fromAddress(rawPointer).cast<llama_model>();

  @override
  String toString() => "Model{$rawPointer}";
}

final class Context with Disposable {
  static pub.Context _nextContext = 1;
  final pub.Context id = _nextContext++;
  final int rawPointer;
  final Model model;
  final ContextParams params;

  late final TokenBuf tokens;
  late final llama_batch batch;
  late final Candidates candidates;

  int i = 0; // index into context window
  int j = 0; // index into current batch
  int decodeOffset = 0;

  Context(this.rawPointer, this.model, this.params) {
    tokens = TokenBuf.allocate(params.contextSizeTokens);
    batch = llama_batch_init(params.batchSizeTokens, 0, 1);
    candidates = Candidates(llama_n_vocab(model.pointer));
  }

  Pointer<llama_context> get pointer =>
      Pointer.fromAddress(rawPointer).cast<llama_context>();

  @override
  void dispose() {
    super.dispose();
    tokens.dispose();
    llama_batch_free(batch);
    candidates.dispose();
  }
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

  pub.Token get record => (id: id, text: text);

  @override
  bool operator ==(Object other) => other is Token && other.id == id;

  @override
  int get hashCode => id;

  @override
  String toString() => text;
  String toStringForLogging() => "${id.toString().padLeft(5)} = $rawText\n";
}

// Stores an array of candidate tokens and their logit probabilities.
final class Candidates with Disposable {
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
    checkDisposed();
    pointer.ref.size = vocabSize;
    pointer.ref.sorted = false;

    for (var i = 0; i < size; i++) {
      _candidates[i].id = i;
      _candidates[i].logit = logits[i];
      _candidates[i].p = 0.0;
    }
  }

  double getLogit(int tokId) {
    checkDisposed();
    return _candidates[tokId].logit;
  }

  void setLogit(int tokId, double logit) {
    checkDisposed();
    _candidates[tokId].logit = logit;
  }

  String toStringContext(Context ctx) {
    checkDisposed();
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

  @override
  void dispose() {
    super.dispose();
    calloc.free(_candidates);
    calloc.free(pointer);
  }
}

final class TokenBuf with Disposable {
  int _length = 0;
  int get length => _length;

  final Pointer<Int32> buf;
  final int capacity;
  TokenBuf._(this.buf, this.capacity);

  factory TokenBuf.allocate(int size) {
    final buf = calloc.allocate(size * sizeOf<Int32>()).cast<Int32>();
    return TokenBuf._(buf, size);
  }

  int operator [](int index) {
    checkDisposed();
    RangeError.checkValidIndex(index, this);
    return buf[index];
  }

  void operator []=(int index, int value) {
    checkDisposed();
    RangeError.checkValidIndex(index, this);
    buf[index] = value;
  }

  void add(int tokId) {
    checkDisposed();
    assert(length <= capacity);
    if (_length == capacity) {
      throw Exception(
          "tried to store $_length tokens in $capacity token buffer");
    }
    buf[_length++] = tokId;
  }

  /// Tokenizes [text] with the [ctx.model] and returns the number of tokens.
  ///
  /// [addBos] should only be true when tokenizing the initial prompt.
  int addFromString(Context ctx, String text, bool addBos) {
    checkDisposed();
    final int remainingCapacity = capacity - _length;
    Pointer<Utf8>? utf;
    try {
      utf = text.toNativeUtf8(allocator: calloc);
      final numTokens = llama_tokenize(
        ctx.model.pointer,
        utf.cast<Char>(),
        utf.length,
        buf.elementAt(_length),
        remainingCapacity,
        addBos, // add Beginning-Of-Stream token
        false, // tokenize meta tokens (like BOS/EOS)
      );

      if (numTokens < 0) {
        throw Exception("llama_tokenize failed with $numTokens");
      } else if (numTokens >= remainingCapacity) {
        throw Exception("prompt too large: $numTokens >= $remainingCapacity");
      }

      _length += numTokens;
      return numTokens;
    } finally {
      if (utf != null) calloc.free(utf);
    }
  }

  String toStringContext(Context ctx) {
    checkDisposed();
    final strb = StringBuffer("buf[0:${length - 1}] = ");
    for (var i = 0; i < length; i++) {
      strb.write(Token.fromId(ctx, buf[i]));
    }
    return strb.toString();
  }

  /// Returns the [Token]s in this buffer.
  ///
  /// If [lastN] is provided, will return the tokens in the buffer starting
  /// from [length - lastN].
  List<pub.Token> toList(Context ctx, [int? lastN]) {
    checkDisposed();
    lastN ??= _length;
    final List<pub.Token> list = [];
    for (var i = _length - lastN; i < _length; i++) {
      list.add(Token.fromId(ctx, buf[i]).record);
    }
    return list;
  }

  @override
  void dispose() {
    super.dispose();
    calloc.free(buf);
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

      return TokenBuf._(buf, contextSize).._length = numTokens;
    } finally {
      if (textC != null) calloc.free(textC);
    }
  }
}
