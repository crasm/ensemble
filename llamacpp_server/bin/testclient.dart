import 'dart:io';
import 'package:ensemble_protos/llamacpp.dart' as protos;
import 'package:grpc/grpc.dart' as grpc;

void main(List<String> arguments) async {
  final channel = grpc.ClientChannel('brick',
      port: 8888,
      options: const grpc.ChannelOptions(
          credentials: grpc.ChannelCredentials.insecure()));

  final stub = protos.LlamaCppClient(channel,
      options: grpc.CallOptions(timeout: Duration(seconds: 30)));

  try {
    await for (final tok in stub.generate(protos.Prompt(text: arguments[0]))) {
      stdout.write(tok.text);
    }
  } catch (e) {
    stderr.writeln("\nerror: $e");
  }
  await channel.shutdown();
}
