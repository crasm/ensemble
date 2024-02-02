import 'dart:ffi';

// We also assume little-endian
final class ReifHeader extends Struct {
  @Array(4)
  external Array<Uint8> magicNumber; // should be 'REIF' in ASCII;

  @Uint32()
  external int version;

  @Uint32()
  external int lastCheckpointOffset;

  @Uint32()
  external int lastDeltaOffset;

  @Array(12)
  external Array<Uint32> reserved;
}

abstract final class EntryType {
  static const int checkpoint = 0;
  static const int delta = 1;
}

// Payload is aligned/padded for 4-bytes alignment
// TODO: this might be unnecessary but was fun to think about
final class EntryHeader extends Struct {
  @Uint8()
  external int type;

  @Uint8()
  external int prefixPadding; // Padding in bytes before payload begins

  @Uint8()
  external int suffixPadding; // Padding in bytes after payload ends

  @Uint32()
  external int payloadSize;
}
