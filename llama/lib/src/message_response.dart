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

  static bool Function(ResponseMessage) matches<T extends ResponseMessage>(int id) {
    return (resp) => resp is T && resp.id == id;
  }

  @override
  String toString() => err == null ? "$runtimeType#$id" : toStringErr();
  String toStringErr() => "$runtimeType#$id{err: $err}";
}

final class HandshakeResp extends ResponseMessage {
  final SendPort controlPort;
  const HandshakeResp(this.controlPort, [super.id = 0]);
}

final class ExitResp extends ResponseMessage {
  const ExitResp(super.id);
}

// TODO: include mem used, model details?
final class LoadModelResp extends ResponseMessage {
  final Model? model;
  const LoadModelResp(super.id, {super.err, this.model});
  @override
  String toString() => err == null ? "LoadModelResp#$id{model: $model}" : toStringErr();
}

final class LoadModelProgressResp extends ResponseMessage {
  final double progress;
  const LoadModelProgressResp(super.id, this.progress);
  @override
  String toString() => err == null
      ? "LoadModelProgressResp#$id{progress: ${progress.toStringAsFixed(6)}}"
      : toStringErr();
}

final class FreeModelResp extends ResponseMessage {
  const FreeModelResp(super.id, {super.err});
}

final class NewContextResp extends ResponseMessage {
  final Context? ctx;
  const NewContextResp(super.id, {super.err, this.ctx});
  @override
  String toString() => err == null ? "NewContextResp#$id{ctx: $ctx}" : toStringErr();
}

final class FreeContextResp extends ResponseMessage {
  const FreeContextResp(super.id, {super.err});
}

final class TokenizeResp extends ResponseMessage {
  final List<Token> tokens;
  final int? firstTokenIndex; // index of tokens[0] in context's tokens
  const TokenizeResp(
    super.id, {
    super.err,
    this.firstTokenIndex,
    this.tokens = const [],
  });

  @override
  String toString() {
    if (err != null) return toStringErr();

    final buf = StringBuffer("TokenizeResp#");
    buf.write(id);
    buf.write("{tokens: [\n");
    for (int i = 0; i < tokens.length; i++) {
      buf.writeln(tokens[i].toLogString(firstTokenIndex! + i));
    }
    buf.write("]}");
    return buf.toString();
  }
}

final class EditResp extends ResponseMessage {
  const EditResp(super.id, {super.err});
}

final class IngestResp extends ResponseMessage {
  const IngestResp(super.id, {super.err});
}

final class GenerateResp extends ResponseMessage {
  const GenerateResp(super.id, {super.err});
}

final class GenerateTokenResp extends ResponseMessage {
  final Token tok;
  const GenerateTokenResp(super.id, this.tok);
  @override
  String toString() => err == null ? "GenerateTokenResp#$id{${tok.toLogString()}}" : toStringErr();
}
