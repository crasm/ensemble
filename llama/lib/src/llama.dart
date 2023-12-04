import 'dart:isolate';

import 'package:logging/logging.dart';

import 'package:ensemble_llama/llama_ffi.dart' show ggml_log_level;

import 'package:ensemble_llama/src/disposable.dart';
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

final class Llama with Disposable {
  final _log = Logger('Llama');

  late final Stream<LogMessage> log;
  late final Stream<ResponseMessage> _responseStream;

  final _logPort = ReceivePort();
  final _responsePort = ReceivePort();

  late final SendPort _controlPort;

  Llama._() {
    log = _logPort.asBroadcastStream().cast<LogMessage>();
    _responseStream = _responsePort.asBroadcastStream().cast<ResponseMessage>();
  }

  static Future<Llama> create() async {
    final llama = Llama._();

    Isolate.spawn(
      init,
      (log: llama._logPort.sendPort, response: llama._responsePort.sendPort),
    );

    final resp = await llama._responseStream.first as HandshakeResp;
    llama._controlPort = resp.controlPort;

    llama._responseStream.listen((e) {
      llama._log.finest(() => "received resp $e");
    });
    return llama;
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _send(ExitCtl());
    _logPort.close();
    _responsePort.close();
  }

  int _sendCtl(ControlMessage ctl) {
    _log.finest(() => "sent ctl $ctl");
    _controlPort.send(ctl);
    return ctl.id;
  }

  Future<T> _send<T extends ResponseMessage>(ControlMessage ctl) async {
    final id = _sendCtl(ctl);
    T resp =
        (await _responseStream.firstWhere(ResponseMessage.matches<T>(id))) as T;
    resp.throwIfErr();
    return resp;
  }

  Future<Model> loadModel(
    String path, {
    void Function(double progress)? progressCallback,
    ModelParams? params,
  }) async {
    checkDisposed();
    final ctl = LoadModelCtl(path, params ?? ModelParams());
    final progressListener = _responseStream
        .where(ResponseMessage.matches<LoadModelProgressResp>(ctl.id))
        .cast<LoadModelProgressResp>()
        .listen((e) => progressCallback?.call(e.progress));

    final resp = await _send<LoadModelResp>(ctl);
    progressListener.cancel();
    return resp.model!;
  }

  Future<void> freeModel(Model model) async {
    checkDisposed();
    await _send(FreeModelCtl(model));
  }

  Future<Context> newContext(Model model, {ContextParams? params}) async {
    checkDisposed();
    final ctl = NewContextCtl(model, params ?? ContextParams());
    final resp = await _send<NewContextResp>(ctl);
    return resp.ctx!;
  }

  Future<void> freeContext(Context ctx) async {
    checkDisposed();
    await _send(FreeContextCtl(ctx));
  }

  Future<List<Token>> tokenize(Context ctx, String prompt) async {
    checkDisposed();
    final resp = await _send<TokenizeResp>(
      TokenizeCtl(ctx, prompt, addBos: true),
    );
    return resp.tokens;
  }

  Stream<Token> generate(
    Context ctx,
    String prompt, {
    List<Sampler> samplers = const [],
  }) async* {
    checkDisposed();
    SendPort? genPort;
    try {
      if (samplers.isEmpty) samplers = [Temperature(0.0)];

      await _send(TokenizeCtl(ctx, prompt, addBos: true));
      await _send(IngestCtl(ctx));

      final id = _sendCtl(GenerateCtl(ctx, samplers));
      await for (final resp in _responseStream) {
        if (resp.id != id) continue;
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
