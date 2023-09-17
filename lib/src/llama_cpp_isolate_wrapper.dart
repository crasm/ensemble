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

class _LlamaCpp {

  late final SendPort controlResponse;
  late final Stream<ControlMessage> control;
  late final ReceivePort controlPort;

  _LlamaCpp(this.controlResponse) {
    controlPort = ReceivePort();
    control = controlPort.cast<ControlMessage>()..listen(onControl);
    controlResponse.send(HandshakeResp(controlPort.sendPort));

    libllama.llama_backend_init(false);
    libllama.llama_log_set(
      Pointer.fromFunction(_onLlamaLog),
      Pointer.fromAddress(0), // not used
    );
  }

  void onControl(ControlMessage ctl) {
    switch (ctl) {
      case ExitCtl():
        dispose();
        controlResponse.send(ExitResp());

      case LoadModelCtl():
        var params = libllama.llama_context_default_params();
        params.n_gpu_layers = 1;
        // TODO NEXT:
        // params.progress_callback = Pointer.fromFunction(onModelLoadProgress);
        libllama.llama_load_model_from_file(
            ctl.path.toNativeUtf8().cast<Char>(), params);
    }
  }

  void dispose() {
    controlPort.close();
    libllama.llama_backend_free();
  }
}

class EntryArgs {
  final SendPort log, controlResponse;
  EntryArgs({
    required this.log,
    required this.controlResponse,
  });
}

SendPort? _log;
void entry(EntryArgs args) {
  _log = args.log;
  _LlamaCpp(args.controlResponse);
}

void _onLlamaLog(int level, Pointer<Char> text, Pointer<Void> userData) =>
    _log?.send(LogMessage(
        level: level, text: text.cast<Utf8>().toDartString().trimRight()));
