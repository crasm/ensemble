import 'dart:io';
import 'package:ensemble_common/common.dart' as c;
import 'package:grpc/grpc.dart' as grpc;

void main(List<String> arguments) async {
  final channel = grpc.ClientChannel('127.0.0.1',
      port: 9090,
      options: const grpc.ChannelOptions(credentials: grpc.ChannelCredentials.insecure()));

  final stub = c.LlmClient(channel, options: grpc.CallOptions(timeout: Duration(seconds: 30)));

  try {
    await for (final tok in stub.generate(c.Prompt(text: arguments[0]))) {
      stdout.write(tok.text);
    }
  } catch (e) {
    stderr.writeln("\nerror: $e");
  }
  await channel.shutdown();
}
