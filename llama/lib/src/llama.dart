import 'dart:isolate'; // for log events from llama.cpp

import 'package:logging/logging.dart';

import 'package:ensemble_llama/src/disposable.dart';
import 'package:ensemble_llama/src/isolate.dart';
import 'package:ensemble_llama/src/message_control.dart';
import 'package:ensemble_llama/src/message_response.dart';
import 'package:ensemble_llama/src/params.dart';
import 'package:ensemble_llama/src/sampling.dart';

typedef Model = int;
typedef Context = int;
typedef Token = ({int id, String text});

final class Llama with Disposable {
  final _log = Logger('Llama');

  late final Stream<ResponseMessage> _responseStream;

  final _logPort = ReceivePort();
  final _responsePort = ReceivePort();

  late final SendPort _controlPort;

  Llama._() {
    _responseStream = _responsePort.asBroadcastStream().cast<ResponseMessage>();
  }

  static Future<Llama> create({bool? disableGgmlLog}) async {
    final llama = Llama._();

    Isolate.spawn(init, (
      response: llama._responsePort.sendPort,
      log: llama._logPort.sendPort,
      logLevel: Logger.root.level,
      disableGgmlLog: disableGgmlLog ?? false,
    ));

    final resp = await llama._responseStream.first as HandshakeResp;
    llama._controlPort = resp.controlPort;

    llama._responseStream.listen((e) {
      llama._log.finest(() => " got $e");
    });

    llama._logPort.listen((e) {
      // _log._publish(e as LogRecord);
      final record = e as LogRecord;
      llama._log.log(record.level, () => record.message);
    });

    return llama;
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _send(ExitCtl());
    _responsePort.close();
    _logPort.close();
  }

  int _sendCtl(ControlMessage ctl) {
    _log.finest(() => "sent $ctl");
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
