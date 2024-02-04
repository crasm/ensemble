import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'package:reif/src/reif_file.dart';

final class Series {
  final Uint8List checkpoint;
  final List<Uint8List> deltas = [];
  Series(this.checkpoint);
}

abstract class Reif {
  static final _log = Logger('Reif');

  ReifFile? _file;
  final List<Series> _seriesList = [];

  Future<void> openFile(String file) async {
    _file = await ReifFile.open(
      file,
      onReplayCheckpoint: _replayCheckpoint,
      onReplayDelta: _replayDelta,
    );
  }

  @mustCallSuper
  Future<void> dispose() async {
    await _file?.commit();
    await _file?.close();
  }

  Future<void> addCheckpoint(Uint8List data) async {
    _seriesList.add(Series(data));
    await _file?.addCheckpoint(data);
  }

  Future<void> addDelta(Uint8List data) async {
    _seriesList.last.deltas.add(data);
    await _file?.addDelta(data);
  }

  Future<void> _replayCheckpoint(Uint8List data) async {
    _seriesList.clear();
    _seriesList.add(Series(data));
    await replayCheckpoint(data);
  }

  Future<void> _replayDelta(Uint8List data) async {
    _seriesList.last.deltas.add(data);
    await replayDelta(data);
  }

  @protected
  Future<void> replayCheckpoint(Uint8List data);
  @protected
  Future<void> replayDelta(Uint8List data);
}
