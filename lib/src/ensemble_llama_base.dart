import 'dart:ffi';
import 'dart:io' show Directory;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

import 'bindings.dart';

class LlamaCpp {
  static final LlamaCpp _instance = LlamaCpp._init();
  final DynamicLibrary _llama = DynamicLibrary.open(
      path.join(Directory.current.path, 'llama', 'libllama.so'));

  factory LlamaCpp() {
    return _instance;
  }

  LlamaCpp._init() {
    _llama
        .lookupFunction<BackendInitC, BackendInit>('llama_backend_init')
        .call(false);
  }

  void dispose() {
    _llama
        .lookupFunction<BackendFreeC, BackendFree>('llama_backend_free')
        .call();
  }

  String systemInfo() {
    return _llama
        .lookupFunction<PrintSystemInfo, PrintSystemInfo>(
          isLeaf: true,
          'llama_print_system_info',
        )
        .call()
        .toDartString();
  }
}
