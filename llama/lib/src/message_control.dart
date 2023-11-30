import 'dart:isolate';
import 'dart:math';

import 'package:ensemble_llama/src/common.dart';
import 'package:ensemble_llama/src/llama.dart';
import 'package:ensemble_llama/src/message_response.dart';
import 'package:ensemble_llama/src/params.dart';
import 'package:ensemble_llama/src/sampling.dart';

sealed class ControlMessage {
  final id = Random().nextInt(int32Max);
  ControlMessage();
}

class ExitCtl extends ControlMessage {
  ExitResp done() => ExitResp(id);
}

class LoadModelCtl extends ControlMessage {
  final String path;
  final ModelParams params;
  LoadModelCtl(this.path, this.params);

  LoadModelResp done(Model model) => LoadModelResp(id, model: model);
  LoadModelResp error(Object err) => LoadModelResp(id, err: err);
  LoadModelProgressResp progress(double progress) =>
      LoadModelProgressResp(id, progress);
}

class FreeModelCtl extends ControlMessage {
  final Model model;
  FreeModelCtl(this.model);

  FreeModelResp done() => FreeModelResp(id);
}

class NewContextCtl extends ControlMessage {
  final Model model;
  final ContextParams params;
  NewContextCtl(this.model, this.params);

  NewContextResp done(Context ctx) => NewContextResp(id, ctx: ctx);
  NewContextResp error(Object err) => NewContextResp(id, err: err);
}

class FreeContextCtl extends ControlMessage {
  final Context ctx;
  FreeContextCtl(this.ctx);

  FreeContextResp done() => FreeContextResp(id);
}

class TokenizeCtl extends ControlMessage {
  final Context ctx;
  final String prompt;
  TokenizeCtl(this.ctx, this.prompt);

  TokenizeResp done(List<Token> tokens) => TokenizeResp(id, tokens: tokens);
  TokenizeResp error(Object err) => TokenizeResp(id, err: err);
}

class GenerateCtl extends ControlMessage {
  final Context ctx;
  final String prompt;
  final List<Sampler> samplers;

  GenerateCtl(this.ctx, this.prompt, this.samplers);

  GenerateResp done() => GenerateResp(id);
  GenerateResp error(Object err) => GenerateResp(id, err: err);
  GenerateTokenResp token(Token tok) => GenerateTokenResp(id, tok);
  HandshakeResp handshake(SendPort port) => HandshakeResp(port, id);
}
