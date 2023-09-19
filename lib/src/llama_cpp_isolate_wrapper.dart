import 'dart:ffi';
import 'dart:isolate';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:ensemble_llama/ensemble_llama_cpp.dart';

// 4294967295 (32 bit unsigned)
// -1 (32 bit signed)
const _int32Max = 0xFFFFFFFF;

class ContextParams {
  final int seed;
  final int contextSizeTokens;
  final int batchSizeTokens;
  final int gpuLayers;
  final int cudaMainGpu;
  // final List<double> cudaTensorSplits;
  final double ropeFreqBase;
  final double ropeFreqScale;
  final bool useLessVram;
  final bool cudaUseMulMatQ;
  final bool useFloat16KVCache;
  final bool calculateAllLogits;
  final bool loadOnlyVocabSkipTensors;
  final bool useMmap;
  final bool useMlock;
  final bool willUseEmbedding;

  const ContextParams({
    this.seed = _int32Max,
    this.contextSizeTokens = 512,
    this.batchSizeTokens = 512,
    this.gpuLayers = 0,
    this.cudaMainGpu = 0,
    // this.cudaTensorSplits = const [0.0],
    this.ropeFreqBase = 10000.0,
    this.ropeFreqScale = 1.0,
    this.useLessVram = false,
    this.cudaUseMulMatQ = true,
    this.useFloat16KVCache = true,
    this.calculateAllLogits = false,
    this.loadOnlyVocabSkipTensors = false,
    this.useMmap = true,
    this.useMlock = false,
    this.willUseEmbedding = false,
  }) : assert(seed <= _int32Max);
}

class LogMessage {
  final int level;
  final String text;
  const LogMessage({
    required this.level,
    required this.text,
  });

  @override
  String toString() {
    String levelStr = switch (level) {
      llama_log_level.LLAMA_LOG_LEVEL_ERROR => 'ERROR',
      llama_log_level.LLAMA_LOG_LEVEL_WARN => 'WARN',
      llama_log_level.LLAMA_LOG_LEVEL_INFO => 'INFO',
      _ => throw Exception("Unknown log level: $level"),
    };

    return "$levelStr: $text";
  }
}

sealed class ControlMessage {
  final id = Random().nextInt(_int32Max);
  ControlMessage();
}

class ExitCtl extends ControlMessage {
  ExitResp done() {
    return ExitResp(id);
  }
}
class LoadModelCtl extends ControlMessage {
  final String path;
  final ContextParams ctxParams;
  LoadModelCtl(this.path, this.ctxParams);

  LoadModelResp done(Model model) {
    return LoadModelResp(id, model: model);
  }

  LoadModelResp error(Object err) {
    return LoadModelResp(id, err: err);
  }

  LoadModelProgressResp progress(double progress) {
    return LoadModelProgressResp(id, progress);
  }
}

sealed class ResponseMessage {
  final int id;
  final Object? err;
  const ResponseMessage(this.id, {this.err}) : assert(id <= _int32Max);
  void throwIfErr() {
    if (err != null) {
      throw err!;
    }
  }
}

class HandshakeResp extends ResponseMessage {
  final SendPort controlPort;
  const HandshakeResp(this.controlPort, [super.id = 0]);
}

class ExitResp extends ResponseMessage {
  const ExitResp(super.id);
}

// TODO: include mem used, model details?
class LoadModelResp extends ResponseMessage {
  final Model? model;
  const LoadModelResp(super.id, {
    super.err,
    this.model
  });
}

class LoadModelProgressResp extends ResponseMessage {
  final double progress;
  const LoadModelProgressResp(super.id, this.progress);
}

class EntryArgs {
  final SendPort log, response;
  const EntryArgs({
    required this.log,
    required this.response,
  });
}

// Map from raw pointer to the Model object we pass back to the main isolate.
final Map<int, Model> _models = {};

class Model {
  final int rawPointer;
  const Model._(this.rawPointer);
}

late final SendPort _log;
late final SendPort _response;

final ReceivePort _controlPort = ReceivePort();
final Stream<ControlMessage> _control = _controlPort.cast<ControlMessage>();

void init(EntryArgs args) {
  _log = args.log;
  _response = args.response;

  _control.listen(_onControl);
  _response.send(HandshakeResp(_controlPort.sendPort));

  libllama.llama_backend_init(false);
  libllama.llama_log_set(
    Pointer.fromFunction(_onLlamaLog),
    Pointer.fromAddress(0), // not used
  );
}

void _free() {
  _controlPort.close();
  libllama.llama_backend_free();
}

void _onLlamaLog(int level, Pointer<Char> text, Pointer<Void> userData) =>
    _log.send(LogMessage(
        level: level, text: text.cast<Utf8>().toDartString().trimRight()));

void _onModelLoadProgress(double progress, Pointer<Void> id) {
  _response.send(LoadModelProgressResp(id.cast<Uint32>().value, progress));
}

void _onControl(ControlMessage ctl) {
  switch (ctl) {
    case ExitCtl():
      _free();
      _response.send(ctl.done());

    case LoadModelCtl():
      final pd = ctl.ctxParams;
      final pc = libllama.llama_context_default_params();

      pc.seed = pd.seed;
      pc.n_ctx = pd.contextSizeTokens;
      pc.n_batch = pd.batchSizeTokens;
      pc.n_gpu_layers = pd.gpuLayers;
      pc.main_gpu = pd.cudaMainGpu;

      // TODO: can't do this until we track contexts to manage memory allocation
      // pc.tensor_split

      pc.rope_freq_base = pd.ropeFreqBase;
      pc.rope_freq_scale = pd.ropeFreqScale;

      pc.progress_callback = Pointer.fromFunction(_onModelLoadProgress);
      final idPointer = calloc.allocate<Uint32>(sizeOf<Uint32>());
      idPointer.value = ctl.id;
      pc.progress_callback_user_data = idPointer.cast<Void>();

      pc.low_vram = pd.useLessVram;
      pc.mul_mat_q = pd.cudaUseMulMatQ;
      pc.f16_kv = pd.useFloat16KVCache;
      pc.logits_all = pd.calculateAllLogits;
      pc.vocab_only = pd.loadOnlyVocabSkipTensors;
      pc.use_mmap = pd.useMmap;
      pc.use_mlock = pd.useMlock;
      pc.embedding = pd.willUseEmbedding;

      final rawModelPointer = libllama
          .llama_load_model_from_file(
            ctl.path.toNativeUtf8().cast<Char>(),
            pc,
          )
          .address;

      if (rawModelPointer == 0) {
        _response.send(ctl.error(
          Exception("failed loading model: ${ctl.path}"),
        ));
        return;
      }

      final model = Model._(rawModelPointer);
      _models[rawModelPointer] = model;

      _response.send(ctl.done(model));
  }
}
