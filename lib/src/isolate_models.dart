import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:logging/logging.dart';

import 'package:ensemble_llama/llama_ffi.dart';
import 'package:ensemble_llama/src/common.dart';
import 'package:ensemble_llama/src/disposable.dart';
import 'package:ensemble_llama/src/llama.dart' as pub;
import 'package:ensemble_llama/src/params.dart' show ContextParams;

final class Model {
  static int _nextId = 1;
  final int id = _nextId++;
  final int rawPointer;

  Model(this.rawPointer);

  Pointer<llama_model> get pointer => Pointer.fromAddress(rawPointer).cast<llama_model>();

  @override
  String toString() => 'Model#$id';
}

final class Context with Disposable {
  static int _nextId = 1;
  final int id = _nextId++;
  final int rawPointer;
  final Model model;
  final ContextParams params;

  Context(this.rawPointer, this.model, this.params) {
    final vocabSize = llama_n_vocab(model.pointer);
    tokens = TokenBuf.allocate(params.contextSizeTokens);
    logits = Logits(params.contextSizeTokens, vocabSize);
    candidates = Candidates(vocabSize);
    batch = llama_batch_init(params.batchSizeTokens, 0, 1);
  }

  late final TokenBuf tokens;
  late final Logits logits;
  late final Candidates candidates;
  late final llama_batch batch;

  bool get needsIngesting => logits.length < tokens.length;

  Pointer<llama_context> get pointer => Pointer.fromAddress(rawPointer).cast<llama_context>();

  @override
  void dispose() {
    super.dispose();
    tokens.dispose();
    logits.dispose();
    candidates.dispose();
    llama_batch_free(batch);
  }

  pub.Token tokenFromId(int id) {
    final str = llama_token_get_text(model.pointer, id).cast<Utf8>().toDartString();
    return pub.Token(
      id,
      str
          .replaceAll('▁', ' ') // replace U+2581 with a space
          // TODO(crasm): is this the right approach here? What about other cases?
          .replaceAll('<0x0A>', '\n'),
      str,
    );
  }

  @override
  String toString() => 'Context#$id';
}

final class TokenBuf with Disposable {
  TokenBuf._(this.buf, this.capacity);
  factory TokenBuf.allocate(int size) {
    final buf = calloc.allocate(size * sizeOf<Int32>()).cast<Int32>();
    return TokenBuf._(buf, size);
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
        throw Exception('llama_tokenize failed with $numTokens');
      } else if (numTokens >= contextSize) {
        throw Exception('prompt too large: $numTokens >= $contextSize tokens');
      }

      return TokenBuf._(buf, contextSize).._length = numTokens;
    } finally {
      if (textC != null) {
        calloc.free(textC);
      }
    }
  }

  static final _log = Logger('TokenBuf');

  int _length = 0;
  int get length => _length;
  bool get isEmpty => _length == 0;

  set length(int value) {
    checkDisposed();
    value.checkIncInc(0, capacity, 'length');
    _length = value;
  }

  final Pointer<Int32> buf;
  final int capacity;
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
      throw Exception('tried to store $_length tokens in $capacity token buffer');
    }
    buf[_length++] = tokId;
  }

  /// Tokenizes [text], adds them to this [TokenBuf], and returns the number of
  /// tokens.
  ///
  /// Does not modify [ctx].
  int addFromString(Context ctx, String text) {
    checkDisposed();
    final remainingCapacity = capacity - _length;
    Pointer<Utf8>? utf;
    try {
      utf = text.toNativeUtf8(allocator: calloc);

      final addBos = isEmpty;
      final numTokens = llama_tokenize(
        ctx.model.pointer,
        utf.cast<Char>(),
        utf.length,
        buf.elementAt(_length),
        remainingCapacity,
        addBos, // add Beginning-Of-Stream token
        false, // tokenize meta tokens (like BOS/EOS)
      );

      if (addBos) _log.fine(() => 'Added BOS token to $ctx');

      if (numTokens < 0) {
        throw Exception('llama_tokenize failed with $numTokens');
      } else if (numTokens >= remainingCapacity) {
        throw Exception('prompt too large: $numTokens >= $remainingCapacity');
      }

      _length += numTokens;
      return numTokens;
    } finally {
      if (utf != null) calloc.free(utf);
    }
  }

  String toStringContext(Context ctx) {
    checkDisposed();
    final strb = StringBuffer('buf[0:${length - 1}] = ');
    for (var i = 0; i < length; i++) {
      strb.write(ctx.tokenFromId(buf[i]));
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
    final list = <pub.Token>[];
    for (var i = _length - lastN; i < _length; i++) {
      list.add(ctx.tokenFromId(buf[i]));
    }
    return list;
  }

  @override
  void dispose() {
    super.dispose();
    calloc.free(buf);
  }
}

/// Stores the log-odds at each index in the context window. The values are
/// unmodifiable, but you can set the [length] to trim excess context and [add]
/// logits produced from a batch decode.
final class Logits with Disposable {
  static final _log = Logger('Logits');

  final int contextSize;
  final int vocabSize;

  int _length = 0;
  int get length => _length;

  set length(int value) {
    checkDisposed();
    value.checkIncInc(0, contextSize, 'length');
    _length = value;
  }

  Pointer<Float> get last => this[length - 1];

  late final Pointer<Float> _logits;

  Logits(this.contextSize, this.vocabSize) {
    final bytes = contextSize * vocabSize * sizeOf<Float>();
    _log.info('Allocating ${bytes >> 20}MiB for logits');
    _logits = calloc.allocate(bytes);
  }

  Pointer<Float> operator [](int tokenIndex) {
    checkDisposed();
    tokenIndex.checkIncInc(0, length, 'tokenIndex');
    return _logits.elementAt(vocabSize * tokenIndex);
  }

  void add(Pointer<Float> batchLogits, int batchSize) {
    checkDisposed();
    (batchSize + length).checkIncInc(0, contextSize, 'batchSize+length');
    for (var i = 0; i < vocabSize * batchSize; i++) {
      _logits.elementAt(vocabSize * length + i).value = batchLogits.elementAt(i).value;
    }

    _length += batchSize;
  }

  @override
  void dispose() {
    super.dispose();
    _length = -1;
    calloc.free(_logits);
  }
}

/// Wrapper for token generation candidates.
///
/// For every possible next token (the size of the model's vocabulary),
/// [Candidates] stores the log-odds (logits) for the likelihood of that token
/// to be the next generated token.
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

  double operator [](int tokId) {
    checkDisposed();
    return _candidates[tokId].logit;
  }

  void operator []=(int tokId, double logit) {
    checkDisposed();
    _candidates[tokId].logit = logit;
  }

  String toStringContext(Context ctx) {
    checkDisposed();
    final copy = <llama_token_data>[];
    for (var i = 0; i < size; i++) {
      copy.add(_candidates[i]);
    }
    copy.sort((a, b) => b.logit.compareTo(a.logit));

    final strb = StringBuffer('cands = ');
    for (var i = 0; i < 8; i++) {
      strb.write(ctx.tokenFromId(_candidates[i].id));
      strb.write('=');
      strb.write(_candidates[i].logit.toStringAsFixed(2));
      strb.write(' ');
    }
    strb.write('...');
    return strb.toString();
  }

  @override
  void dispose() {
    super.dispose();
    calloc.free(_candidates);
    calloc.free(pointer);
  }
}
