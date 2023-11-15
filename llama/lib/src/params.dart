import 'package:ensemble_llama/src/common.dart';

extension on num {
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
  final double ropeFreqBase;
  final double ropeFreqScale;
  final bool cudaUseMulMatQ;
  final bool useFloat16KVCache;
  final bool computeAllLogits;
  final bool embeddingModeOnly;

  ContextParams({
    this.seed = int32Max,
    this.contextSizeTokens = 512,
    this.batchSizeTokens = 512,
    this.ropeFreqBase = 10000.0,
    this.ropeFreqScale = 1.0,
    this.cudaUseMulMatQ = true,
    this.useFloat16KVCache = true,
    this.computeAllLogits = false,
    this.embeddingModeOnly = false,
  }) {
    seed.checkIncInc(0, int32Max, "seed");
    contextSizeTokens.checkGTE(2, "contextSizeTokens");
    batchSizeTokens.checkGTE(1, "batchSizeTokens");
    ropeFreqBase.checkGT(0.0, "ropeFreqBase");
    ropeFreqScale.checkZeroToOne("ropeFreqScale");
  }
}

class SamplingParams {
  final int topK;
  final double topP;
  final double tfsZ;
  final double typicalP;
  final double temperature;
  final double repeatPenalty;
  final int repeatPenaltyLastN;
  final double frequencyPenalty;
  final double presencePenalty;
  final int mirostatMode;
  final double mirostatTau;
  final double mirostatEta;
  final bool penalizeNewline;
  final int keepTokenTopProbs;
  final String? cfgNegativePrompt;
  final double cfgScale;
  final Map? tokenLogitBiasMap;

  SamplingParams({
    this.topK = 40,
    this.topP = 0.95,
    this.tfsZ = 1.00,
    this.typicalP = 1.0,
    this.temperature = 0.80,
    this.repeatPenalty = 1.10,
    this.repeatPenaltyLastN = 64,
    this.frequencyPenalty = 0.00,
    this.presencePenalty = 0.00,
    this.mirostatMode = 0,
    this.mirostatTau = 5.00,
    this.mirostatEta = 0.10,
    this.penalizeNewline = true,
    this.keepTokenTopProbs = 1,
    this.cfgNegativePrompt,
    this.cfgScale = 1.0,
    this.tokenLogitBiasMap,
  }) {
    topK.checkGTE(0, "topK");
    topP.checkZeroToOne("topP");
    tfsZ.checkZeroToOne("tfsZ");
    typicalP.checkZeroToOne("typicalP");
    temperature.checkGTE(0, "temperature");
    repeatPenalty.checkGTE(0, "repeatePenalty");
    repeatPenaltyLastN.checkGTE(-1, "repeatPenaltyLastN");
    frequencyPenalty.checkZeroToOne("frequencyPenalty");
    presencePenalty.checkZeroToOne("presencePenalty");
    mirostatMode.checkIncInc(0, 2, "mirostatMode");
    mirostatTau.checkGTE(0.0, "mirostatTau");
    mirostatEta.checkGTE(0.0, "mirostatEta");
    keepTokenTopProbs.checkGTE(1, "keepTokenTopProbs");
    cfgScale.checkGTE(0.0, "cfgScale");
  }
}
