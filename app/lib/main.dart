// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
// TODO: delete ^^^

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:ensemble_common/common.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

Logger _log = Logger('main.dart');

void main() {
  Logger.root.onRecord.listen((record) {
    debugPrint("${record.level.name}: ${record.time}: "
        "${record.loggerName}: "
        "${record.message}");
  });

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

  final TextEditingController _textCtl = TextEditingController();
  final ScrollController _scrollCtl = ScrollController();

  late final ClientChannel _channel;
  late final LlmClient _stub;
  ResponseStream<Token>? _resp;
  final StringBuffer _gen = StringBuffer();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _channel = ClientChannel(
      'brick',
      port: 8888,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _stub = LlmClient(
      _channel,
      options: CallOptions(timeout: const Duration(seconds: 30)),
    );

    _textCtl.addListener(() {
      _gen.clear();
      _gen.write(_textCtl.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textCtl.dispose();
    _scrollCtl.dispose();
    _channel.shutdown();
  }

  void _onFab() async {
    if (!_isGenerating) {
      _resp = _stub.generate(Prompt(text: _gen.toString()))
        ..listen(
          (tok) {
            if (tok.hasText()) {
              setState(() {
                _gen.write(tok.text);
                _textCtl.text = _gen.toString();
              });
            }
          },
          onDone: () => setState(() => _isGenerating = false),
          onError: (e) {
            _log.fine(e);
            setState(() => _isGenerating = false);
          },
          cancelOnError: true,
        );
      setState(() => _isGenerating = true);
    } else {
      await _resp?.cancel();
      setState(() => _isGenerating = false);
    }
  }

  double _topHeight = 500;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: 0, height: _topHeight, left: 0, right: 0, child: _genArea()),
          Positioned(top: _topHeight, bottom: 0, left: 0, right: 0, child: _params()),
          Positioned(top: _topHeight, left: 0, right: 0, height: 30, child: _dragBar())
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: _fab(),
    );
  }

  Widget _dragBar() {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        double screenHeight = MediaQuery.of(context).size.height;
        setState(() {
          _topHeight = (_topHeight + details.delta.dy).clamp(0.0, screenHeight);
        });
      },
      child: Container(color: Colors.blue),
    );
  }

  Widget _fab() {
    return FloatingActionButton(
      onPressed: _onFab,
      child:
          Icon(!_isGenerating ? Icons.play_circle_filled_sharp : Icons.pause_circle_filled_sharp),
    );
  }

  Widget _genArea() {
    const style = TextStyle(
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

    return Container(
      padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 0),
      child: _isGenerating
          ? SingleChildScrollView(child: Text(_gen.toString(), style: style))
          : GestureDetector(
              onTap: () {},
              child: TextField(
                autofocus: true,
                controller: _textCtl,
                scrollController: _scrollCtl,
                style: style,
                maxLines: null,
                decoration: null,
              )),
    );
  }

  Widget _params() {
    return Container(
      color: Colors.amber,
      child: ListView(
          children: ['Temperature', 'TopK', 'TopP', 'MinP']
              .map((p) => FilledButton.tonal(onPressed: () {}, child: Text(p)))
              .toList()),
    );
  }
}

void withx<T>(T x, void Function(T) f) => f(x);
