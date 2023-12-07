import 'dart:isolate'; // for log events from llama.cpp

import 'package:logging/logging.dart';

import 'package:ensemble_llama/src/disposable.dart';
import 'package:ensemble_llama/src/isolate.dart';
import 'package:ensemble_llama/src/message_control.dart';
import 'package:ensemble_llama/src/message_response.dart';
import 'package:ensemble_llama/src/params.dart';
import 'package:ensemble_llama/src/sampling.dart';

final class Model {
  final int id;
  const Model(this.id);

  @override
  String toString() => "Model#$id";

  @override
  bool operator ==(Object? other) => other is Model && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

final class Context {
  final int id;
  const Context(this.id);

  @override
  String toString() => "Context#$id";

  @override
  bool operator ==(Object? other) => other is Context && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

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
      llama._log.finest(() => "got  $e");
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
    T resp = (await _responseStream.firstWhere(ResponseMessage.matches<T>(id))) as T;
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

  /// Tokenize and add [text] to this [ctx].
  ///
  /// This does not ingest or decode the text, so it computationally cheap.
  Future<List<Token>> add(Context ctx, String text) async {
    checkDisposed();
    final tokens = (await _send<TokenizeResp>(TokenizeCtl(ctx, text))).tokens;
    return tokens;
  }

  /// Clears and resets the stored tokens in [ctx].
  Future<void> clear(Context ctx) async {
    checkDisposed();
    await _send<EditResp>(EditCtl(ctx, length: 0));
  }

  /// Decodes the tokens that have been added to [ctx].
  ///
  /// This is computationally expensive.
  Future<void> ingest(Context ctx) async {
    checkDisposed();
    await _send<IngestResp>(IngestCtl(ctx));
  }

  /// Runs inference to generate new tokens, constrained by [samplers].
  ///
  /// If no samplers are provided, greedy sampling will be used.
  ///
  /// If [prompt] is not null, then any existing token state in [ctx] will be
  /// cleared and [prompt] will be added to the context/ingested.
  Stream<Token> generate(
    Context ctx, {
    String? prompt,
    List<Sampler> samplers = const [],
  }) async* {
    checkDisposed();
    SendPort? genPort;
    try {
      if (samplers.isEmpty) samplers = [Temperature(0.0)];
      if (prompt != null) {
        await clear(ctx);
        await add(ctx, prompt);
        _log.info("set context tokens to prompt");
        await ingest(ctx);
        _log.info("finished ingesting prompt");
      }

      final id = _sendCtl(GenerateCtl(ctx, samplers));
      await for (final resp in _responseStream) {
        if (resp.id != id) continue;
        switch (resp) {
          case GenerateTokenResp():
            yield resp.tok;
          case GenerateResp():
            genPort = null;
            resp.throwIfErr();
            return;
          case HandshakeResp():
            genPort = resp.controlPort;
          default:
            throw AssertionError("unexpected response ($resp), but valid id (${resp.id})");
        }
      }
    } finally {
      if (genPort != null) {
        genPort.send(0);
        _log.info("generation canceled");
      }
    }
  }
}
