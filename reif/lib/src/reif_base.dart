import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

const _magicNumber = [0x52, 0x45, 0x49, 0x46];

abstract class Reif {
  static final _log = Logger('Reif');

  final String file;
  late final RandomAccessFile _file;
  late final Pointer<ReifHeader> _headerPointer;
  late final Pointer<EntryHeader> _entryPointer;
  late final ReifHeader _header;
  late final EntryHeader _entry;

  /// Create a Reif, initializing the file if it does not exist.
  Reif(this.file) {
    _headerPointer = malloc.allocate(ReifHeader.size).cast<ReifHeader>()
      ..zero();
    _entryPointer = malloc.allocate(EntryHeader.size).cast<EntryHeader>()
      ..zero();
    _header = _headerPointer.ref;
    _entry = _entryPointer.ref;

    _file = File(file).openSync(mode: FileMode.append);
    final fileLength = _file.lengthSync();
    if (fileLength == 0) {
      // Initialize file with Reif header
      for (var i = 0; i < _magicNumber.length; i++) {
        _header.magicNumber[i] = _magicNumber[i];
      }
      _header.version = 1;
      _header.nextEntryOffset = ReifHeader.size;
      _file.writeFromSync(_headerPointer.asBytes);
    }

    _file.setPositionSync(0);
    var bytesRead = _file.readIntoSync(_headerPointer.asBytes);
    if (bytesRead != ReifHeader.size) {
      throw Exception(
          "Couldn't read entire header from $file, only read $bytesRead bytes");
    }

    for (var i = 0; i < _magicNumber.length; i++) {
      if (_header.magicNumber[i] != _magicNumber[i]) {
        throw Exception("File at $file doesn't contain the REIF magic number");
      }
    }
  }

  @mustCallSuper
  Future<void> dispose() async {
    // Save the header
    _file.setPositionSync(0);
    _file.writeFromSync(_headerPointer.asBytes);
    malloc.free(_headerPointer);
    await _file.close();

    malloc.free(_entryPointer);
  }

  Future<void> addCheckpoint(Uint8List bytes) =>
      _addEntry(bytes, EntryType.checkpoint);
  Future<void> addDelta(Uint8List bytes) => _addEntry(bytes, EntryType.delta);

  Future<void> _addEntry(Uint8List bytes, int entryType) async {
    switch (entryType) {
      case EntryType.checkpoint:
        _header.lastCheckpointOffset = _header.nextEntryOffset;
      case EntryType.delta:
        _header.lastDeltaOffset = _header.nextEntryOffset;
      default:
        assert(false, '_entryType $entryType is not a valid EntryType');
    }

    _file.setPositionSync(_header.nextEntryOffset);

    _entryPointer.zero();
    _entry.type = entryType;
    _entry.payloadSize = bytes.length;

    final remainder = _entry.payloadSize % 4;
    _entry.payloadPadding = remainder > 0 ? 4 - remainder : 0;

    _header.nextEntryOffset = _header.nextEntryOffset +
        EntryHeader.size +
        _entry.payloadSize +
        _entry.payloadPadding;

    _file.writeFromSync(_entryPointer.asBytes);
    await _file.writeFrom(bytes);
    for (var i = 0; i < _entry.payloadPadding; i++) {
      await _file.writeByte(0);
    }
    // TODO(crasm): sync?
    // await _file.flush();
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

// We also assume little-endian
final class ReifHeader extends Struct {
  static int get size => sizeOf<ReifHeader>();

  @Array(4)
  external Array<Uint8> magicNumber; // should be 'REIF' in ASCII;

  @Uint32()
  external int version;

  @Uint32()
  external int lastCheckpointOffset;

  @Uint32()
  external int lastDeltaOffset;

  // The offset to begin writing the EntryHeader for the next Entry. This is
  // typically the length of the file.
  @Uint32()
  external int nextEntryOffset;

  @Array(11)
  external Array<Uint32> reserved;
}

abstract final class EntryType {
  static const int checkpoint = 0;
  static const int delta = 1;
}

// Payload is aligned/padded for 4-bytes alignment
// TODO: this might be unnecessary but was fun to think about
final class EntryHeader extends Struct {
  static int get size => sizeOf<EntryHeader>();

  @Uint8()
  external int type;

  @Uint8()
  external int payloadPadding; // Padding in bytes after payload ends

  @Uint16()
  external int reserved;

  @Uint32()
  external int payloadSize;
}
