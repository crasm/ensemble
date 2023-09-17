import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:ensemble_llama/ensemble_llama_cpp.dart';

class LogMessage {
  final int level;
  final String text;
  LogMessage({
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

sealed class ControlMessage {}

class ExitCtl extends ControlMessage {}
class LoadModelCtl extends ControlMessage {
  final String path;
  LoadModelCtl(this.path);
}

sealed class ResponseMessage {}

class HandshakeResp extends ResponseMessage {
  final SendPort controlPort;
  HandshakeResp(this.controlPort);
}

class ExitResp extends ResponseMessage {}

class ModelLoadProgressResp extends ResponseMessage {
  final double progress;
  ModelLoadProgressResp(this.progress);
}

class EntryArgs {
  final SendPort log, response;
  EntryArgs({
    required this.log,
    required this.response,
  });
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

void _onModelLoadProgress(double progress, Pointer<Void> ctx) {
  _response.send(ModelLoadProgressResp(progress));
}

void _onControl(ControlMessage ctl) {
  switch (ctl) {
    case ExitCtl():
      _free();
      _response.send(ExitResp());

    case LoadModelCtl():
      var params = libllama.llama_context_default_params();
      params.n_gpu_layers = 1;
      params.use_mmap = false;
      params.progress_callback = Pointer.fromFunction(_onModelLoadProgress);
      libllama.llama_load_model_from_file(
          ctl.path.toNativeUtf8().cast<Char>(), params);
  }
}

