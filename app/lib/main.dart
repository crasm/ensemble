// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
// TODO: delete ^^^

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:ensemble_common/common.dart';
import 'package:grpc/grpc.dart';

void main() {
  runApp(const EnsembleApp());
}

class EnsembleApp extends StatelessWidget {
  const EnsembleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ensemble',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.lightBlue, brightness: Brightness.light)),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Ensemble'),
        actions: [
          PopupMenuButton(
            itemBuilder: (ctx) {
              return [
                PopupMenuItem(child: Text('Settings')),
              ];
            },
          )
        ],
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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _genScrollController = ScrollController();

  bool _isGenerating = false;

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
    stub.generate(Prompt(text: prompt)).listen(
          _loadGen,
          onDone: _onDoneGen,
          onError: _onErrorGen,
          cancelOnError: true,
        );
    _isGenerating = true;
  }

  void _loadGen(Token tok) {
    if (tok.hasText()) {
      setState(() {
        gen.write(tok.text);
        _controller.text = gen.toString();
      });
    }
  }

  void _onDoneGen() => _isGenerating = false;
  void _onErrorGen(e) => _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final genTextStyle = TextStyle(
      fontFamily: 'monospace',
      inherit: false,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      wordSpacing: 0.8,
      letterSpacing: 0.0,
      fontSize: 14.0,
      height: 1.3,
      leadingDistribution: null,
      textBaseline: TextBaseline.alphabetic,
    );

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: _isGenerating
            ? SingleChildScrollView(child: Text(gen.toString(), style: genTextStyle))
            : TextField(
                controller: _controller,
                scrollController: _genScrollController,
                style: genTextStyle,
                maxLines: null,
                decoration: null,
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _isGenerating = !_isGenerating),
        child:
            Icon(!_isGenerating ? Icons.play_circle_filled_sharp : Icons.pause_circle_filled_sharp),
      ),
      bottomSheet: DraggableScrollableSheet(
        maxChildSize: 0.70,
        initialChildSize: 0.15,
        minChildSize: 0.1,
        expand: false,
        snap: true,
        shouldCloseOnMinExtent: true,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          children: ['Temperature', 'TopK', 'TopP', 'MinP']
              .map((p) => FilledButton.tonal(onPressed: () {}, child: Text(p)))
              .toList(),
        ),
      ),
    );
  }
}
