part of 'llamacpp.dart';

final class UnsortedError extends Error {
  final String sampler;
  UnsortedError(this.sampler);
  @override
  String toString() =>
      "UnsortedError: Can't apply $sampler to unsorted candidates.";
}

/// Samplers implement different ways to alter potential [Candidates], such as
/// [Temperature], [TopK], and [MinP].
abstract interface class Sampler {
  /// Apply this sampler to [ctx] and optionally end sampling by returning a
  /// token. If a token is returned, no further samplers will be called.
  Token? sample(Context ctx);
}

/// Implementers of this interface require native memory allocated using e.g.
/// [malloc] or [calloc].
///
/// With regards to samplers, a [Sampler] that implements NativeMemoryUser will
/// be allocated at the beginning of [Context.generate] and will be freed after
/// generation is stopped.
abstract interface class NativeMemoryUser {
  /// Allocate native memory.
  void alloc();

  /// Free native memory.
  void free();
}

final class _DefaultLastSampler implements Sampler {
  const _DefaultLastSampler();
  @override
  Token? sample(Context ctx) {
    final tokId = llama_sample_token(ctx.pointer, ctx._candidates.pointer);
    return Token._fromId(ctx.model.pointer, tokId);
  }
}

/// A temperature sampler, which increases the likelihood of less probable
/// next-token candidates.
///
/// Typical values for temperature are 0.0 (greedy sampling) or around 0.70.
///
/// * [temp] must be positive.
/// * `temp == 0.0` creates a greedy sampler, which samples and returns the most
/// likely next token.
/// * `temp > 0.0` does not end sampling, but instead alters the [Candidates] to
/// make tokens with lower probability more likely.
final class Temperature implements Sampler {
  /// The temperature of the model.
  final double temp;

  /// Defines a temperature sampler.
  const Temperature(this.temp) : assert(temp >= 0.0);

  @override
  Token? sample(Context ctx) {
    if (temp == 0.0) {
      final tokId = llama_sample_token_greedy(
        ctx.pointer,
        ctx._candidates.pointer,
      );
      return Token._fromId(ctx.model.pointer, tokId);
    } else {
      llama_sample_temp(ctx.pointer, ctx._candidates.pointer, temp);
      return null;
    }
  }

  @override
  String toString() => 'Temperature{$temp}';
}

/// A top-k sampler, which restricts the next-token candidates to the top *k*
/// most likely tokens.
///
/// A typical value for top-k is 40.
final class TopK implements Sampler {
  /// The top *k* most likely tokens to keep in [Candidates].
  final int topK;

  /// The minimum number of candidates to retain.
  final int minKeep;

  /// Defines a top-k sampler.
  const TopK(this.topK, {this.minKeep = 1})
      : assert(topK >= 0),
        assert(minKeep > 0);

  @override
  Token? sample(Context ctx) {
    llama_sample_top_k(
      ctx.pointer,
      ctx._candidates.pointer,
      topK == 0 ? llama_n_vocab(ctx.model.pointer) : topK,
      minKeep,
    );
    return null;
  }

  @override
  String toString() => 'TopK{$topK}';
}

/// A top-p sampler, which restricts the next-token candidates to the first *n*
/// most likely tokens, where the sum of the probabilities from 1..n == p.
///
/// A typical value for top-p is 0.95.
final class TopP implements Sampler {
  /// The target sum probability.
  final double topP;

  /// The minimum number of candidates to retain.
  final int minKeep;

  /// Defines a top-p sampler.
  const TopP(this.topP, {this.minKeep = 1})
      : assert(topP >= 0.0 && topP <= 1.0),
        assert(minKeep > 0);

  @override
  Token? sample(Context ctx) {
    llama_sample_top_p(ctx.pointer, ctx._candidates.pointer, topP, minKeep);
    return null;
  }

  @override
  String toString() => 'TopP{$topP}';
}

final class MinP implements Sampler {
  final double minP;
  final int minKeep;
  const MinP(this.minP, {this.minKeep = 1})
      : assert(minP >= 0.0 && minP <= 1.0),
        assert(minKeep > 0);

  @override
  Token? sample(Context ctx) {
    llama_sample_min_p(ctx.pointer, ctx._candidates.pointer, minP, minKeep);
    return null;
  }

  @override
  String toString() => 'MinP{$minP}';
}

final class TailFree implements Sampler {
  final double z;
  final int minKeep;
  const TailFree(this.z, {this.minKeep = 1})
      : assert(z >= 0.0 && z <= 1.0),
        assert(minKeep > 0);

  @override
  Token? sample(Context ctx) {
    llama_sample_tail_free(ctx.pointer, ctx._candidates.pointer, z, minKeep);
    return null;
  }

  @override
  String toString() => 'TailFree{$z}';
}

