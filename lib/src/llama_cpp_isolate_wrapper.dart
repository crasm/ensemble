import 'dart:ffi';
import 'dart:isolate';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:ensemble_llama/ensemble_llama_cpp.dart';
import 'package:ensemble_llama/src/ensemble_llama_base.dart' show ContextParams;

// 4294967295 (32 bit unsigned)
// -1 (32 bit signed)
const int32Max = 0xFFFFFFFF;

extension on llama_context_params {
  // Sets most of the context parameters, such as int, double, bool.
  // Does not set callbacks or pointers to allocated memory.
  void setSimpleFrom(ContextParams p) {
    seed = p.seed;
    n_ctx = p.contextSizeTokens;
    n_batch = p.batchSizeTokens;
    n_gpu_layers = p.gpuLayers;
    main_gpu = p.cudaMainGpu;

    // Skipping: tensor_split

    rope_freq_base = p.ropeFreqBase;
    rope_freq_scale = p.ropeFreqScale;

    // Skipping: progress_callback{,_user_data}

    low_vram = p.useLessVram;
    mul_mat_q = p.cudaUseMulMatQ;
    f16_kv = p.useFloat16KVCache;
    logits_all = p.computeAllLogits;
    vocab_only = p.loadOnlyVocabSkipTensors;
    use_mmap = p.useMmap;
    use_mlock = p.useMlock;
    embedding = p.embeddingModeOnly;
  }
}

class Model {
  final int _rawPointer;
  const Model._(this._rawPointer);
  Pointer<llama_model> get _ffiPointer =>
      Pointer.fromAddress(_rawPointer).cast<llama_model>();
  @override
  String toString() => "Model{$_rawPointer}";
}

class Context {
  final int _rawPointer;
  const Context._(this._rawPointer);
  Pointer<llama_context> get _ffiPointer =>
      Pointer.fromAddress(_rawPointer).cast<llama_context>();
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
  final id = Random().nextInt(int32Max);
  ControlMessage();
}

class ExitCtl extends ControlMessage {
  ExitResp done() => ExitResp(id);
}

class LoadModelCtl extends ControlMessage {
  final String path;
  final ContextParams params;
  LoadModelCtl(this.path, this.params);

  LoadModelResp done(Model model) => LoadModelResp(id, model: model);

  LoadModelResp error(Object err) => LoadModelResp(id, err: err);

  LoadModelProgressResp progress(double progress) =>
      LoadModelProgressResp(id, progress);
}

class FreeModelCtl extends ControlMessage {
  final Model model;
  FreeModelCtl(this.model);

  FreeModelResp done() => FreeModelResp(id);
}

class NewContextCtl extends ControlMessage {
  final Model model;
  final ContextParams params;
  NewContextCtl(this.model, this.params);

  NewContextResp done(Context ctx) => NewContextResp(id, ctx: ctx);

  NewContextResp error(Object err) => NewContextResp(id, err: err);
}

class FreeContextCtl extends ControlMessage {
  final Context ctx;
  FreeContextCtl(this.ctx);

  FreeContextResp done() => FreeContextResp(id);
}

sealed class ResponseMessage {
  final int id;
  final Object? err;
  const ResponseMessage(this.id, {this.err}) : assert(id <= int32Max);
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
  const LoadModelResp(super.id, {super.err, this.model});
}

class LoadModelProgressResp extends ResponseMessage {
  final double progress;
  const LoadModelProgressResp(super.id, this.progress);
}

class FreeModelResp extends ResponseMessage {
  const FreeModelResp(super.id);
}

class NewContextResp extends ResponseMessage {
  final Context? ctx;
  const NewContextResp(super.id, {super.err, this.ctx});
}

class FreeContextResp extends ResponseMessage {
  const FreeContextResp(super.id);
}

class EntryArgs {
  final SendPort log, response;
  const EntryArgs({required this.log, required this.response});
}

class _Allocations<E> {
  final Map<E, Set<Pointer>> _map = {};

  Set<Pointer>? operator [](E key) => _map[key];
  void operator []=(E key, Set<Pointer> allocs) => _map[key] = allocs;

  void clear(E key) => _map.remove(key);

  void add(E key, Pointer p) {
    _map[key] ??= {}..add(p);
    _map[key]!.add(p);
  }
}

final _modelAllocs = _Allocations<int>();
// final _ctxAllocs = _Allocations<int>();

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

void _onLlamaLog(int level, Pointer<Char> text, Pointer<Void> userData) =>
    _log.send(LogMessage(
        level: level, text: text.cast<Utf8>().toDartString().trimRight()));

void _onModelLoadProgress(double progress, Pointer<Void> id) =>
    _response.send(LoadModelProgressResp(id.cast<Uint32>().value, progress));

void _onControl(ControlMessage ctl) {
  switch (ctl) {
    case ExitCtl():
      _controlPort.close();
      libllama.llama_backend_free();
      _response.send(ctl.done());

    case LoadModelCtl():
      final Set<Pointer> allocs = {};
      final params = libllama.llama_context_default_params()
        ..setSimpleFrom(ctl.params);

      params.progress_callback = Pointer.fromFunction(_onModelLoadProgress);
      final idPointer = calloc.allocate<Uint32>(sizeOf<Uint32>());
      allocs.add(idPointer);
      idPointer.value = ctl.id;
      params.progress_callback_user_data = idPointer.cast<Void>();

      final rawModel = libllama
          .llama_load_model_from_file(
            ctl.path.toNativeUtf8().cast<Char>(),
            params,
          )
          .address;

      if (rawModel == 0) {
        _response
            .send(ctl.error(Exception("failed loading model: ${ctl.path}")));
        return;
      }

      _modelAllocs[rawModel] = allocs;
      _response.send(ctl.done(Model._(rawModel)));

    case FreeModelCtl():
      assert(ctl.model._rawPointer != 0);
      _modelAllocs[ctl.model._rawPointer]?.forEach((p) {
        calloc.free(p);
      });
      _modelAllocs.clear(ctl.model._rawPointer);

      libllama.llama_free_model(ctl.model._ffiPointer);
      _response.send(ctl.done());

    case NewContextCtl():
      assert(ctl.model._rawPointer != 0);
      final params = libllama.llama_context_default_params()
        ..setSimpleFrom(ctl.params);

      final rawCtx = libllama
          .llama_new_context_with_model(ctl.model._ffiPointer, params)
          .address;

      if (rawCtx == 0) {
        _response.send(ctl.error(Exception("failed creating context")));
        return;
      }

      _response.send(ctl.done(Context._(rawCtx)));

    case FreeContextCtl():
      libllama.llama_free(ctl.ctx._ffiPointer);
      _response.send(ctl.done());
  }
}
