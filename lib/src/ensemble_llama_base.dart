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

  late final Set<ReceivePort> _receivePorts = {};
  final ReceivePort _logPort = ReceivePort();

  late final Future<SendPort> _controlPort;

  late final LlamaCpp _isolateWrapper;
  Llama() {
    _receivePorts.add(_logPort);
    log = _logPort.cast<String>();

    final controlHelper = ReceivePort();
    _isolateWrapper =
        LlamaCpp(log: _logPort.sendPort, controlHelper: controlHelper.sendPort);
    Isolate.spawn(_isolateWrapper.entryPoint, {});

    _controlPort = controlHelper.first.then((sp) {
      controlHelper.close();
      print("got controller from isolate");
      return sp;
    });
  }

  // TODO: - define control message types as enum or something
  //       - avoid creating temp ReceivePorts by making a ctlresponse broadcast stream
  Future<void> dispose() async {
    final ack = ReceivePort();
    (await _controlPort).send(ExitMessage(ack.sendPort));
    print(await ack.first);
    ack.close();
    for (var p in _receivePorts) {
      p.close();
    }
  }
}
