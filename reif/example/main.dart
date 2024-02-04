import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import 'package:reif/reif.dart';

// Reif future requirements
// * Isolate for doing background IO and maintenance tasks.
// * Cache deltas in memory and commit them in background
// * Designed to accomodate replication, synchronization, and transparent
//   partial caching (all state on remote, less state locally) over network

final class TextAppendReif extends Reif {
  StringBuffer _buf = StringBuffer();
  String get text => _buf.toString();

  @override
  Future<void> replayCheckpoint(Uint8List data) async {
    _buf = StringBuffer(utf8.decode(data));
  }

  @override
  Future<void> replayDelta(Uint8List data) async {
    _buf.write(utf8.decode(data));
  }

  Future<void> append(String value) async {
    if (_buf.isEmpty) await addCheckpoint(utf8.encode(''));
    _buf.write(value);
    await addDelta(utf8.encode(value));
  }
}

Future<void> makeReif() async {
  try {
    File('./text-append.reif').deleteSync();
  } on Exception catch (_) {}
  final reif = TextAppendReif();
  await reif.open('./text-append.reif');
  for (final str in ['My name', ' is Bob.', ' What is your ', 'name? ']) {
    await reif.append(str);
    print(reif.text);
  }

  await reif.dispose();
}

Future<void> printReif() async {
  final reif = TextAppendReif();
  await reif.open('./text-append.reif');
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
