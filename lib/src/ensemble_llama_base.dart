import 'dart:isolate';

import 'package:ensemble_llama/src/llama_cpp_isolate_wrapper.dart';

class ContextParams {
  final int seed;
  final int contextSizeTokens;
  final int batchSizeTokens;
  final int gpuLayers;
  final int cudaMainGpu;
  // final List<double> cudaTensorSplits;
  final double ropeFreqBase;
  final double ropeFreqScale;
  final bool useLessVram;
  final bool cudaUseMulMatQ;
  final bool useFloat16KVCache;
  final bool computeAllLogits;
  final bool loadOnlyVocabSkipTensors;
  final bool useMmap;
  final bool useMlock;
  final bool embeddingModeOnly;

  const ContextParams({
    this.seed = int32Max,
    this.contextSizeTokens = 512,
    this.batchSizeTokens = 512,
    this.gpuLayers = 0,
    this.cudaMainGpu = 0,
    // this.cudaTensorSplits = const [0.0],
    this.ropeFreqBase = 10000.0,
    this.ropeFreqScale = 1.0,
    this.useLessVram = false,
    this.cudaUseMulMatQ = true,
    this.useFloat16KVCache = true,
    this.computeAllLogits = false,
    this.loadOnlyVocabSkipTensors = false,
    this.useMmap = true,
    this.useMlock = false,
    this.embeddingModeOnly = false,
  }) : assert(seed <= int32Max);
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
    assert(resp.id == 0);
    assert(resp.err == null);

    llama._controlPort = resp.controlPort;
    return llama;
  }

  Future<void> dispose() async {
    final ctl = ExitCtl();
    _controlPort.send(ctl);
    await _response.firstWhere((e) => e is ExitResp && e.id == ctl.id);
    _logPort.close();
    _responsePort.close();
  }

  Future<Model> loadModel(
    String path, {
    void Function(double progress)? progressCallback,
    ContextParams params = const ContextParams(),
  }) async {
    final ctl = LoadModelCtl(path, params);
    final progressListener = _response
        .where((e) => e is LoadModelProgressResp && e.id == ctl.id)
        .cast<LoadModelProgressResp>()
        .listen((e) => progressCallback?.call(e.progress));

    _controlPort.send(ctl);
    final resp = (await _response.firstWhere(
        (e) => e is LoadModelResp && e.id == ctl.id)) as LoadModelResp;

    progressListener.cancel();
    resp.throwIfErr();
    return resp.model!;
  }

  Future<void> freeModel(Model model) async {
    final ctl = FreeModelCtl(model);
    _controlPort.send(ctl);
    await _response.firstWhere((e) => e is FreeModelResp && e.id == ctl.id);
  }

  Future<Context> newContext(Model model, ContextParams params) async {
    final ctl = NewContextCtl(model, params);
    _controlPort.send(ctl);
    final resp = await _response.firstWhere(
        (e) => e is NewContextResp && e.id == ctl.id) as NewContextResp
      ..throwIfErr();
    return resp.ctx!;
  }

  Future<void> freeContext(Context ctx) async {
    final ctl = FreeContextCtl(ctx);
    _controlPort.send(ctl);
    await _response.firstWhere((e) => e is FreeContextResp && e.id == ctl.id);
  }
}
