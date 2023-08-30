import 'dart:ffi';
import 'dart:io' show Directory;

import 'package:path/path.dart' as path;

import 'package:ensemble_llama/src/libllama.ffigen.dart';

final NativeLibrary libllama = NativeLibrary(DynamicLibrary.open(
    path.join(Directory.current.path, 'llama', 'libllama.so')));
