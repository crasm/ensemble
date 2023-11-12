import 'dart:isolate';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:ensemble_llama/llama_ffi.dart';

import 'package:ensemble_llama/src/isolate.dart';
import 'package:ensemble_llama/src/message_control.dart';
import 'package:ensemble_llama/src/message_response.dart';
import 'package:ensemble_llama/src/params.dart';

final class Model {
  final int rawPointer;

  const Model(this.rawPointer);

  Pointer<llama_model> get pointer =>
      Pointer.fromAddress(rawPointer).cast<llama_model>();

  @override
  String toString() => "Model{$rawPointer}";
}

final class Context {
  final int rawPointer;
  final Model model;
  final ContextParams params;

  const Context(this.rawPointer, this.model, this.params);

  Pointer<llama_context> get pointer =>
      Pointer.fromAddress(rawPointer).cast<llama_context>();
}

final class Token {
  final int id;
  final String text;
  final String rawText;

  const Token(this.id, this.text, this.rawText);

  factory Token.fromId(Context ctx, int id) {
    final str = libllama
        .llama_token_get_text(ctx.pointer, id)
        .cast<Utf8>()
        .toDartString();
    return Token(
      id,
      str
          .replaceAll("▁", " ") // replace U+2581 with a space
          // TODO: is this the right approach here? What about other cases?
          .replaceAll("<0x0A>", "\n"),
      str,
    );
  }

  @override
  String toString() => text;
}

class LogMessage {
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

  Future<Context> newContext(Model model, [ContextParams? params]) async {
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
      Context ctx, String prompt, SamplingParams sparams) async* {
    final ctl = GenerateCtl(ctx, prompt, sparams);
    _controlPort.send(ctl);
    await for (final resp in _response) {
      if (resp.id != ctl.id) continue;
      switch (resp) {
        case GenerateTokenResp():
          yield resp.tok;
        case GenerateResp():
          resp.throwIfErr();
          return;
        default:
          throw AssertionError(
              "unexpected response ($resp), but valid id (${resp.id})");
      }
    }
  }
}
