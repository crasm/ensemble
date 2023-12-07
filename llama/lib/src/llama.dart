import 'dart:isolate'; // for log events from llama.cpp

import 'package:logging/logging.dart';

import 'package:ensemble_llama/src/disposable.dart';
import 'package:ensemble_llama/src/isolate.dart';
import 'package:ensemble_llama/src/message_control.dart';
import 'package:ensemble_llama/src/message_response.dart';
import 'package:ensemble_llama/src/params.dart';
import 'package:ensemble_llama/src/sampling.dart';

typedef Token = ({int id, String text});

final class Model with Disposable {
  final Llama llama;
  final int id;
  Model._(this.llama, this.id);

  @override
  void dispose() async {
    llama.checkDisposed();
    super.dispose();
    await llama._send(FreeModelCtl(id));
  }

  @override
  String toString() => "Model#$id";

  @override
  bool operator ==(Object? other) => other is Model && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

final class Context with Disposable {
  static final _log = Logger('Context');

  final Llama llama;
  final Model model;
  final int id;

  final List<Token> tokens = [];

  Context._(this.llama, this.model, this.id);

  @override
  void dispose() async {
    llama.checkDisposed();
    model.checkDisposed();
    super.dispose();
    await llama._send(FreeContextCtl(id));
  }

  /// Tokenize and add [text] to this [ctx].
  ///
  /// This does not ingest or decode the text, so it computationally cheap.
  Future<List<Token>> add(String text) async {
    checkDisposed();
    final textTokens = (await llama._send<TokenizeResp>(TokenizeCtl(id, text))).tokens;
    tokens.addAll(textTokens);
    return tokens;
  }

  /// Clears and resets the stored tokens in [ctx].
  Future<void> clear() async {
    checkDisposed();
    setLength(0);
  }

  Future<void> setLength(int length) async {
    checkDisposed();
    await llama._send<EditResp>(EditCtl(id, length: length));
    tokens.length = length;
  }

  /// Decodes the tokens that have been added to this context.
  ///
  /// This is computationally expensive.
  Future<void> ingest() async {
    checkDisposed();
    await llama._send<IngestResp>(IngestCtl(id));
  }

  /// Runs inference to generate new tokens, constrained by [samplers].
  ///
  /// If no samplers are provided, greedy sampling will be used.
  ///
  Stream<Token> generate({
    List<Sampler> samplers = const [],
  }) async* {
    checkDisposed();
    SendPort? genPort;
    try {
      if (samplers.isEmpty) samplers = [Temperature(0.0)];

      final ctlId = await llama._sendCtl(GenerateCtl(id, samplers));
      await for (final resp in llama._responseStream) {
        if (resp.id != ctlId) continue;
        switch (resp) {
          case GenerateTokenResp():
            tokens.add(resp.tok);
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
      // This is necessary in the case that a token is generated (and therefore
      // altered and within the llama.cpp state) but we have already canceled
      // generation and stopped listening.
      //
      // This is very unlikely, since decoding tokens is much slower than
      // sending messages across isolates, and tokens are not committed before
      // checking for cancellation. However, I think it's possible if main is
      // starved for CPU and llama.cpp decodes tokens at full speed using GPU.
      await llama._send(EditCtl(id, length: tokens.length));
    }
  }

  @override
  String toString() => "Context#$id";

  @override
  bool operator ==(Object? other) => other is Context && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

final class Llama with Disposable {
  final _log = Logger('Llama');

  late final Stream<ResponseMessage> _responseStream;

  final _logPort = ReceivePort();
  final _responsePort = ReceivePort();

  late final Future<SendPort> _controlPort;

  Llama({bool? disableGgmlLog}) {
    _responseStream = _responsePort.asBroadcastStream().cast<ResponseMessage>();
    _responseStream.listen((e) => _log.finest(() => "got  $e"));
    _logPort.listen((e) {
      final record = e as LogRecord;
      _log.log(record.level, () => record.message);
    });

    Isolate.spawn(init, (
      response: _responsePort.sendPort,
      log: _logPort.sendPort,
      logLevel: Logger.root.level,
      disableGgmlLog: disableGgmlLog ?? false,
    ));

    _controlPort = _responseStream.first.then((resp) {
      return (resp as HandshakeResp).controlPort;
    });
  }

  @override
  Future<void> dispose() async {
    await _send(ExitCtl());
    _responsePort.close();
    _logPort.close();
    super.dispose(); // Have to call this last to avoid tripping checkDisposed()
  }

  Future<int> _sendCtl(ControlMessage ctl) async {
    checkDisposed();
    _log.finest(() => "sent $ctl");
    (await _controlPort).send(ctl);
    return ctl.id;
  }

  Future<T> _send<T extends ResponseMessage>(ControlMessage ctl) async {
    checkDisposed();
    final id = await _sendCtl(ctl);
    T resp = (await _responseStream.firstWhere(ResponseMessage.matches<T>(id))) as T;
    resp.throwIfErr();
    return resp;
  }

  Future<Model> initModel(
    String path, {
    void Function(double progress)? progressCallback,
    ModelParams? params,
  }) async {
    checkDisposed();
    final ctl = InitModelCtl(path, params ?? ModelParams());
    final progressListener = _responseStream
        .where(ResponseMessage.matches<InitModelProgressResp>(ctl.id))
        .cast<InitModelProgressResp>()
        .listen((e) => progressCallback?.call(e.progress));

    final resp = await _send<InitModelResp>(ctl);
    progressListener.cancel();
    return Model._(this, resp.modelId!);
  }

  Future<Context> initContext(Model model, {ContextParams? params}) async {
    checkDisposed();
    final ctl = InitContextCtl(model.id, params ?? ContextParams());
    final resp = await _send<InitContextResp>(ctl);
    return Context._(this, model, resp.ctxId!);
  }

  Stream<Token> generateFromPrompt({
    required String modelPath,
    required String prompt,
    void Function(double progress)? progressCallback,
    ModelParams? modelParams,
    ContextParams? contextParams,
    List<Sampler> samplers = const [],
  }) async* {
    checkDisposed();
    final disposables = <Disposable>[];
    try {
      final model =
          await initModel(modelPath, progressCallback: progressCallback, params: modelParams);
      disposables.add(model);

      final ctx = await initContext(model, params: contextParams);
      disposables.add(ctx);

      await ctx.add(prompt);
      await ctx.ingest();

      yield* ctx.generate(samplers: samplers);
    } finally {
      for (final d in disposables.reversed) {
        d.dispose();
      }
    }
  }
}
