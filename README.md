<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# llamacpp-dart

**⚠️This package is incomplete and under active development!⚠️**

This package provides low-level (FFI) and high-level bindings for [llama.cpp][]
for Native platform Dart.

[llama.cpp]: https://github.com/ggerganov/llama.cpp
[native_assets_cli]: https://pub.dev/packages/native_assets_cli

Depends on [native_assets_cli][], to integrate with llama.cpp, which requires
passing the flag `--enable-experiment=native-assets` and possibly a dev-channel
build of Dart.

See `example/` for basic usage of the API.