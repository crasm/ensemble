import 'package:ensemble_llama/llama_ffi.dart';
import 'package:ensemble_llama/src/common.dart';

// TODO: explain all parameters for ModelParams, ContextParams, and SamplingParams
final class ModelParams {
  final int gpuLayers;
  final int cudaMainGpu;
  // final List<double> cudaTensorSplits;
  final bool loadOnlyVocabSkipTensors;
  final bool useMmap;
  final bool useMlock;

  ModelParams({
    this.gpuLayers = 0,
    this.cudaMainGpu = 0,
    // this.cudaTensorSplits = const [0.0],
    this.loadOnlyVocabSkipTensors = false,
    this.useMmap = true,
    this.useMlock = false,
  }) {
    gpuLayers.checkGTE(0, 'gpuLayers');
    cudaMainGpu.checkGTE(0, 'cudaMainGpu');
  }
}

final class ContextParams {
  final int seed;
  final int contextSizeTokens;
  final int batchSizeTokens;
  final int threads;
  final int batchThreads;

  final Rope? rope;

  final bool cudaUseMulMatQ;
  final bool useFloat16KVCache; // TODO: isn't this deprecated?
  final bool embeddingModeOnly;

  ContextParams({
    this.seed = int32Max,
    this.contextSizeTokens = 512,
    this.batchSizeTokens = 512,
    this.threads = GGML_DEFAULT_N_THREADS,
    this.batchThreads = GGML_DEFAULT_N_THREADS,
    this.rope,
    this.cudaUseMulMatQ = true,
    this.useFloat16KVCache = true,
    this.embeddingModeOnly = false,
  }) {
    seed.checkIncInc(0, int32Max, 'seed');
    contextSizeTokens.checkGTE(2, 'contextSizeTokens');
    batchSizeTokens.checkGTE(1, 'batchSizeTokens');
    threads.checkGTE(1, 'threads');
    batchThreads.checkGTE(1, 'batchThreads');
  }
}

sealed class Rope {
  int llamaRopeScalingType();
}

final class RopeNone extends Rope {
  @override
  int llamaRopeScalingType() => llama_rope_scaling_type.LLAMA_ROPE_SCALING_NONE;
}

final class RopeLinear extends Rope {
  final double freqBase;
  final double freqScale;
  RopeLinear(this.freqBase, this.freqScale)
      : assert(freqBase > 0.0),
        assert(freqScale > 0.0 && freqScale <= 1.0);

  @override
  int llamaRopeScalingType() => llama_rope_scaling_type.LLAMA_ROPE_SCALING_LINEAR;
}

// TODO: test yarn
final class RopeYarn extends Rope {
  final double extrapolFactor;
  final double attnScaleFactor;
  final double betaFast;
  final double betaSlow;
  final int origCtx;

  RopeYarn({
    this.extrapolFactor = -1.0, // negative indicates 'not set' (default 1.0)
    this.attnScaleFactor = 1.0,
    this.betaFast = 32.0,
    this.betaSlow = 1.0,
    this.origCtx = 0,
  });

  @override
  int llamaRopeScalingType() => llama_rope_scaling_type.LLAMA_ROPE_SCALING_YARN;
}
