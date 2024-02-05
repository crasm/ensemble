import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'package:reif/src/reif_file.dart';

abstract interface class Serializable {
  Uint8List asBytes();
}

typedef SerializableMap = Map<String, Serializable>;

final class Series {
  final SerializableMap checkpoint;
  final List<SerializableMap> deltas = [];
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

  Future<void> addCheckpoint(SerializableMap data) async {
    _seriesList.add(Series(data));
    await _file?.addCheckpoint(data);
  }

  Future<void> addDelta(SerializableMap data) async {
    _seriesList.last.deltas.add(data);
    await _file?.addDelta(data);
  }

  Future<void> _replayCheckpoint(SerializableMap data) async {
    _seriesList.clear();
    _seriesList.add(Series(data));
    await replayCheckpoint(data);
  }

  Future<void> _replayDelta(SerializableMap data) async {
    _seriesList.last.deltas.add(data);
    await replayDelta(data);
  }

  @protected
  Future<void> replayCheckpoint(SerializableMap data);
  @protected
  Future<void> replayDelta(SerializableMap data);
}
