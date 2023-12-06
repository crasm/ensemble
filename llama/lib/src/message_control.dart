import 'dart:isolate';

import 'package:ensemble_llama/src/llama.dart';
import 'package:ensemble_llama/src/message_response.dart';
import 'package:ensemble_llama/src/params.dart';
import 'package:ensemble_llama/src/sampling.dart';

sealed class ControlMessage {
  static int _nextId = 1;
  final int id = _nextId++;
  ControlMessage();
  @override
  String toString() => "$runtimeType #$id";
}

final class ExitCtl extends ControlMessage {
  ExitResp done() => ExitResp(id);
}

final class LoadModelCtl extends ControlMessage {
  final String path;
  final ModelParams params;
  LoadModelCtl(this.path, this.params);
  @override
  String toString() => "LoadModelCtl #$id {\n  path: $path\n}"; // TODO: params?

  LoadModelResp done(Model model) => LoadModelResp(id, model: model);
  LoadModelResp error(Object err) => LoadModelResp(id, err: err);
  LoadModelProgressResp progress(double progress) => LoadModelProgressResp(id, progress);
}

final class FreeModelCtl extends ControlMessage {
  final Model model;
  FreeModelCtl(this.model);
  @override
  String toString() => "FreeModelCtl #$id { model: $model }";

  FreeModelResp done() => FreeModelResp(id);
  FreeModelResp error(Object err) => FreeModelResp(id, err: err);
}

final class NewContextCtl extends ControlMessage {
  final Model model;
  final ContextParams params;
  NewContextCtl(this.model, this.params);
  @override
  String toString() => "NewContextCtl #$id { model: $model }"; // TODO: params?

  NewContextResp done(Context ctx) => NewContextResp(id, ctx: ctx);
  NewContextResp error(Object err) => NewContextResp(id, err: err);
}

final class FreeContextCtl extends ControlMessage {
  final Context ctx;
  FreeContextCtl(this.ctx);
  @override
  String toString() => "FreeContextCtl #$id { ctx: $ctx }";

  FreeContextResp done() => FreeContextResp(id);
  FreeContextResp error(Object err) => FreeContextResp(id, err: err);
}

final class TokenizeCtl extends ControlMessage {
  final Context ctx;
  final String text;
  TokenizeCtl(this.ctx, this.text);
  @override
  String toString() => "TokenizeCtl #$id { ctx: $ctx, text: ```\n$text\n```}";

  TokenizeResp done(List<Token> tokens) => TokenizeResp(id, tokens: tokens);
  TokenizeResp error(Object err) => TokenizeResp(id, err: err);
}

final class IngestCtl extends ControlMessage {
  final Context ctx;
  IngestCtl(this.ctx);
  @override
  String toString() => "IngestCtl #$id { ctx: $ctx }";

  IngestResp done() => IngestResp(id);
  IngestResp error(Object err) => IngestResp(id, err: err);
}

final class GenerateCtl extends ControlMessage {
  final Context ctx;
  final List<Sampler> samplers;
  GenerateCtl(this.ctx, this.samplers);
  @override
  String toString() =>
      "GenerateCtl #$id { ctx: $ctx, samplers: [\n${samplers.map((s) => '  $s').join('\n')}\n]}";

  GenerateResp done() => GenerateResp(id);
  GenerateResp error(Object err) => GenerateResp(id, err: err);
  GenerateTokenResp token(Token tok) => GenerateTokenResp(id, tok);
  HandshakeResp handshake(SendPort port) => HandshakeResp(port, id);
}
