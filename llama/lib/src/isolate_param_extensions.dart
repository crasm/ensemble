import 'package:ensemble_llama/src/params.dart';
import 'package:ensemble_llama/llama_ffi.dart';

extension ModelParamConverter on llama_model_params {
  void setSimpleFrom(ModelParams p) {
    n_gpu_layers = p.gpuLayers;
    main_gpu = p.cudaMainGpu;
    // Skipping: tensor_split
    // Skipping: progress_callback{,_user_data}
    vocab_only = p.loadOnlyVocabSkipTensors;
    use_mmap = p.useMmap;
    use_mlock = p.useMlock;
  }
}

extension ContextParamConverter on llama_context_params {
  void setSimpleFrom(ContextParams p) {
    seed = p.seed;
    n_ctx = p.contextSizeTokens;
    n_batch = p.batchSizeTokens;
    n_threads = p.threads;
    n_threads_batch = p.batchThreads;

    rope_scaling_type =
        p.rope?.llamaRopeScalingType() ?? llama_rope_scaling_type.LLAMA_ROPE_SCALING_UNSPECIFIED;
    if (p.rope is RopeLinear) {
      final rope = p.rope! as RopeLinear;
      rope_freq_base = rope.freqBase;
      rope_freq_scale = rope.freqScale;
    } else if (p.rope is RopeYarn) {
      final yarn = p.rope! as RopeYarn;
      yarn_ext_factor = yarn.extrapolFactor;
      yarn_beta_fast = yarn.betaFast;
      yarn_beta_slow = yarn.betaSlow;
      yarn_orig_ctx = yarn.origCtx;
    }

    mul_mat_q = p.cudaUseMulMatQ;
    f16_kv = p.useFloat16KVCache;
    // Needed for zero-decode generation on matching prompt prefix
    logits_all = true;
    embedding = p.embeddingModeOnly;
  }
}
