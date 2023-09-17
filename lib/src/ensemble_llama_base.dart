import 'dart:isolate';

import 'package:ensemble_llama/src/llama_cpp_isolate_wrapper.dart';

void main() {
  var llama = Llama("/Users/vczf/models/default/ggml-model-f16.gguf");
  llama.log.listen((event) {
    print(event);
  });

  // llama.dispose();
}

class Llama {
  late final Stream<LogMessage> log;
  late final Stream<ResponseMessage> _controlResponse;

  late final Set<ReceivePort> _receivePorts = {};

  late final Future<SendPort> _controlPort;

  Llama(String path) {
    final logPort = ReceivePort();
    final controlResponsePort = ReceivePort();
    _receivePorts.addAll([logPort, controlResponsePort]);
    log = logPort
        .asBroadcastStream(
          onCancel: (s) => s.pause(),
          onListen: (s) => s.resume(), // if paused, resumes
        )
        .cast<LogMessage>();
    _controlResponse = controlResponsePort
        .asBroadcastStream(
          onCancel: (s) => s.pause(),
          onListen: (s) => s.resume(), // if paused, resumes
        )
        .cast<ResponseMessage>();

    Isolate.spawn(
        entry,
        EntryArgs(
            log: logPort.sendPort,
            controlResponse: controlResponsePort.sendPort));

    _controlPort = _controlResponse.first.then((sp) {
      assert(sp is HandshakeResp);
      return (sp as HandshakeResp).controlPort;
    });

    _controlPort.then((ctl) => ctl.send(LoadModelCtl(path)));
  }

  Future<void> dispose() async {
    (await _controlPort).send(ExitCtl());
    await _controlResponse.firstWhere((a) => a is ExitResp);
    for (var p in _receivePorts) {
      p.close();
    }
  }
}
