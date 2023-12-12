import 'dart:math';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'package:llamacpp/src/llama.dart' show Token;
import 'package:llamacpp/llama_ffi.dart';
import 'package:llamacpp/src/isolate_models.dart';

abstract interface class Sampler {
  /// Apply this sampler to [cands] and optionally return a [Token].
  /// Returning a token prevents any further [Sampler] from being called.
  Token? sample(Context ctx, Candidates cands, TokenBuf toks);
}

abstract interface class NativeMemoryUser {
  void alloc();
  void free();
}

/// Implements temperature based sampling.
///
/// Typically, this sampler should be called last.
final class Temperature implements Sampler {
  final double temp;
  bool get greedy => temp == 0.0;
  // TODO(crasm): change to temp >= Float32.minValue * 10 or something
  const Temperature(this.temp) : assert(temp >= 0.0);

  @override
  Token? sample(Context ctx, Candidates cands, TokenBuf toks) {
    if (temp == 0.0) {
      final tokId = llama_sample_token_greedy(ctx.pointer, cands.pointer);
      return ctx.tokenFromId(tokId);
    } else {
      llama_sample_temp(ctx.pointer, cands.pointer, temp);
      return null;
    }
  }

  @override
  String toString() => 'Temperature{$temp}';
}

final class TopK implements Sampler {
  final int topK;
  final int keepProbs;
  const TopK(this.topK, {this.keepProbs = 1})
      : assert(topK >= 0),
        assert(keepProbs > 0);

  @override
  Token? sample(Context ctx, Candidates cands, TokenBuf toks) {
    llama_sample_top_k(
      ctx.pointer,
      cands.pointer,
      topK == 0 ? llama_n_vocab(ctx.model.pointer) : topK,
      keepProbs,
    );
    return null;
  }

  @override
  String toString() => 'TopK{$topK}';
}

final class TopP implements Sampler {
  final double topP;
  final int keepProbs;
  const TopP(this.topP, {this.keepProbs = 1})
      : assert(topP >= 0.0 && topP <= 1.0),
        assert(keepProbs > 0);

  @override
  Token? sample(Context ctx, Candidates cands, TokenBuf toks) {
    llama_sample_top_p(ctx.pointer, cands.pointer, topP, keepProbs);
    return null;
  }

  @override
  String toString() => 'TopP{$topP}';
}

/// Implements min P sampling.
///
/// Generally, this should only be used with [Temperature] sampling and no
/// other samplers.
final class MinP implements Sampler {
  final double minP;
  final int keepProbs;
  const MinP(this.minP, {this.keepProbs = 1})
      : assert(minP >= 0.0 && minP <= 1.0),
        assert(keepProbs > 0);

  @override
  Token? sample(Context ctx, Candidates cands, TokenBuf toks) {
    llama_sample_min_p(ctx.pointer, cands.pointer, minP, keepProbs);
    return null;
  }

  @override
  String toString() => 'MinP{$minP}';
}

final class TailFree implements Sampler {
  final double z;
  final int keepProbs;
  const TailFree(this.z, {this.keepProbs = 1})
      : assert(z >= 0.0 && z <= 1.0),
        assert(keepProbs > 0);

  @override
  Token? sample(Context ctx, Candidates cands, TokenBuf toks) {
    llama_sample_tail_free(ctx.pointer, cands.pointer, z, keepProbs);
    return null;
  }

  @override
  String toString() => 'TailFree{$z}';
}

final class LocallyTypical implements Sampler {
  final double p;
  final int keepProbs;
  const LocallyTypical(this.p, {this.keepProbs = 1})
      : assert(p >= 0.0 && p <= 1.0),
        assert(keepProbs > 0);

  @override
  Token? sample(Context ctx, Candidates cands, TokenBuf toks) {
    llama_sample_typical(ctx.pointer, cands.pointer, p, keepProbs);
    return null;
  }

  @override
  String toString() => 'LocallyTypical{$p}';
}

int _min(List<int> args) => args.fold(args[0], min);

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
  Token? sample(Context ctx, Candidates cands, TokenBuf toks) {
    final nlId = llama_token_nl(ctx.model.pointer);
    final nlBackupLogit = cands[nlId];

    var lastN = this.lastN;
    if (lastN == -1) {
      lastN = ctx.params.n_ctx;
    }

    lastN = _min([
      toks.capacity,
      lastN,
      ctx.params.n_ctx,
    ]);

    final tokenPointer = toks.buf.elementAt(toks.capacity - lastN);

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
      // llama/common/sampling.cpp uses a loop here, because it's possible for
      // the candidates to be sorted (and therefore newline logit not at index nlId).
      assert(!cands.pointer.ref.sorted);
      cands[nlId] = nlBackupLogit;
    }
    return null;
  }

  @override
  String toString() =>
      'RepetitionPenalty{lastN=$lastN, penalty=$penalty, frequencyPenalty=$frequencyPenalty, presencePenalty=$presencePenalty, penalizeNewline=$penalizeNewline}';
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
  Token? sample(Context ctx, Candidates cands, TokenBuf toks) {
    const m = 100;
    final tokId = llama_sample_token_mirostat(
        ctx.pointer, cands.pointer, tau, eta, m, _mu);
    return ctx.tokenFromId(tokId);
  }
}

final class MirostatV2 extends Mirostat {
  MirostatV2([super.tau, super.eta]);
  @override
  Token? sample(Context ctx, Candidates cands, TokenBuf toks) {
    final tokId = llama_sample_token_mirostat_v2(
        ctx.pointer, cands.pointer, tau, eta, _mu);
    return ctx.tokenFromId(tokId);
  }
}
