import 'dart:io';
import 'dart:isolate';

import 'package:ensemble_llama/src/llama_cpp_isolate_wrapper.dart';

void main() {
  var llama = Llama();
  llama.log.listen((event) {
    print(event);
  });

  final progressListener = llama.response
      .where((event) => event is LoadModelProgressResp)
      .cast<LoadModelProgressResp>()
      .listen((a) {
    stdout.write("${(a.progress * 100).floor()}\r");
  });

  llama
      .loadModel("/Users/vczf/models/default/ggml-model-f16.gguf")
      .then((_) => progressListener.cancel());
  // llama.dispose();
}

class Llama {
  late final Stream<LogMessage> log;
  late final Stream<ResponseMessage> response;

  late final Set<ReceivePort> _receivePorts = {};

  late final Future<SendPort> _controlPort;

  Llama() {
    final logPort = ReceivePort();
    final responsePort = ReceivePort();
    _receivePorts.addAll([logPort, responsePort]);
    log = logPort.asBroadcastStream().cast<LogMessage>();
    response = responsePort.asBroadcastStream().cast<ResponseMessage>();

    Isolate.spawn(
        init,
        EntryArgs(
            log: logPort.sendPort,
            response: responsePort.sendPort));

    _controlPort = response.first.then((sp) {
      assert(sp is HandshakeResp);
      return (sp as HandshakeResp).controlPort;
    });
  }

  Future<void> dispose() async {
    (await _controlPort).send(ExitCtl());
    await response.firstWhere((a) => a is ExitResp);
    for (var p in _receivePorts) {
      p.close();
    }
  }

  Future<void> loadModel(String path) async {
    (await _controlPort).send(LoadModelCtl(path));
    await response.firstWhere((a) => a is LoadModelResp);
  }
}
