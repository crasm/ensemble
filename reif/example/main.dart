import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:reif/src/reif_base.dart';

// Reif future requirements
// * Isolate for doing background IO and maintenance tasks.
// * Cache deltas in memory and commit them in background

final class TextAppendReif extends Reif {
  StringBuffer _buf = StringBuffer();
  TextAppendReif(super.filePath);

  String get text => _buf.toString();

  @override
  Future<void> replayCheckpoint(Uint8List data) async {
    _buf = StringBuffer(utf8.decode(data));
  }

  @override
  Future<void> replayDelta(Uint8List data) async {
    _buf.write(utf8.decode(data));
  }

  Future<void> init() => addCheckpoint(utf8.encode(''));
  Future<void> append(String value) async {
    _buf.write(value);
    await addDelta(utf8.encode(value));
  }
}

Future<void> makeReif() async {
  File('./text-append.reif').deleteSync();
  final reif = TextAppendReif('./text-append.reif');
  await reif.init();
  for (final str in ['My name', ' is Bob.', ' What is your ', 'name? ']) {
    await reif.append(str);
    print(reif.text);
  }

  await reif.dispose();
}

Future<void> printReif() async {
  final reif = TextAppendReif('./text-append.reif');
  await reif.reify();
  print(reif.text);
}

Future<void> main(List<String> arguments) async {
  final startTime = DateTime.now();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((e) {
    final diff = e.time.difference(startTime);
    stderr.writeln(
      '${e.level.name.padRight(7)}: '
      '${diff.inMilliseconds.toString().padLeft(6, '0')}: '
      '${e.loggerName}: '
      '${e.message}',
    );
  });

  switch (arguments.first) {
    case 'make':
      await makeReif();
    case 'print':
      await printReif();
  }
}
