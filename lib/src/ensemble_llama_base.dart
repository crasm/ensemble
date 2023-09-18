import 'dart:io';
import 'dart:isolate';

import 'package:ensemble_llama/src/llama_cpp_isolate_wrapper.dart';

void main() async {
  var llama = await Llama.create();
  llama.log.listen((msg) {
    final msgText = msg.toString();
    if (!msgText.contains("llama_model_loader: - tensor")) {
      print(msgText);
    }
  });

  final model = await llama.loadModel(
      "/Users/vczf/models/default/ggml-model-f16.gguf",
    params: ContextParams(gpuLayers: 1, useMmap: false),
    progressCallback: (p) => stdout.write("${(p * 100).floor()}\r"),
  );

  print(model.rawPointer);
  llama.dispose();
}

class Llama {
  late final Stream<LogMessage> log;
  late final Stream<ResponseMessage> _response;

  final _logPort = ReceivePort();
  final _responsePort = ReceivePort();

  late final SendPort _controlPort;

  Llama._() {
    log = _logPort.asBroadcastStream().cast<LogMessage>();
    _response = _responsePort.asBroadcastStream().cast<ResponseMessage>();
  }

  static Future<Llama> create() async {
    final llama = Llama._();

    Isolate.spawn(
        init,
        EntryArgs(
            log: llama._logPort.sendPort,
            response: llama._responsePort.sendPort));

    final resp = await llama._response.first as HandshakeResp;
    llama._controlPort = resp.controlPort;

    return llama;
  }

  Future<void> dispose() async {
    _controlPort.send(ExitCtl());
    await _response.firstWhere((a) => a is ExitResp);
    _logPort.close();
    _responsePort.close();
  }

  Future<Model> loadModel(
    String path, {
    void Function(double progress)? progressCallback,
    ContextParams params = const ContextParams(),
  }) async {
    final progressListener = _response
        .where((event) => event is LoadModelProgressResp)
        .cast<LoadModelProgressResp>()
        .listen((a) => progressCallback?.call(a.progress));

    _controlPort.send(LoadModelCtl(path, params));
    final resp = (await _response.firstWhere((a) => a is LoadModelResp))
        as LoadModelResp;

    progressListener.cancel();
    resp.throwIfErr();
    return resp.model!;
  }
}
