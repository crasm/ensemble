import 'dart:math';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'package:ensemble_llama/llama_ffi.dart';
import 'package:ensemble_llama/src/isolate.dart' show Candidates, TokenBuf;
import 'package:ensemble_llama/src/llama.dart' show Context;

abstract interface class ChainableSampler {
  void apply(Context ctx, Candidates cands, TokenBuf toks);
}

abstract interface class TerminalSampler {
  int applyAndSample(Context ctx, Candidates cands, TokenBuf toks);
}

abstract interface class NativeMemoryUser {
  void alloc();
  void free();
}

/// Implements temperature based sampling.
///
/// Typically, this sampler should be called last.
final class Temperature implements ChainableSampler {
  final double temp;
  const Temperature(this.temp) : assert(temp >= 0.0);

  @override
  void apply(Context ctx, Candidates cands, TokenBuf toks) =>
      llama_sample_temp(ctx.pointer, cands.pointer, temp);
}

final class TopK implements ChainableSampler {
  final int topK;
  final int keepProbs;
  const TopK(this.topK, {this.keepProbs = 1})
      : assert(topK > 0),
        assert(keepProbs > 0);

  @override
  void apply(Context ctx, Candidates cands, TokenBuf toks) =>
      llama_sample_top_k(
        ctx.pointer,
        cands.pointer,
        topK == 0 ? llama_n_vocab(ctx.model.pointer) : topK,
        keepProbs,
      );
}

final class TopP implements ChainableSampler {
  final double topP;
  final int keepProbs;
  const TopP(this.topP, {this.keepProbs = 1})
      : assert(topP >= 0.0 && topP <= 1.0),
        assert(keepProbs > 0);

  @override
  void apply(Context ctx, Candidates cands, TokenBuf toks) =>
      llama_sample_top_p(ctx.pointer, cands.pointer, topP, keepProbs);
}

/// Implements min P sampling.
///
/// Generally, this should only be used with [Temperature] sampling and no
/// other samplers.
final class MinP implements ChainableSampler {
  final double minP;
  final int keepProbs;
  const MinP(this.minP, {this.keepProbs = 1})
      : assert(minP >= 0.0 && minP <= 1.0),
        assert(keepProbs > 0);

  @override
  void apply(Context ctx, Candidates cands, TokenBuf toks) =>
      llama_sample_min_p(ctx.pointer, cands.pointer, minP, keepProbs);
}

final class TailFree implements ChainableSampler {
  final double z;
  final int keepProbs;
  const TailFree(this.z, {this.keepProbs = 1})
      : assert(z >= 0.0 && z <= 1.0),
        assert(keepProbs > 0);

  @override
  void apply(Context ctx, Candidates cands, TokenBuf toks) =>
      llama_sample_tail_free(ctx.pointer, cands.pointer, z, keepProbs);
}

final class LocallyTypical implements ChainableSampler {
  final double p;
  final int keepProbs;
  const LocallyTypical(this.p, {this.keepProbs = 1})
      : assert(p >= 0.0 && p <= 1.0),
        assert(keepProbs > 0);

  @override
  void apply(Context ctx, Candidates cands, TokenBuf toks) =>
      llama_sample_typical(ctx.pointer, cands.pointer, p, keepProbs);
}

int _min(List<int> args) => args.fold(args[0], (a, b) => min(a, b));

final class RepetitionPenalty implements ChainableSampler {
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
  void apply(Context ctx, Candidates cands, TokenBuf toks) {
    final nlId = llama_token_nl(ctx.model.pointer);
    final nlBackupLogit = cands.getLogit(nlId);

    var lastN = this.lastN;
    if (lastN == -1) {
      lastN = ctx.params.contextSizeTokens;
    }

    lastN = _min([
      toks.capacity,
      lastN,
      ctx.params.contextSizeTokens,
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
      cands.setLogit(nlId, nlBackupLogit);
    }
  }
}

mixin MirostatMu implements NativeMemoryUser {
  int? _raw;

  get _mu => Pointer.fromAddress(_raw!).cast<Float>();

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

sealed class Mirostat with MirostatMu implements TerminalSampler {
  final double tau;
  final double eta;
  Mirostat([this.tau = 5.0, this.eta = 0.1])
      : assert(tau > 0.0),
        assert(eta > 0.0);
}

final class MirostatV1 extends Mirostat {
  MirostatV1([super.tau, super.eta]);
  @override
  int applyAndSample(Context ctx, Candidates cands, TokenBuf toks) {
    final m = 100;
    return llama_sample_token_mirostat(
        ctx.pointer, cands.pointer, tau, eta, m, _mu);
  }
}

final class MirostatV2 extends Mirostat {
  MirostatV2([super.tau, super.eta]);
  @override
  int applyAndSample(Context ctx, Candidates cands, TokenBuf toks) {
    return llama_sample_token_mirostat_v2(
        ctx.pointer, cands.pointer, tau, eta, _mu);
  }
}

final class GreedySampler implements TerminalSampler {
  const GreedySampler();
  @override
  int applyAndSample(Context ctx, Candidates cands, TokenBuf _) =>
      llama_sample_token_greedy(
        ctx.pointer,
        cands.pointer,
      );
}

/// Samples the next token randomly, using the probabilities in [cands].
///
/// This is called last, after any [ChainableSampler] have been called, unless
/// an alternative [TerminalSampler] is supplied. This does not modify any
/// probabilities in [cands].
final class DefaultLastSampler implements TerminalSampler {
  const DefaultLastSampler();
  @override
  int applyAndSample(Context ctx, Candidates cands, TokenBuf _) =>
      llama_sample_token(ctx.pointer, cands.pointer);
}
