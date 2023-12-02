import 'dart:isolate';

import 'package:ensemble_llama/llama_ffi.dart' show ggml_log_level;

import 'package:ensemble_llama/src/isolate.dart';
import 'package:ensemble_llama/src/message_control.dart';
import 'package:ensemble_llama/src/message_response.dart';
import 'package:ensemble_llama/src/params.dart';
import 'package:ensemble_llama/src/sampling.dart';

typedef Model = int;
typedef Context = int;
typedef Token = ({int id, String text});

final class LogMessage {
  final int level;
  final String text;
  const LogMessage({
    required this.level,
    required this.text,
  });

  @override
  String toString() {
    String levelStr = switch (level) {
      ggml_log_level.GGML_LOG_LEVEL_ERROR => 'ERROR',
      ggml_log_level.GGML_LOG_LEVEL_WARN => 'WARN',
      ggml_log_level.GGML_LOG_LEVEL_INFO => 'INFO',
      _ => throw Exception("Unknown log level: $level"),
    };

    return "$levelStr: $text";
  }
}

final class Llama {
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
      (log: llama._logPort.sendPort, response: llama._responsePort.sendPort),
    );

    final resp = await llama._response.first as HandshakeResp;
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
    ModelParams? params,
  }) async {
    final ctl = LoadModelCtl(path, params ?? ModelParams());
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

  Future<Context> newContext(Model model, {ContextParams? params}) async {
    final ctl = NewContextCtl(model, params ?? ContextParams());
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

  Future<List<Token>> tokenize(Context ctx, String prompt) async {
    final ctl = TokenizeCtl(ctx, prompt);
    _controlPort.send(ctl);
    final resp = await _response.firstWhere(
      (e) => e is TokenizeResp && e.id == ctl.id,
    ) as TokenizeResp
      ..throwIfErr();
    return resp.tokens;
  }

  Stream<Token> generate(
    Context ctx,
    String prompt, {
    List<Sampler> samplers = const [],
  }) async* {
    SendPort? genPort;
    try {
      if (samplers.isEmpty) {
        samplers = [Temperature(0.0)];
      }
      final ctl = GenerateCtl(ctx, prompt, samplers);
      _controlPort.send(ctl);
      await for (final resp in _response) {
        if (resp.id != ctl.id) continue;
        switch (resp) {
          case GenerateTokenResp():
            yield resp.tok;
          case GenerateResp():
            resp.throwIfErr();
            return;
          case HandshakeResp():
            genPort = resp.controlPort;
          default:
            throw AssertionError(
                "unexpected response ($resp), but valid id (${resp.id})");
        }
      }
    } finally {
      genPort?.send(0);
    }
  }
}
