part of 'llamacpp.dart';

/// The maximum value for a 32-bit unsigned integer.
const uint32Max = 0xFFFFFFFF;

/// The maximum positive value for a 32-bit signed integer.
const int32Max = 0x7FFFFFFF;

/// The maximum positive value for a 32-bit float.
const float32Max = 3.4028234663852886e+38;

extension on num {
  void checkIncInc(num start, num end, String name) {
    if (!(this >= start && this <= end)) {
      throw RangeError.value(this, name, 'must be between [$start, $end]');
    }
  }
}
