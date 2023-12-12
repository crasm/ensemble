import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:llamacpp/llamacpp_ffi.dart';
import 'package:meta/meta.dart' show immutable;

@immutable
final class Token {
  final int id;
  final String text;
  final String rawText;

  const Token(this.id, this.text, this.rawText);

  factory Token.fromId(Pointer<llama_model> modelPointer, int id) {
    final rawText =
        llama_token_get_text(modelPointer, id).cast<Utf8>().toDartString();
    // replace U+2581 with a space
    final text = rawText.replaceAll('▁', ' ').replaceAll('<0x0A>', '\n');
    return Token(id, text, rawText);
  }

  @override
  String toString() => text;
  String toStringForLogging() => '${id.toString().padLeft(5)} = $rawText\n';

  @override
  bool operator ==(Object? other) =>
      other is Token && other.id == id && other.rawText == rawText;
  @override
  int get hashCode => id.hashCode + rawText.hashCode;
}
