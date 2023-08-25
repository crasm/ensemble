import 'dart:ffi';
import 'package:ffi/ffi.dart';

typedef BackendInitC = Void Function(Bool numa);
typedef BackendInit = void Function(bool isNuma);

typedef BackendFreeC = Void Function();
typedef BackendFree = void Function();

typedef PrintSystemInfo = Pointer<Utf8> Function();
