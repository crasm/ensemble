part of 'llamacpp.dart';

/// Stores the token IDs for each token of a context window.
final class ContextTokens with Disposable {
  static final _log = Logger('ContextTokens');

  int _length = 0;

  /// The number of stored tokens.
  int get length => _length;
  // ignore: public_member_api_docs
  bool get isEmpty => _length == 0;

  set length(int value) {
    checkDisposed();
    value.checkIncInc(0, capacity, 'length');
    _length = value;
  }

  late final Pointer<Int32> _buf;

  /// The maximum number of tokens that can be held, typically the context
  /// window size.
  late final int capacity;
  ContextTokens._(int size) : capacity = size {
    _buf = calloc.allocate(size * sizeOf<Int32>()).cast<Int32>();
  }

  /// Retrieve the token ID for [index].
  int operator [](int index) {
    checkDisposed();
    RangeError.checkValidIndex(index, this);
    return _buf[index];
  }

  /// Set the token ID for [index] to [value].
  void operator []=(int index, int value) {
    checkDisposed();
    RangeError.checkValidIndex(index, this);
    _buf[index] = value;
  }

  /// Add [tokId] to this.
  ///
  /// If there is not enough [capacity], an exception will be thrown.
  void add(int tokId) {
    checkDisposed();
    assert(length <= capacity);
    if (_length == capacity) {
      throw Exception(
          'tried to store $_length tokens in $capacity token buffer');
    }
    _buf[_length++] = tokId;
  }

  /// Tokenizes [text], adds each token, and returns the number of new tokens.
  int addFromString(Pointer<llama_model> model, String text) {
    checkDisposed();
    final remainingCapacity = capacity - _length;
    Pointer<Utf8>? utf;
    try {
      utf = text.toNativeUtf8(allocator: calloc);

      final addBos = isEmpty;
      final numTokens = llama_tokenize(
        model,
        utf.cast<Char>(),
        utf.length,
        _buf.elementAt(_length),
        remainingCapacity,
        addBos, // add Beginning-Of-Stream token
        false, // tokenize meta tokens (like BOS/EOS)
      );

      if (addBos) _log.fine(() => 'Added BOS token to context');

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

  /// Produce a list of tokens from a slice of the stored tokens.
  ///
  /// If [lastN] is provided, will return the tokens in the buffer starting
  /// from `length - lastN`.
  List<Token> toList(Pointer<llama_model> modelPointer, [int? lastN]) {
    checkDisposed();
    lastN ??= _length;
    final list = <Token>[];
    for (var i = _length - lastN; i < _length; i++) {
      list.add(Token.fromId(modelPointer, _buf[i]));
    }
    return list;
  }

  @override
  void dispose() {
    super.dispose();
    calloc.free(_buf);
  }
}

/// Stores the logit sets for each position in the context window.
final class ContextLogits with Disposable {
  static final _log = Logger('Logits');

  /// The maximum number of rows of logits, or the number of tokens in the
  /// context window.
  final int contextSize;

  /// The number of columns of logits, or the number of tokens in the model
  /// vocabulary.
  final int vocabSize;

  /// The number of logit sets currently stored.
  int get length => _length;
  int _length = 0;

  set length(int value) {
    checkDisposed();
    value.checkIncInc(0, contextSize, 'length');
    _length = value;
  }

  /// The last logits set added.
  Pointer<Float> get last => this[length - 1];

  late final Pointer<Float> _logits;

  /// Creates a [ContextLogits], which allocates memory to store logits for the
  /// entire context window.
  ///
  /// For LLaMA-based models with a [vocabSize] of 32000 and a [contextSize] of
  /// 4096 tokens, this will allocate 500MiB of additional memory.
  ContextLogits._(this.contextSize, this.vocabSize) {
    final bytes = contextSize * vocabSize * sizeOf<Float>();
    _log.info('Allocating ${bytes >> 20}MiB for logits');
    _logits = calloc.allocate(bytes);
  }

  /// Retrieve the row of logits for the position [tokenIndex] in the context
  /// window.
  Pointer<Float> operator [](int tokenIndex) {
    checkDisposed();
    tokenIndex.checkIncInc(0, length, 'tokenIndex');
    return _logits.elementAt(vocabSize * tokenIndex);
  }

  /// Add [batchSize] number of logit sets, copying from [batchLogits].
  void add(Pointer<Float> batchLogits, int batchSize) {
    checkDisposed();
    (batchSize + length).checkIncInc(0, contextSize, 'batchSize+length');
    for (var i = 0; i < vocabSize * batchSize; i++) {
      _logits.elementAt(vocabSize * length + i).value =
          batchLogits.elementAt(i).value;
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

/// Stores the log-odds probabilities of each candidate token in the model
/// vocabulary ([size]), for a specific position in the context window.
final class Candidates with Disposable {
  /// The number of logits in a set of candidates.
  int get size => pointer.ref.size;

  /// Pointer to the internal [llama_token_data], same as `pointer.ref.data`.
  late final Pointer<llama_token_data> candidates;

  /// Pointer to the internal [llama_token_data_array] struct used to pass
  /// candidates to the sampling methods in llama.cpp.
  late final Pointer<llama_token_data_array> pointer;

  /// Create and allocate a [Candidates] of size [vocabSize].
  Candidates(int vocabSize) {
    candidates = calloc.allocate(vocabSize * sizeOf<llama_token_data>());
    pointer = calloc.allocate(sizeOf<llama_token_data_array>());

    pointer.ref.data = candidates;
    pointer.ref.size = vocabSize;
    pointer.ref.sorted = false;
  }

  void _load(Pointer<Float> logits) {
    checkDisposed();
    pointer.ref.sorted = false;

    for (var i = 0; i < size; i++) {
      candidates[i].id = i;
      candidates[i].logit = logits[i];
      candidates[i].p = 0.0;
    }
  }

  /// Retrieves the [llama_token_data] at [index].
  ///
  /// Initially, index is equal to the token ID, such that `index == 0` gives
  /// the UNK token, and so on. However, if a [Sampler] has sorted the
  /// candidates, then this is not the case. **Callers should check
  /// `pointer.ref.sorted` and verify the logits returned match the expected
  /// token.**
  llama_token_data operator [](int index) {
    checkDisposed();
    return candidates[index];
  }

  /// Set the [llama_token_data] at [index].
  void operator []=(int index, llama_token_data tokData) {
    checkDisposed();
    candidates[index] = tokData;
  }

  @override
  void dispose() {
    super.dispose();
    calloc.free(candidates);
    calloc.free(pointer);
  }
}
