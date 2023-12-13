// 4294967295 (32 bit unsigned)
// -1 (32 bit signed)
const int32Max = 0xFFFFFFFF;

extension NumberRangeChecks on num {
  void checkIncInc(num start, num end, String name) {
    if (!(this >= start && this <= end)) {
      throw RangeError.value(this, name, 'must be between [$start, $end]');
    }
  }

  void checkGTE(num min, String name) {
    if (!(this >= min)) {
      throw RangeError.value(
          this, name, 'must be greater than or equal to $min');
    }
  }
}
