import 'dart:convert';
import 'dart:io';
import 'package:ensemble_protos/llamacpp.dart' as protos;
import 'package:grpc/grpc.dart' as grpc;

void listenTo(grpc.ResponseStream stream) {
  stream.listen(
    (tok) {
      stdout.write(utf8.decode(tok.textUtf8));
    },
    onError: (e) {
      stderr.writeln('\nerror: $e');
    },
    onDone: () {
      stderr.writeln('done');
    },
  );
}

void main(List<String> arguments) async {
  final channel = grpc.ClientChannel(
    '192.168.32.3',
    port: 8888,
    options: const grpc.ChannelOptions(
        credentials: grpc.ChannelCredentials.insecure()),
  );

  final stub = protos.LlamaCppClient(channel,
      options: grpc.CallOptions(timeout: Duration(seconds: 30)));

  final ctx = await stub.newContext(protos.NewContextRequest());
  await stub.addText(
    protos.AddTextRequest(
      context: ctx,
      textUtf8: utf8.encode(arguments[0]),
    ),
  );
  await stub.ingest(ctx);
  final respStream = stub.generate(ctx);
  listenTo(respStream);

  await Future.delayed(const Duration(seconds: 1));
  await respStream.cancel();

  final respStream2 = stub.generate(ctx);
  listenTo(respStream2);
  await channel.shutdown();
}
