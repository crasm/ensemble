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
  String toString() => "$runtimeType#$id";
}

final class ExitCtl extends ControlMessage {
  ExitResp done() => ExitResp(id);
}

final class InitModelCtl extends ControlMessage {
  final String path;
  final ModelParams params;
  InitModelCtl(this.path, this.params);
  @override
  String toString() => "LoadModelCtl#$id {\n  path: $path\n}"; // TODO: params?

  InitModelResp done(int modelId) => InitModelResp(id, modelId: modelId);
  InitModelResp error(Object err) => InitModelResp(id, err: err);
  InitModelProgressResp progress(double progress) => InitModelProgressResp(id, progress);
}

final class FreeModelCtl extends ControlMessage {
  final int model;
  FreeModelCtl(this.model);
  @override
  String toString() => "FreeModelCtl#$id{model: #$model}";

  FreeModelResp done() => FreeModelResp(id);
  FreeModelResp error(Object err) => FreeModelResp(id, err: err);
}

final class InitContextCtl extends ControlMessage {
  final int model;
  final ContextParams params;
  InitContextCtl(this.model, this.params);
  @override
  String toString() => "NewContextCtl#$id{model: #$model}"; // TODO: params?

  InitContextResp done(int ctxId) => InitContextResp(id, ctxId: ctxId);
  InitContextResp error(Object err) => InitContextResp(id, err: err);
}

final class FreeContextCtl extends ControlMessage {
  final int ctx;
  FreeContextCtl(this.ctx);
  @override
  String toString() => "FreeContextCtl#$id{ctx: #$ctx}";

  FreeContextResp done() => FreeContextResp(id);
  FreeContextResp error(Object err) => FreeContextResp(id, err: err);
}

final class TokenizeCtl extends ControlMessage {
  final int ctx;
  final String text;
  TokenizeCtl(this.ctx, this.text);
  @override
  String toString() => "TokenizeCtl#$id{ctx: #$ctx, text: ```$text```}";

  TokenizeResp done(List<Token> tokens, int firstTokenIndex) =>
      TokenizeResp(id, tokens: tokens, firstTokenIndex: firstTokenIndex);
  TokenizeResp error(Object err) => TokenizeResp(id, err: err);
}

final class EditCtl extends ControlMessage {
  final int ctx;
  final int? length;
  EditCtl(this.ctx, {this.length});
  @override
  String toString() => "EditCtl#$id{ctx: #$ctx, length: $length}";

  EditResp done() => EditResp(id);
  EditResp error(Object err) => EditResp(id, err: err);
}

final class IngestCtl extends ControlMessage {
  final int ctx;
  IngestCtl(this.ctx);
  @override
  String toString() => "IngestCtl#$id{ctx: #$ctx}";

  IngestResp done() => IngestResp(id);
  IngestResp error(Object err) => IngestResp(id, err: err);
}

final class GenerateCtl extends ControlMessage {
  final int ctx;
  final List<Sampler> samplers;
  GenerateCtl(this.ctx, this.samplers);
  @override
  String toString() =>
      "GenerateCtl#$id{ctx: #$ctx, samplers: [\n${samplers.map((s) => '  $s').join('\n')}\n]}";

  GenerateResp done() => GenerateResp(id);
  GenerateResp error(Object err) => GenerateResp(id, err: err);
  GenerateTokenResp token(Token tok) => GenerateTokenResp(id, tok);
  HandshakeResp handshake(SendPort port) => HandshakeResp(port, id);
}
