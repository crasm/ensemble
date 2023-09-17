import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:ensemble_llama/ensemble_llama_cpp.dart';

sealed class ControlMessage {}

class ExitMessage extends ControlMessage {
  final SendPort ackPort;
  ExitMessage(this.ackPort);
}

class LlamaCpp {
  late final SendPort _log;
  late final SendPort _controlHelper;
  LlamaCpp({
    required SendPort log,
    required SendPort controlHelper,
  }) {
    _log = log;
    _controlHelper = controlHelper;
  }

  late final ReceivePort _control;
  void entryPoint(Map values) {
    _control = ReceivePort()..listen(_onControl);
    _controlHelper.send(_control.sendPort);

    libllama.llama_backend_init(false);
    _log.send("Hello from LLamaCpp");
  }

  void _onControl(dynamic msg) {
    switch (msg) {
      case ExitMessage():
        _dispose();
        msg.ackPort.send(1);
      default:
        print("unknown ControlMessage: $msg");
    }
  }

  void _onLlamaLog(int level, Pointer<Char> text, Pointer<Void> userData) {
    String msgText = text.cast<Utf8>().toDartString().trimRight();
    print("$level: $msgText");
  }

  void _dispose() {
    libllama.llama_backend_free();
  }
}
