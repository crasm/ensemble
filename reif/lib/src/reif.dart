import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'package:reif/reif.dart';

const _magicNumber = [0x52, 0x45, 0x49, 0x46];

abstract class Reif {
  static final _log = Logger('Reif');

  RandomAccessFile? _file;
  late final Pointer<ReifHeader> _headerPointer;
  late final Pointer<EntryHeader> _entryPointer;
  late final ReifHeader _header;
  late final EntryHeader _entry;

  /// Create a Reif, initializing the file if it does not exist.
  Reif() {
    _headerPointer = malloc.allocate(ReifHeader.size).cast<ReifHeader>()
      ..zero();
    _entryPointer = malloc.allocate(EntryHeader.size).cast<EntryHeader>()
      ..zero();
    _header = _headerPointer.ref;
    _entry = _entryPointer.ref;
  }

  Future<void> open(String file) async {
    this._file = File(file).openSync(mode: FileMode.append);
    final _file = this._file!; // so we don't need ! everywhere

    final fileLength = _file.lengthSync();
    if (fileLength == 0) {
      _log.info('Initializing $file as Reif file');
      // Initialize file with Reif header
      for (var i = 0; i < _magicNumber.length; i++) {
        _header.magicNumber[i] = _magicNumber[i];
      }
      _header.version = 1;
      _header.nextEntryOffset = ReifHeader.size;
      _file.writeFromSync(_headerPointer.asBytes);
    } else {
      _log.info('Loading header from Reif file');
      _file.readReifHeader(_headerPointer);
    }

    for (var i = 0; i < _magicNumber.length; i++) {
      if (_header.magicNumber[i] != _magicNumber[i]) {
        throw Exception("File at $file doesn't contain the REIF magic number");
      }
    }

    if (_header.lastCheckpointOffset != 0) await _reify();
  }

  /// Reify ("make an abstraction concrete") the state. Begins by replaying
  /// the last checkpoint, and then replays each delta in turn until the
  /// last delta is reached.
  Future<void> _reify() async {
    // TODO(crasm): what if the last entry is a checkpoint? What if there are
    // no checkpoints? What if there are checkpoints after checkpoints?
    int pos;
    Uint8List data;

    final _file = this._file!; // so we don't need ! everywhere

    //
    // Replay the last checkpoint
    _log.fine(
        'Loading lastCheckPointOffset from ${_header.lastCheckpointOffset}');
    pos = _header.lastCheckpointOffset;
    _file.setPositionSync(pos);
    _file.readEntryHeader(_entryPointer);

    data = await _file.readData(_entry.payloadSize);
    _log.info('Replaying ${data.length} bytes of checkpoint data');
    await replayCheckpoint(data);

    //
    // Replay all deltas until we reach the end
    pos = _header.lastCheckpointOffset + _entry.totalSize;

    while (pos < _header.nextEntryOffset) {
      _file.setPositionSync(pos);
      _file.readEntryHeader(_entryPointer);
      data = await _file.readData(_entry.payloadSize);
      _log.info('Replaying ${data.length} bytes of delta data');
      await replayDelta(data);

      pos = pos + _entry.totalSize;
    }
    assert(pos == _header.nextEntryOffset);
  }

  @mustCallSuper
  Future<void> dispose() async {
    // Save the header before freeing
    _file?.setPositionSync(0);
    _file?.writeFromSync(_headerPointer.asBytes);
    await _file?.close();

    malloc.free(_headerPointer);
    malloc.free(_entryPointer);
  }

  Future<void> addCheckpoint(Uint8List data) =>
      _addEntry(data, EntryType.checkpoint);
  Future<void> addDelta(Uint8List data) => _addEntry(data, EntryType.delta);

  Future<void> _addEntry(Uint8List data, EntryType entryType) async {
    _log.info('Adding a $entryType');
    switch (entryType) {
      case EntryType.checkpoint:
        _header.lastCheckpointOffset = _header.nextEntryOffset;
      case EntryType.delta:
        _header.lastDeltaOffset = _header.nextEntryOffset;
      default:
        assert(false, '_entryType $entryType is not a valid EntryType');
    }

    _file?.setPositionSync(_header.nextEntryOffset);

    _entryPointer.zero();
    _entry.type = entryType.index;
    _entry.payloadSize = data.length;

    final remainder = _entry.payloadSize % 4;
    _entry.payloadPadding = remainder > 0 ? 4 - remainder : 0;

    _header.nextEntryOffset = _header.nextEntryOffset + _entry.totalSize;

    if (_file != null) {
      _file!.writeFromSync(_entryPointer.asBytes);
      _log.info('Writing ${data.length} bytes of data');
      await _file!.writeFrom(data);
      _log.finer('Writing ${_entry.payloadPadding} bytes of padding');
      for (var i = 0; i < _entry.payloadPadding; i++) {
        await _file!.writeByte(0);
      }
    }
  }

  Future<void> replayCheckpoint(Uint8List data);
  Future<void> replayDelta(Uint8List data);
}

extension on RandomAccessFile {
  void readReifHeader(Pointer<ReifHeader> header) {
    setPositionSync(0);
    final bytesRead = readIntoSync(header.asBytes);
    if (bytesRead != ReifHeader.size) {
      throw Exception(
          'Expected to read ${ReifHeader.size} bytes, got $bytesRead bytes');
    }
  }

  void readEntryHeader(Pointer<EntryHeader> entry) {
    final bytesRead = readIntoSync(entry.asBytes);
    if (bytesRead != EntryHeader.size) {
      throw Exception(
          'Expected to read ${EntryHeader.size} bytes, got $bytesRead bytes');
    }
  }

  Future<Uint8List> readData(int size) async {
    final data = await read(size);
    if (data.length < size) {
      throw Exception('Expected to read $size bytes, got ${data.length} bytes');
    }
    return data;
  }
}

extension on Pointer<ReifHeader> {
  Uint8List get asBytes =>
      Uint8List.view(cast<Uint8>().asTypedList(ReifHeader.size).buffer);

  void zero() {
    final bp = cast<Uint8>();
    for (var i = 0; i < ReifHeader.size; i++) {
      bp[0] = i;
    }
  }
}

extension on Pointer<EntryHeader> {
  Uint8List get asBytes =>
      Uint8List.view(cast<Uint8>().asTypedList(EntryHeader.size).buffer);

  void zero() {
    final bp = cast<Uint8>();
    for (var i = 0; i < EntryHeader.size; i++) {
      bp[0] = i;
    }
  }
}
