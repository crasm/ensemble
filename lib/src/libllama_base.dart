import 'dart:ffi';
import 'dart:io' show Directory;

import 'package:ensemble_llama/src/libllama.ffigen.dart';
import 'package:path/path.dart' as path;

final NativeLibrary libllama = NativeLibrary(DynamicLibrary.open(
    path.join(Directory.current.path, 'llama', 'libllama.so')));
