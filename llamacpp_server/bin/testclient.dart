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

  final ctx = await stub.newContext(protos.NewContextRequest());
  await stub.addText(protos.AddTextRequest(
      context: ctx, text: protos.Text(text: arguments[0])));
  await stub.ingest(ctx);
  try {
    await for (final tok in stub.generate(ctx)) {
      stdout.write(tok.text);
    }
  } catch (e) {
    stderr.writeln("\nerror: $e");
  }
  await channel.shutdown();
}
