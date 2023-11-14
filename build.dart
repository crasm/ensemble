import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as path;

import 'package:native_assets_cli/native_assets_cli.dart';

final class CompileError extends Error {
  String message;
  CompileError([this.message = ""]);
}

void main(List<String> args) async {
  final buildConfig = await BuildConfig.fromArgs(args);
  final buildOutput = BuildOutput();

  final proc =
      await Process.start('make', ['libllama.so'], workingDirectory: 'src');

  proc.stdout.transform(utf8.decoder).forEach(stderr.write);
  proc.stderr.transform(utf8.decoder).forEach(stderr.write);
  int exitCode = await proc.exitCode;
  if (exitCode != 0) {
    throw CompileError("make failed: exitCode=$exitCode");
  }

  // $ cp ./src/libllama.so ./.dart_tool/native_assets_builder/<snip>/out/libllama.so
  final libllama = await File(path.join('src', 'libllama.so'))
      .copy(path.join(path.fromUri(buildConfig.outDir), 'libllama.so'));

  buildOutput.assets.add(Asset(
    id: 'package:ensemble_llama/src/libllama.ffigen.dart',
    linkMode: buildConfig.linkModePreference.preferredLinkMode,
    target: buildConfig.target,
    path: AssetPath('absolute', libllama.uri),
  ));

  await buildOutput.writeToFile(outDir: buildConfig.outDir);
}
