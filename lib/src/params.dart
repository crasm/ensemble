import 'package:ensemble_llama/src/common.dart';

// TODO: explain all parameters for ModelParams, ContextParams, and SamplingParams
class ModelParams {
  final int gpuLayers;
  final int cudaMainGpu;
  // final List<double> cudaTensorSplits;
  final bool loadOnlyVocabSkipTensors;
  final bool useMmap;
  final bool useMlock;

  const ModelParams({
    this.gpuLayers = 0,
    this.cudaMainGpu = 0,
    // this.cudaTensorSplits = const [0.0],
    this.loadOnlyVocabSkipTensors = false,
    this.useMmap = true,
    this.useMlock = false,
  });
}

// TODO: insert ArgumentError.value checks for all params
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

  const ContextParams({
    this.seed = int32Max,
    this.contextSizeTokens = 512,
    this.batchSizeTokens = 512,
    this.ropeFreqBase = 10000.0,
    this.ropeFreqScale = 1.0,
    this.cudaUseMulMatQ = true,
    this.useFloat16KVCache = true,
    this.computeAllLogits = false,
    this.embeddingModeOnly = false,
  });
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
  const SamplingParams({
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
    this.keepTokenTopProbs = 0,
    this.cfgNegativePrompt,
    this.cfgScale = 1.0,
    this.tokenLogitBiasMap,
  });
}
