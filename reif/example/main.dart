import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:reif/src/gen/text_append.pb.dart';
import 'package:reif/src/reif_base.dart';

// Reif future requirements
// * Isolate for doing background IO and maintenance tasks.
// * Cache deltas in memory and commit them in background

class TextAppendReif {
  static Future<TextAppendReif> fromFile(String filePath) async {
    final file = await File(filePath).open(mode: FileMode.append);

    // If file is more-or-less empty, initialize it
    if (await file.length() < sizeOf<ReifHeader>()) {
      final header = calloc.allocate(sizeOf<ReifHeader>()).cast<ReifHeader>();
      final magic = ascii.encode('REIF');
      for (var i = 0; i < magic.length; i++) {
        header.ref.magicNumber[i] = magic[i];
      }
      header.ref.version = 1;

      final buf = Uint8List.view(
        header
            .cast<Uint8>()
            .asTypedList(
              sizeOf<ReifHeader>(),
            )
            .buffer,
      );

      await file.writeFrom(buf);
      calloc.free(header);
    }

    return TextAppendReif(file);
  }

  final RandomAccessFile _file;
  final List<String> _deltas = [];

  TextAppendReif(this._file) {}

  Future<void> close() async {
    await _file.close();
  }

  String get text {
    final buf = StringBuffer()..writeAll(_deltas);
    return buf.toString();
  }

  // set text(String value) => _text = value;
  void append(String value) => _deltas.add(value);
}

void main() async {
  final reif = await TextAppendReif.fromFile('./text-append.reif');
  ['My name', ' is Bob.', ' What is your ', 'name? '].forEach((element) {
    reif.append(element);
    print(reif.text);
  });

  await reif.close();
}
