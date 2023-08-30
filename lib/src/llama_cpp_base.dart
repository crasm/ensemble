// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

const LlamaLogLevelError = 2;
const LlamaLogLevelWarn = 3;
const LlamaLogLevelInfo = 4;

typedef LlamaProgressCallback = Void Function(
    Float progress, Pointer<Void> ctx);

final class LlamaContextParams extends Struct {
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

typedef LlamaContextDefaultParams = LlamaContextParams Function();

typedef LlamaBackendInitC = Void Function(Bool numa);
typedef LlamaBackendInit = void Function(bool numa);
typedef LlamaBackendFreeC = Void Function();
typedef LlamaBackendFree = void Function();

typedef LlamaModel = Pointer;
typedef LlamaLoadModelFromFile = LlamaModel Function(
    Pointer<Utf8> pathModel, LlamaContextParams params);

typedef LlamaLogCallbackC = Void Function(
    Int32 level, Pointer<Utf8> text, Pointer<Void> userData);
typedef LlamaLogCallback = void Function(
    int level, Pointer<Utf8> text, Pointer<Void> userData);

typedef LlamaPrintSystemInfo = Pointer<Utf8> Function();

typedef LlamaLogSetC = Void Function(
    LlamaLogCallbackC logCallback, Pointer<Void> userData);
typedef LlamaLogSet = Void Function(
    LlamaLogCallback logCallback, Pointer<Void> userData);

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
        .lookupFunction<LlamaBackendInitC, LlamaBackendInit>(
            'llama_backend_init')
        .call(false);
  }

  void dispose() {
    _libllama
        .lookupFunction<LlamaBackendFreeC, LlamaBackendFree>(
            'llama_backend_free')
        .call();
  }
}

LlamaContextParams contextDefaultParams() {
  return _LlamaCpp()
      ._libllama
      .lookupFunction<LlamaContextDefaultParams, LlamaContextDefaultParams>(
          isLeaf: true, 'llama_context_default_params')
      .call();
}

void loadModelFromFile(String pathModel, LlamaContextParams params) {
  _LlamaCpp()
      ._libllama
      .lookupFunction<LlamaLoadModelFromFile, LlamaLoadModelFromFile>(
          isLeaf: true, 'llama_load_model_from_file')
      .call(pathModel.toNativeUtf8(), params);
}

String systemInfo() {
  return _LlamaCpp()
      ._libllama
      .lookupFunction<LlamaPrintSystemInfo, LlamaPrintSystemInfo>(
        isLeaf: true,
        'llama_print_system_info',
      )
      .call()
      .toDartString();
}

void logSet(LlamaLogCallback logCallback, Pointer<Void> userData) {
  _LlamaCpp()
      ._libllama
      .lookupFunction<LlamaLogSet, LlamaLogSet>(isLeaf: true, 'llama_log_set')
      .call(logCallback, userData);
}
