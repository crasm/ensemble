// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
// TODO: delete ^^^

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:ensemble_common/common.dart';
import 'package:grpc/grpc.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Ensemble',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ensemble'),
        backgroundColor: Colors.amber[300],
      ),
      body: PageView(children: [
        GenPage(),
        GenPage(),
      ]),
    );
  }
}

class GenPage extends StatefulWidget {
  const GenPage({super.key});
  @override
  State<StatefulWidget> createState() => _GenPageState();
}

class _GenPageState extends State<GenPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final ClientChannel channel;
  late final LlmClient stub;

  final String prompt = "Hello, my name is";
  late final StringBuffer gen;

  @override
  void initState() {
    super.initState();
    channel = ClientChannel(
      'brick',
      port: 8888,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = LlmClient(
      channel,
      options: CallOptions(timeout: const Duration(seconds: 30)),
    );

    gen = StringBuffer(prompt);

    stub.generate(Prompt(text: prompt)).listen(_loadGen);
  }

  void _loadGen(Token tok) {
    if (tok.hasText()) {
      setState(() {
        gen.write(tok.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: [
      Text(gen.toString()),
      DraggableScrollableSheet(
        builder: (ctx, ctl) => Container(
          color: Colors.lightGreen[100],
          child: ListView(
            controller: ctl,
            children: [
              ListTile(title: Text("temp")),
              ListTile(title: Text("top K")),
              ListTile(title: Text("top P")),
            ],
          ),
        ),
      ),
    ]);
  }
}
