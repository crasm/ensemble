import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:reif/src/reif_base.dart';

// Reif future requirements
// * Isolate for doing background IO and maintenance tasks.
// * Cache deltas in memory and commit them in background

final class TextAppendReif extends Reif {
  TextAppendReif(super.filePath);

  final _isEmpty = false;
  Future<void> append(String value) async {
    if (_isEmpty) {
      await addCheckpoint(utf8.encode(value));
    } else {
      await addDelta(utf8.encode(value));
    }
  }
}

void main() async {
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

  final reif = TextAppendReif('./text-append.reif');
  for (final str in ['My name', ' is Bob.', ' What is your ', 'name? ']) {
    await reif.append(str);
    // print(reif.text);
  }

  await reif.dispose();
}
