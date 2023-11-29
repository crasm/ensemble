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
        backgroundColor: context.color.primary,
        foregroundColor: context.color.onPrimary,
        title: Text('Ensemble'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
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

    _textCtl.text = "A chat.\nUSER: ";
  }

  @override
  void dispose() {
    super.dispose();
    _textCtl.dispose();
    _scrollCtl.dispose();
    _channel.shutdown();
  }

  void _startGenerating() {
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
  }

  Future<void> _stopGenerating() async {
    await _resp?.cancel();
    setState(() => _isGenerating = false);
  }

  // Reasonable defaults (but should be updated immediately)
  bool _isHeightInitialized = false;
  double _maxHeight = 600.0;
  double _divTop = 400.0;
  final _divThickness = 32.0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: LayoutBuilder(builder: (context, box) {
        if (!_isHeightInitialized) {
          _isHeightInitialized = true;
          _maxHeight = box.maxHeight;
          _divTop = box.maxHeight / 3.0 * 2.0;
        }

        return Stack(
          children: [
            Positioned(top: 0, height: _divTop, left: 0, right: 0, child: _genArea()),
            Positioned(
                top: _divTop + _divThickness,
                bottom: 0,
                left: 0,
                right: 0,
                child: _params(context)),
            Positioned(
                top: _divTop, left: 0, right: 0, height: _divThickness, child: _divBar(context)),
          ],
        );
      }),
    );
  }

  final FocusNode _genFocusNode = FocusNode();

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
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: SingleChildScrollView(
        controller: _scrollCtl,
        child: Column(children: [
          SizedBox(height: 12),
          GestureDetector(
            onTap: _stopGenerating,
            child: _isGenerating
                ? Text(_gen.toString(), style: style)
                : TextField(
                    focusNode: _genFocusNode,
                    controller: _textCtl,
                    style: style,
                    maxLines: null,
                    decoration: null,
                  ),
          ),
          SizedBox(
              height: _divTop / 2,
              child: GestureDetector(onTap: _isGenerating ? _stopGenerating : _focusGenTail)),
        ]),
      ),
    );
  }

  void _focusGenTail() {
    if (!_genFocusNode.hasPrimaryFocus) {
      _genFocusNode.requestFocus();
      _textCtl.selection = TextSelection.fromPosition(TextPosition(offset: _textCtl.text.length));
    } else {
      _genFocusNode.unfocus();
    }
  }

  Widget _params(BuildContext context) {
    return Container(
      color: context.color.surfaceVariant,
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {},
              children: ['Temperature', 'Top K', 'Top P', 'Min P'].map((p) {
                return ListTile(key: Key(p), title: Text(p));
              }).toList(),
            ),
          ),
          Column(children: [
            IconButton.filled(
              onPressed: () => _isGenerating ? _stopGenerating() : _startGenerating(),
              iconSize: 48,
              icon: Icon(_isGenerating ? Icons.pause : Icons.play_arrow),
            ),
            Container(),
          ]),
        ],
      ),
    );
  }

  Widget _divBar(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _divTop = (_divTop + details.delta.dy).clamp(0.0, _maxHeight - _divThickness);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.color.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Icon(Icons.drag_handle, color: context.color.onSurfaceVariant),
      ),
    );
  }
}

extension<T> on T {
  void withas<R>(R Function(T) f) => f(this);
}

extension on BuildContext {
  ColorScheme get color => Theme.of(this).colorScheme;
}
