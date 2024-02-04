// We also assume little-endian
import 'dart:ffi';

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

enum EntryType { checkpoint, delta }

// Payload is aligned/padded for 4-bytes alignment. This might be unnecessary
// but was fun to think about.
// TODO(crasm):
// * hash of payload? (=> deduplication?)
// * UUID or incremental ID key?
final class EntryHeader extends Struct {
  static int get size => sizeOf<EntryHeader>();
  int get totalSize => EntryHeader.size + payloadSize + payloadPadding;

  @Uint8()
  external int type;

  @Uint8()
  // Padding in bytes after payload ends
  external int payloadPadding;

  @Uint16()
  external int reserved;

  @Uint32()
  external int payloadSize;
}
