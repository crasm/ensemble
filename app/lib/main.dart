import 'dart:io';

import 'package:flutter/material.dart';

import 'package:ensemble_common/common.dart';
import 'package:grpc/grpc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ClientChannel channel;
  late final LlmClient stub;

  final String prompt = "Hello, my name is";
  late final StringBuffer gen;

  _MyHomePageState() {
    channel = ClientChannel(
      // '127.0.0.1',
      '192.168.32.3',
      // 'brick',
      port: 8888,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = LlmClient(
      channel,
      options: CallOptions(timeout: const Duration(seconds: 30)),
    );

    gen = StringBuffer(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: StreamBuilder<Token>(
          stream: stub.generate(Prompt(text: "Hello, my name is")),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.hasText()) {
              stderr.write(snapshot.data!.text);
              gen.write(snapshot.data!.text);
            }
            return Text(gen.toString());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
