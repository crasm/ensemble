import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

import 'bindings.dart';

// Internal singleton for managing llama.cpp globally
class _LlamaCpp {
  static final _LlamaCpp _instance = _LlamaCpp._init();

  final DynamicLibrary _libllama = DynamicLibrary.open(
      path.join(Directory.current.path, 'llama', 'libllama.so'));

  factory _LlamaCpp() {
    return _instance;
  }

  _LlamaCpp._init() {
    _libllama
        .lookupFunction<BackendInitC, BackendInit>('llama_backend_init')
        .call(false);
  }

  void dispose() {
    _libllama
        .lookupFunction<BackendFreeC, BackendFree>('llama_backend_free')
        .call();
  }
}

String systemInfo() {
  return _LlamaCpp()
      ._libllama
      .lookupFunction<PrintSystemInfo, PrintSystemInfo>(
        isLeaf: true,
        'llama_print_system_info',
      )
      .call()
      .toDartString();
}

typedef ModelLoadingProgressCallback = Future<void> Function(double progress);

typedef LlamaProgressCallback = Void Function(
    Float progress, Pointer<Void> ctx);

final class ContextParams extends Struct {
  @Uint32()
  external int seed;
  @Int32()
  external int n_ctx;
  @Int32()
  external int n_batch;
  @Int32()
  external int n_gpu_layers;
  @Int32()
  external int main_gpu;

  external Pointer<Float> tensor_split;

  @Float()
  external double rope_freq_base;
  @Float()
  external double rope_freq_scale;

  external Pointer<NativeFunction<LlamaProgressCallback>> progress_callback;
  external Pointer<Void> progress_callback_user_data;

  @Bool()
  external bool low_vram;
  @Bool()
  external bool mul_mat_q;
  @Bool()
  external bool f16_kv;
  @Bool()
  external bool logits_all;
  @Bool()
  external bool vocab_only;
  @Bool()
  external bool use_mmap;
  @Bool()
  external bool use_mlock;
  @Bool()
  external bool embedding;
}

class LlamaCppModel {
  final String ggufModelFilePath;
  final int contextWindowSize;
  final int gpuLayers;
  final bool useMmap;
  final int promptBatchProcessingSize;
  final double ropeFreqBase;
  final double ropeFreqScale;
  // TODO: LORA
  // TODO: main GPU
  // TODO: tensor split
  // TODO: model seed
  // TODO: mulmatq
  LlamaCppModel._({
    required this.ggufModelFilePath,
    required this.contextWindowSize,
    required this.gpuLayers,
    this.useMmap = false,
    this.promptBatchProcessingSize = 512,
    this.ropeFreqBase = 10000.0,
    this.ropeFreqScale = 1.0,
  });

  Future<LlamaCppModel> create(
    String ggufModelFilePath, {
    int rngSeed = 0xFFFFFFFF,
    required int contextWindowSize,
    promptBatchProcessingSize = 512,
    required int gpuLayers,
    int cudaMainGpu = 0,

    // TODO idk about this
    Pointer<Float>? cudaTensorSplit,
    ModelLoadingProgressCallback? progressCallback,
    bool useMmap = false,
    ropeFreqBase = 10000.0,
    ropeFreqScale = 1.0,
  }) async {
    return LlamaCppModel._(
        ggufModelFilePath: ggufModelFilePath,
        contextWindowSize: contextWindowSize,
        gpuLayers: gpuLayers);
  }
}
