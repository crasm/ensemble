import 'dart:isolate';

import 'package:ensemble_llama/src/llama.dart' show Model, Context, Token;
import 'package:ensemble_llama/src/common.dart';

sealed class ResponseMessage {
  final int id;
  final Object? err;
  const ResponseMessage(this.id, {this.err}) : assert(id <= int32Max);
  void throwIfErr() {
    if (err != null) {
      throw err!;
    }
  }
}

class HandshakeResp extends ResponseMessage {
  final SendPort controlPort;
  const HandshakeResp(this.controlPort, [super.id = 0]);
}

class ExitResp extends ResponseMessage {
  const ExitResp(super.id);
}

// TODO: include mem used, model details?
class LoadModelResp extends ResponseMessage {
  final Model? model;
  const LoadModelResp(super.id, {super.err, this.model});
}

class LoadModelProgressResp extends ResponseMessage {
  final double progress;
  const LoadModelProgressResp(super.id, this.progress);
}

class FreeModelResp extends ResponseMessage {
  const FreeModelResp(super.id, {super.err});
}

class NewContextResp extends ResponseMessage {
  final Context? ctx;
  const NewContextResp(super.id, {super.err, this.ctx});
}

class FreeContextResp extends ResponseMessage {
  const FreeContextResp(super.id, {super.err});
}

class TokenizeResp extends ResponseMessage {
  final List<Token> tokens;
  const TokenizeResp(super.id, {super.err, this.tokens = const []});
}

class GenerateResp extends ResponseMessage {
  const GenerateResp(super.id, {super.err});
}

class GenerateTokenResp extends ResponseMessage {
  final Token tok;
  const GenerateTokenResp(super.id, this.tok);
}
