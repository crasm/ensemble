import 'package:ensemble_llama/llama_ffi.dart';
import 'package:ensemble_llama/src/common.dart';

extension on num {
  void checkNotNaN(String name) {
    if (isNaN) {
      throw RangeError.value(this, name);
    }
  }

  void checkIncInc(num start, num end, String name) {
    if (!(this >= start && this <= end)) {
      throw RangeError.value(this, name, "must be between [$start, $end]");
    }
  }

  void checkZeroToOne(String name) {
    if (!(this >= 0.0 && this <= 1.0)) {
      throw RangeError.value(this, name, "must be between [0.0, 1.0]");
    }
  }

  void checkGT(num min, String name) {
    if (!(this > min)) {
      throw RangeError.value(this, name, "must be greater than $min");
    }
  }

  void checkGTE(num min, String name) {
    if (!(this >= min)) {
      throw RangeError.value(
          this, name, "must be greater than or equal to $min");
    }
  }
}

// TODO: explain all parameters for ModelParams, ContextParams, and SamplingParams
class ModelParams {
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
    gpuLayers.checkGTE(0, "gpuLayers");
    cudaMainGpu.checkGTE(0, "cudaMainGpu");
  }
}

class ContextParams {
  final int seed;
  final int contextSizeTokens;
  final int batchSizeTokens;
  final int threads;
  final int batchThreads;

  final int ropeScalingType;
  final double ropeFreqBase;
  final double ropeFreqScale;
  final double yarnExtrapolFactor;
  final double yarnAttnScaleFactor;
  final double yarnBetaFast;
  final double yarnBetaSlow;
  final int yarnOrigCtx;

  final bool cudaUseMulMatQ;
  final bool useFloat16KVCache;
  final bool computeAllLogits;
  final bool embeddingModeOnly;

  ContextParams({
    this.seed = int32Max,
    this.contextSizeTokens = 512,
    this.batchSizeTokens = 512,
    this.threads = GGML_DEFAULT_N_THREADS,
    this.batchThreads = GGML_DEFAULT_N_THREADS,
    this.ropeScalingType =
        llama_rope_scaling_type.LLAMA_ROPE_SCALING_UNSPECIFIED,
    this.ropeFreqBase = 0.0, //  0.0 = from model
    this.ropeFreqScale = 0.0, // 0.0 = from model
    this.yarnExtrapolFactor =
        -1.0, // negative indicates 'not set' (default 1.0)
    this.yarnAttnScaleFactor = 1.0,
    this.yarnBetaFast = 32.0,
    this.yarnBetaSlow = 1.0,
    this.yarnOrigCtx = 0,
    this.cudaUseMulMatQ = true,
    this.useFloat16KVCache = true,
    this.computeAllLogits = false,
    this.embeddingModeOnly = false,
  }) {
    seed.checkIncInc(0, int32Max, "seed");
    contextSizeTokens.checkGTE(2, "contextSizeTokens");
    batchSizeTokens.checkGTE(1, "batchSizeTokens");
    threads.checkGTE(1, "threads");
    batchThreads.checkGTE(1, "batchThreads");
    ropeScalingType.checkIncInc(
        llama_rope_scaling_type.LLAMA_ROPE_SCALING_UNSPECIFIED,
        llama_rope_scaling_type.LLAMA_ROPE_SCALING_MAX_VALUE,
        "ropeScalingType");
    ropeFreqBase.checkGTE(0.0, "ropeFreqBase");
    ropeFreqScale.checkZeroToOne("ropeFreqScale");
    yarnExtrapolFactor.checkNotNaN("yarnExtrapol");
    yarnAttnScaleFactor.checkGTE(1.0, "yarnAttnScaleFactor");
    yarnBetaFast.checkGT(0.0, "yarnBetaFast");
    yarnBetaSlow.checkGT(0.0, "yarnBetaSlow");
    yarnOrigCtx.checkGTE(0, "yarnOrigCtx");
  }
}

class SamplingParams {
  // final int keepTokenPrev; // Not using this one yet
  int keepTokenTopProbs;
  int topK;
  double topP;
  double minP;
  double tfsZ;
  double typicalP;
  double temperature;
  int repeatPenaltyLastN;
  double repeatPenalty;
  double frequencyPenalty;
  double presencePenalty;
  int mirostatMode;
  double mirostatTau;
  double mirostatEta;
  bool penalizeNewline;
  // TODO: grammar
  String? cfgNegativePrompt;
  double cfgScale;
  Map? tokenLogitBiasMap;

  SamplingParams({
    this.keepTokenTopProbs = 1,
    this.topK = 0,
    this.topP = 1.00,
    this.minP = 0.00,
    this.tfsZ = 1.00,
    this.typicalP = 1.0,
    this.temperature = 0.00,
    this.repeatPenaltyLastN = 0,
    this.repeatPenalty = 1.00,
    this.frequencyPenalty = 0.00,
    this.presencePenalty = 0.00,
    this.mirostatMode = 0,
    this.mirostatTau = 5.00,
    this.mirostatEta = 0.10,
    this.penalizeNewline = true,
    this.cfgNegativePrompt,
    this.cfgScale = 1.0,
    this.tokenLogitBiasMap,
  }) {
    keepTokenTopProbs.checkGTE(1, "keepTokenTopProbs");
    topK.checkGTE(0, "topK");
    topP.checkZeroToOne("topP");
    minP.checkGTE(0.0, "minP");
    tfsZ.checkZeroToOne("tfsZ");
    typicalP.checkZeroToOne("typicalP");
    temperature.checkGTE(0, "temperature");
    repeatPenaltyLastN.checkGTE(-1, "repeatPenaltyLastN");
    repeatPenalty.checkGTE(0, "repeatePenalty");
    frequencyPenalty.checkZeroToOne("frequencyPenalty");
    presencePenalty.checkZeroToOne("presencePenalty");
    mirostatMode.checkIncInc(0, 2, "mirostatMode");
    mirostatTau.checkGTE(0.0, "mirostatTau");
    mirostatEta.checkGTE(0.0, "mirostatEta");
    cfgScale.checkGTE(0.0, "cfgScale");
  }

  SamplingParams.greedy() : this(temperature: 0.0);
}
