// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
// TODO: delete ^^^

import 'package:flutter/material.dart';

import 'package:ensemble_protos/llamacpp.dart' as pb;
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

Logger _log = Logger('main.dart');

void main() {
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: '
        '${record.loggerName}: '
        '${record.message}');
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue,
            brightness: Brightness.light,
          )),
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

  final ScrollController _scrollCtl = ScrollController();

  late final ClientChannel _channel;
  late final pb.LlamaCppClient _stub;

  late final Future<pb.Context> _ctx;

  bool _isGenerating = false;

  ResponseStream<pb.Token>? _resp;

  final TextEditingController _textCtl = TextEditingController();
  List<pb.Token> _decodedTokens = [];

  @override
  void initState() {
    super.initState();
    _channel = ClientChannel(
      'brick',
      port: 8888,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _stub = pb.LlamaCppClient(
      _channel,
      options: CallOptions(timeout: const Duration(seconds: 30)),
    );

    _textCtl.text = 'A chat.\nUSER: ';

    _ctx = _stub.newContext(pb.NewContextRequest());
  }

  @override
  void dispose() {
    super.dispose();
    _textCtl.dispose();
    _scrollCtl.dispose();
    _channel.shutdown();
  }

  String _contextString() {
    StringBuffer buf = StringBuffer();
    for (final tok in _decodedTokens) {
      buf.write(tok.text);
    }
    return buf.toString();
  }

  Future<void> _startGenerating() async {
    final newText = _textCtl.text;
    final ctx = await _ctx;

    final addedTokens = await _stub.addText(pb.AddTextRequest(
      context: ctx,
      text: pb.Text(text: newText),
    ));

    _decodedTokens.addAll(addedTokens.toks);
    _stub.ingest(ctx);

    _resp = _stub.generate(ctx)
      ..listen(
        (tok) {
          if (tok.hasText()) {
            _decodedTokens.add(tok);
            _textCtl.text = _contextString();
            setState(() {/* Added a generated token */});
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
            Positioned(
                top: 0,
                height: _divTop,
                left: 0,
                right: 0,
                child: _genArea(context)),
            Positioned(
                top: _divTop + _divThickness,
                bottom: 0,
                left: 0,
                right: 0,
                child: _params(context)),
            Positioned(
                top: _divTop,
                left: 0,
                right: 0,
                height: _divThickness,
                child: _divBar(context)),
          ],
        );
      }),
    );
  }

  final FocusNode _genFocusNode = FocusNode();

  Widget _genArea(BuildContext ctx) {
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

    return LayoutBuilder(builder: (context, box) {
      const topPadding = 12.0;
      const horizontalPadding = 12.0;

      final genText = TextSpan(text: _textCtl.text, style: style);
      final painter =
          TextPainter(text: genText, textDirection: TextDirection.ltr);

      painter.layout(maxWidth: box.maxWidth - 2 * horizontalPadding);
      final textHeightPadded = painter.height + topPadding;
      painter.dispose();

      final mustScroll = textHeightPadded > _divTop / 2;

      final mainColumn = Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topPadding),
            GestureDetector(
              onTap: _stopGenerating,
              child: _isGenerating
                  ? Text(_contextString(), style: style)
                  : TextField(
                      focusNode: _genFocusNode,
                      controller: _textCtl,
                      style: style,
                      maxLines: null,
                      decoration: null,
                    ),
            ),
            SizedBox(
                height: mustScroll ? _divTop / 2 : _divTop - textHeightPadded,
                child: GestureDetector(
                    onTap: _isGenerating ? _stopGenerating : _focusGenTail)),
          ],
        ),
      );

      return mustScroll
          ? SingleChildScrollView(controller: _scrollCtl, child: mainColumn)
          : mainColumn;
    });
  }

  void _focusGenTail() {
    if (!_genFocusNode.hasPrimaryFocus) {
      _genFocusNode.requestFocus();
      _textCtl.selection = TextSelection.fromPosition(
          TextPosition(offset: _textCtl.text.length));
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
              onPressed: () =>
                  _isGenerating ? _stopGenerating() : _startGenerating(),
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
          _divTop = (_divTop + details.delta.dy)
              .clamp(0.0, _maxHeight - _divThickness);
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
