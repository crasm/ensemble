import 'dart:io';
import 'dart:isolate';

import 'package:ensemble_llama/src/llama_cpp_isolate_wrapper.dart';

void main() async {
  var llama = await Llama.create();
  llama.log.listen((event) {
    print(event);
  });

  final progressListener = llama.response
      .where((event) => event is LoadModelProgressResp)
      .cast<LoadModelProgressResp>()
      .listen((a) {
    stdout.write("${(a.progress * 100).floor()}\r");
  });

  await llama.loadModel("/Users/vczf/models/default/ggml-model-f16.gguf");
  progressListener.cancel();
  // llama.dispose();
}

class Llama {
  late final Stream<LogMessage> log;
  late final Stream<ResponseMessage> response;

  final _logPort = ReceivePort();
  final _responsePort = ReceivePort();

  late final SendPort _controlPort;

  Llama._() {
    log = _logPort.asBroadcastStream().cast<LogMessage>();
    response = _responsePort.asBroadcastStream().cast<ResponseMessage>();
  }

  static Future<Llama> create() async {
    final llama = Llama._();

    Isolate.spawn(
        init,
        EntryArgs(
            log: llama._logPort.sendPort,
            response: llama._responsePort.sendPort));

    final resp = await llama.response.first as HandshakeResp;
    llama._controlPort = resp.controlPort;

    return llama;
  }

  Future<void> dispose() async {
    (await _controlPort).send(ExitCtl());
    await response.firstWhere((a) => a is ExitResp);
    _logPort.close();
    _responsePort.close();
  }

  Future<void> loadModel(String path) async {
    (await _controlPort).send(LoadModelCtl(path));
    await response.firstWhere((a) => a is LoadModelResp);
  }
}
