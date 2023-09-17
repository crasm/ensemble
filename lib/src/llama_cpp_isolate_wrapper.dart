import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:ensemble_llama/ensemble_llama_cpp.dart';

sealed class ControlMessage {}

class ExitCtl extends ControlMessage {}

sealed class ResponseMessage {}

class HandshakeResp extends ResponseMessage {
  final SendPort controlPort;
  HandshakeResp(this.controlPort);
}

class ExitResp extends ResponseMessage {}

class LlamaCpp {
  late final SendPort _log;
  late final SendPort _controlResponse;
  LlamaCpp({
    required SendPort log,
    required SendPort controlResponse,
  }) {
    _log = log;
    _controlResponse = controlResponse;
  }

  late final ReceivePort _control;
  void entryPoint(Map values) {
    _control = ReceivePort()..listen(_onControl);
    _controlResponse.send(HandshakeResp(_control.sendPort));

    libllama.llama_backend_init(false);
    libllama.llama_log_set(
      Pointer.fromFunction(_onLlamaLog),
      Pointer.fromAddress(0), // not used
    );
  }

  void _onControl(dynamic msg) {
    switch (msg) {
      case ExitCtl():
        _dispose();
        _controlResponse.send(ExitResp());
      default:
        throw Exception("unknown ControlMessage: $msg");
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
