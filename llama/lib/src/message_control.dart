import 'dart:isolate';

import 'package:ensemble_llama/src/llama.dart';
import 'package:ensemble_llama/src/message_response.dart';
import 'package:ensemble_llama/src/params.dart';
import 'package:ensemble_llama/src/sampling.dart';

sealed class ControlMessage {
  static int _nextId = 1;
  final int id = _nextId++;
  ControlMessage();
}

final class ExitCtl extends ControlMessage {
  ExitResp done() => ExitResp(id);
}

final class LoadModelCtl extends ControlMessage {
  final String path;
  final ModelParams params;
  LoadModelCtl(this.path, this.params);

  LoadModelResp done(Model model) => LoadModelResp(id, model: model);
  LoadModelResp error(Object err) => LoadModelResp(id, err: err);
  LoadModelProgressResp progress(double progress) =>
      LoadModelProgressResp(id, progress);
}

final class FreeModelCtl extends ControlMessage {
  final Model model;
  FreeModelCtl(this.model);

  FreeModelResp done() => FreeModelResp(id);
  FreeModelResp error(Object err) => FreeModelResp(id, err: err);
}

final class NewContextCtl extends ControlMessage {
  final Model model;
  final ContextParams params;
  NewContextCtl(this.model, this.params);

  NewContextResp done(Context ctx) => NewContextResp(id, ctx: ctx);
  NewContextResp error(Object err) => NewContextResp(id, err: err);
}

final class FreeContextCtl extends ControlMessage {
  final Context ctx;
  FreeContextCtl(this.ctx);

  FreeContextResp done() => FreeContextResp(id);
  FreeContextResp error(Object err) => FreeContextResp(id, err: err);
}

final class TokenizeCtl extends ControlMessage {
  final Context ctx;
  final String text;
  final bool addBos;
  TokenizeCtl(this.ctx, this.text, {required this.addBos});

  TokenizeResp done(List<Token> tokens) => TokenizeResp(id, tokens: tokens);
  TokenizeResp error(Object err) => TokenizeResp(id, err: err);
}

final class IngestCtl extends ControlMessage {
  final Context ctx;
  IngestCtl(this.ctx);

  IngestResp done() => IngestResp(id);
  IngestResp error(Object err) => IngestResp(id, err: err);
}

final class GenerateCtl extends ControlMessage {
  final Context ctx;
  final String prompt;
  final List<Sampler> samplers;

  GenerateCtl(this.ctx, this.prompt, this.samplers);

  GenerateResp done() => GenerateResp(id);
  GenerateResp error(Object err) => GenerateResp(id, err: err);
  GenerateTokenResp token(Token tok) => GenerateTokenResp(id, tok);
  HandshakeResp handshake(SendPort port) => HandshakeResp(port, id);
}
