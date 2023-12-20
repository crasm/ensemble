import 'dart:io';
import 'dart:convert';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:path/path.dart' as path;

final class CompileError extends Error {
  final String message; // ignore: unreachable_from_main
  CompileError([this.message = '']);
}

Future<File> _copy(String filename, String src, String dst) =>
    File(path.join(src, filename)).copy(path.join(dst, filename));

void main(List<String> args) async {
  final buildConfig = await BuildConfig.fromArgs(args);
  final buildOutput = BuildOutput();

  final llamacpp = path.join(buildConfig.packageRoot.toFilePath(), 'llama.cpp');

  stderr.writeln(buildConfig);
  final proc = await Process.start(
    'make',
    ['libllama.so'],
    workingDirectory: llamacpp,
  );

  // ignore: unawaited_futures
  proc.stdout.transform(utf8.decoder).forEach(stderr.write);
  // ignore: unawaited_futures
  proc.stderr.transform(utf8.decoder).forEach(stderr.write);
  final exitCode = await proc.exitCode;
  if (exitCode != 0) {
    throw CompileError('make failed: exitCode=$exitCode');
  }

  // $ cp ./llama.cpp/libllama.so ./.dart_tool/native_assets_builder/<snip>/out/libllama.so
  final dst = path.fromUri(buildConfig.outDir);
  final libllama = await _copy('libllama.so', llamacpp, dst);
  await _copy('ggml-metal.metal', llamacpp, dst);

  buildOutput.assets.add(Asset(
    id: 'package:ensemble_llamacpp/src/libllama.dart',
    linkMode: buildConfig.linkModePreference.preferredLinkMode,
    target: buildConfig.target,
    path: AssetPath('absolute', libllama.uri),
  ));

  await buildOutput.writeToFile(outDir: buildConfig.outDir);
}
