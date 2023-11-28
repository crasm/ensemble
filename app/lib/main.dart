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

  late final ClientChannel channel;
  late final LlmClient stub;

  final String prompt = "Hello, my name is";
  late final StringBuffer gen;
  final TextEditingController _genTextController = TextEditingController();
  final ScrollController _genScrollController = ScrollController();
  final DraggableScrollableController _paramsSheetController = DraggableScrollableController();

  ResponseStream<Token>? _resp;
  bool _isGenerating = false;

  final _genTextStyle = TextStyle(
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

    _genTextController.addListener(() {
      gen.clear();
      gen.write(_genTextController.text);
    });

    gen = StringBuffer(prompt);
  }

  @override
  void dispose() {
    super.dispose();
    _genTextController.dispose();
  }

  void _loadGen(Token tok) {
    if (tok.hasText()) {
      setState(() {
        gen.write(tok.text);
        _genTextController.text = gen.toString();
      });
    }
  }

  void _onDoneGen() => setState(() => _isGenerating = false);
  void _onErrorGen(e) {
    _log.fine(e);
    setState(() => _isGenerating = false);
  }

  void _onFab() async {
    if (!_isGenerating) {
      _resp = stub.generate(Prompt(text: gen.toString()))
        ..listen(
          _loadGen,
          onDone: _onDoneGen,
          onError: _onErrorGen,
          cancelOnError: true,
        );
      setState(() => _isGenerating = true);
    } else {
      await _resp!.cancel();
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _topHeight,
            child: GenTextField(
                isGenerating: _isGenerating,
                gen: gen,
                genTextStyle: _genTextStyle,
                genTextController: _genTextController,
                genScrollController: _genScrollController),
          ),
          Positioned(
            top: _topHeight,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.amber,
              child: ListView(
                children: ['Temperature', 'TopK', 'TopP', 'MinP']
                    .map((p) => FilledButton.tonal(onPressed: () {}, child: Text(p)))
                    .toList(),
              ),
            ),
          ),
          Positioned(
            top: _topHeight,
            left: 0,
            right: 0,
            height: 30,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                double screenHeight = MediaQuery.of(context).size.height;
                setState(() {
                  _topHeight = (_topHeight + details.delta.dy).clamp(0.0, screenHeight);
                  withx(_genScrollController, (ctl) {
                    ctl.animateTo(
                      ctl.offset - details.delta.dy,
                      duration: Duration(microseconds: 1),
                      curve: Curves.linear,
                    );
                  });
                });
              },
              child: Container(color: Colors.blue),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: _onFab,
        child:
            Icon(!_isGenerating ? Icons.play_circle_filled_sharp : Icons.pause_circle_filled_sharp),
      ),
    );
  }
}

class GenTextField extends StatelessWidget {
  const GenTextField({
    super.key,
    required bool isGenerating,
    required this.gen,
    required TextStyle genTextStyle,
    required TextEditingController genTextController,
    required ScrollController genScrollController,
  })  : _isGenerating = isGenerating,
        _genTextStyle = genTextStyle,
        _genTextController = genTextController,
        _genScrollController = genScrollController;

  final bool _isGenerating;
  final StringBuffer gen;
  final TextStyle _genTextStyle;
  final TextEditingController _genTextController;
  final ScrollController _genScrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 0),
      child: _isGenerating
          ? SingleChildScrollView(child: Text(gen.toString(), style: _genTextStyle))
          : GestureDetector(
              onTap: () {},
              child: TextField(
                autofocus: true,
                controller: _genTextController,
                scrollController: _genScrollController,
                style: _genTextStyle,
                maxLines: null,
                decoration: null,
              )),
    );
  }
}

void withx<T>(T x, void Function(T) f) => f(x);
