import 'dart:isolate';

import 'package:console/console.dart';

import 'package:ensemble_llama/src/llama_cpp_isolate_wrapper.dart';

void main() {
  Console.init();
  final pbar = ProgressBar(complete: 100);

  var llama = Llama("/Users/vczf/models/default/ggml-model-f16.gguf");
  llama.log.listen((event) {
    print(event);
  });

  llama.response
      .where((event) => event is ModelLoadProgressResp)
      .cast<ModelLoadProgressResp>()
      .listen((a) {
    pbar.update((a.progress * 100).floor());
  });

  // llama.dispose();
}

class Llama {
  late final Stream<LogMessage> log;
  late final Stream<ResponseMessage> response;

  late final Set<ReceivePort> _receivePorts = {};

  late final Future<SendPort> _controlPort;

  Llama(String path) {
    final logPort = ReceivePort();
    final responsePort = ReceivePort();
    _receivePorts.addAll([logPort, responsePort]);
    log = logPort
        .asBroadcastStream(
          onCancel: (s) => s.pause(),
          onListen: (s) => s.resume(), // if paused, resumes
        )
        .cast<LogMessage>();
    response = responsePort
        .asBroadcastStream(
          onCancel: (s) => s.pause(),
          onListen: (s) => s.resume(), // if paused, resumes
        )
        .cast<ResponseMessage>();

    Isolate.spawn(
        init,
        EntryArgs(
            log: logPort.sendPort,
            response: responsePort.sendPort));

    _controlPort = response.first.then((sp) {
      assert(sp is HandshakeResp);
      return (sp as HandshakeResp).controlPort;
    });

    _controlPort.then((ctl) => ctl.send(LoadModelCtl(path)));
  }

  Future<void> dispose() async {
    (await _controlPort).send(ExitCtl());
    await response.firstWhere((a) => a is ExitResp);
    for (var p in _receivePorts) {
      p.close();
    }
  }
}
