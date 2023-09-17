import 'dart:isolate';

import 'package:ensemble_llama/src/llama_cpp_isolate_wrapper.dart';

void main() {
  var llama = Llama();
  llama.log.listen((event) {
    print(event);
  });

  llama.dispose();
}

class Llama {
  late final Stream<String> log;
  late final Stream<ResponseMessage> _controlResponse;

  late final Set<ReceivePort> _receivePorts = {};

  late final Future<SendPort> _controlPort;

  late final LlamaCpp _isolateWrapper;
  Llama() {
    final logPort = ReceivePort();
    final controlResponsePort = ReceivePort();
    _receivePorts.addAll([logPort, controlResponsePort]);
    log = logPort
        .asBroadcastStream(
          onCancel: (s) => s.pause(),
          onListen: (s) => s.resume(), // if paused, resumes
        )
        .cast<String>();
    _controlResponse = controlResponsePort
        .asBroadcastStream(
          onCancel: (s) => s.pause(),
          onListen: (s) => s.resume(), // if paused, resumes
        )
        .cast<ResponseMessage>();

    _isolateWrapper = LlamaCpp(
        log: logPort.sendPort, controlResponse: controlResponsePort.sendPort);
    Isolate.spawn(_isolateWrapper.entryPoint, {});

    _controlPort = _controlResponse.first.then((sp) {
      assert(sp is HandshakeResp);
      return (sp as HandshakeResp).controlPort;
    });
  }

  Future<void> dispose() async {
    (await _controlPort).send(ExitCtl());
    await _controlResponse.firstWhere((a) => a is ExitResp);
    for (var p in _receivePorts) {
      p.close();
    }
  }
}