final class LocallyTypical implements Sampler {
  final double p;
  final int minKeep;
  const LocallyTypical(this.p, {this.minKeep = 1})
      : assert(p >= 0.0 && p <= 1.0),
        assert(minKeep > 0);

  @override
  Token? sample(Context ctx) {
    llama_sample_typical(ctx.pointer, ctx._candidates.pointer, p, minKeep);
    return null;
  }

  @override
  String toString() => 'LocallyTypical{$p}';
}

int _min(List<int> args) => args.fold(args[0], min);

/// A repetition penalty sampler, which decreases next-token candidate
/// probabilities based on how often it has appeared previously.
///
/// WARNING: [penalizeNewline] set to false will not work unless the
/// RepetitionSampler is the first sampler. It requires the candidates to be
/// sorted and indexed by token ID, but after using other samplers this may not
/// hold.
final class RepetitionPenalty implements Sampler {
  final int lastN;
  final double penalty;
  final double frequencyPenalty;
  final double presencePenalty;
  final bool penalizeNewline;
  const RepetitionPenalty({
    this.lastN = -1,
    this.penalty = 1.1,
    this.frequencyPenalty = 0.0,
    this.presencePenalty = 0.0,
    this.penalizeNewline = true,
  })  : assert(lastN >= -1),
        assert(penalty >= 0.0),
        assert(frequencyPenalty >= 0.0 && frequencyPenalty <= 1.0),
        assert(presencePenalty >= 0.0 && presencePenalty <= 1.0);

  @override
  Token? sample(Context ctx) {
    final toks = ctx.tokens;
    final cands = ctx._candidates;
    if (!cands.pointer.ref.sorted) {
      throw UnsortedError('RepetitionPenalty');
    }

    final nlId = llama_token_nl(ctx.model.pointer);
    final nlData = cands[nlId];
    assert(nlData.id == nlId);

    var lastN = this.lastN;
    if (lastN == -1) {
      lastN = ctx.params.n_ctx;
    }

    lastN = _min([
      toks.capacity,
      lastN,
      ctx.params.n_ctx,
    ]);

    final tokenPointer = toks._buf + (toks.capacity - lastN);

    llama_sample_repetition_penalties(
      ctx.pointer,
      cands.pointer,
      tokenPointer,
      lastN,
      penalty,
      frequencyPenalty,
      presencePenalty,
    );

    if (!penalizeNewline) {
      cands[nlId] = nlData;
    }
    return null;
  }

  @override
  String toString() => 'RepetitionPenalty{lastN=$lastN, penalty=$penalty, '
      'frequencyPenalty=$frequencyPenalty, presencePenalty=$presencePenalty, '
      'penalizeNewline=$penalizeNewline}';
}

mixin MirostatMu implements NativeMemoryUser {
  int? _raw;

  Pointer<Float> get _mu => Pointer.fromAddress(_raw!).cast<Float>();

  @override
  void alloc() {
    assert(_raw == null);
    _raw = calloc.allocate(sizeOf<Float>()).address;
  }

  @override
  void free() {
    assert(_raw != null);
    calloc.free(Pointer.fromAddress(_raw!).cast<Float>());
  }
}

sealed class Mirostat with MirostatMu implements Sampler {
  final double tau;
  final double eta;
  Mirostat([this.tau = 5.0, this.eta = 0.1])
      : assert(tau > 0.0),
        assert(eta > 0.0);

  @override
  String toString() {
    switch (this) {
      case MirostatV1():
        return 'MirostatV1{tau: $tau, eta: $eta}';
      case MirostatV2():
        return 'MirostatV2{tau: $tau, eta: $eta}';
    }
  }
}

final class MirostatV1 extends Mirostat {
  MirostatV1([super.tau, super.eta]);
  @override
  Token? sample(Context ctx) {
    const m = 100;
    final tokId = llama_sample_token_mirostat(
        ctx.pointer, ctx._candidates.pointer, tau, eta, m, _mu);
    return Token._fromId(ctx.model.pointer, tokId);
  }
}

final class MirostatV2 extends Mirostat {
  MirostatV2([super.tau, super.eta]);
  @override
  Token? sample(Context ctx) {
    final tokId = llama_sample_token_mirostat_v2(
        ctx.pointer, ctx._candidates.pointer, tau, eta, _mu);
    return Token._fromId(ctx.model.pointer, tokId);
  }
}

final class LogitBias implements Sampler {
  final Map<int, double> biasMap;
  const LogitBias(this.biasMap);

  @override
  Token? sample(Context ctx) {
    final cands = ctx._candidates;
    if (!cands.pointer.ref.sorted) {
      throw UnsortedError('LogitBias');
    }

    biasMap.forEach((tokId, bias) {
      final c = cands[tokId];
      assert(c.id == tokId);
      c.logit += bias;
      cands[tokId] = c;
    });

    return null;
  }
}
