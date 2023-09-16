import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:ensemble_llama/ensemble_llama_cpp.dart';

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

  void _onControl(dynamic ctl) {
    print("got control message: ${ctl['msg']}");
    (ctl['ack'] as SendPort).send("ok");
    _dispose();
  }

  void _onLlamaLog(int level, Pointer<Char> text, Pointer<Void> userData) {
    String msgText = text.cast<Utf8>().toDartString().trimRight();
    print("$level: $msgText");
  }

  void _dispose() {
    libllama.llama_backend_free();
  }
}
