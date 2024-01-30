import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';
import 'package:state_machine/state_machine.dart' as sm;

import 'package:ensemble_protos/llamacpp.dart' as pb;
import 'package:ensemble_app/samplers.dart';
import 'package:ensemble_app/misc.dart';

final _log = Logger('mode_completions');

late final sm.State _isViewing, _isEditing, _isPreparing, _isGenerating;
late final sm.StateTransition _doPrepare, _doGenerate, _doStop;

// Called by main()
void initializeStateMachine() {
  final state = sm.StateMachine('gen page state');

  _isViewing = state.newState('viewing');
  _isEditing = state.newState('editing');
  _isPreparing = state.newState('preparing');
  _isGenerating = state.newState('generating');

  _doPrepare = state.newStateTransition(
    'prepare',
    [_isViewing, _isEditing],
    _isPreparing,
  );
  _doGenerate = state.newStateTransition(
    'generate',
    [_isPreparing],
    _isGenerating,
  );
  _doStop = state.newStateTransition(
    'stop preparing or generating',
    [_isPreparing, _isGenerating],
    _isViewing,
  );

  state.start(_isViewing);
}

final List<Sampler> _samplers = [
  SamplerLogitBias({2: double.negativeInfinity}),
  SamplerRepetitionPenalty(
    lastN: -1,
    penalty: 1.1,
    presencePenalty: 0.0,
    frequencyPenalty: 0.0,
  ),
  SamplerMinP(0.07),
  SamplerTemperature(0.64),
];

class CompletionsPage extends StatefulWidget {
  const CompletionsPage({super.key});
  @override
  State<StatefulWidget> createState() => _CompletionsPageState();
}

class _CompletionsController extends TextEditingController {
  static const _prompt = 'A chat.\nUSER:';
  int _i = 0;
  int _pin = 0;
  final List<({DateTime datetime, String text})> _history = [
    (datetime: DateTime.now(), text: _prompt),
  ];
  _CompletionsController() : super(text: _prompt);

  /// Get the datetime of the currently selected completion snapshot.
  DateTime get datetime => _history[_i].datetime;

  /// Save the value of the current text to a new slot and change position to
  /// that slot.
  void save() {
    _history.add((datetime: DateTime.now(), text: text));
    _i = _history.length - 1;
  }

  /// Remove the most recently added item.
  void pop() => _i = --_history.length - 1;

  /// True if the current item is the pinned item.
  bool get isPinned => _i == _pin;

  /// Mark the current slot as the "pinned" slot, so that [goToPin] navigates to it.
  void pin() => _pin = _i;

  /// Navigate to the pinned history item.
  void goToPin() => text = _history[_i = _pin].text;

  /// Navigate forward in history.
  void goForward() {
    if (_i + 1 < _history.length) {
      text = _history[++_i].text;
    }
  }

  /// Navigate backward in history.
  void goBackward() {
    if (_i > 0) {
      text = _history[--_i].text;
    }
  }
}

class _CompletionsPageState extends State<CompletionsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollCtl = ScrollController();
  final UndoHistoryController _undoCtl = UndoHistoryController();
  final _CompletionsController _completionsCtl = _CompletionsController();
  bool _fingerTouchingScrollArea = false;

  late final ClientChannel _channel;
  late final pb.LlamaCppClient _client;

  late final Future<int> _ctx;

  ResponseStream<pb.Token>? _generateResp;
  ResponseStream<pb.IngestProgressResp>? _ingestResp;

  List<pb.Token> _decodedTokens = [];

  @override
  void initState() {
    super.initState();

    _doPrepare.stream.listen((_) {
      setState(() {});
      _onPrepare();
      setState(() {});
    });
    _doGenerate.stream.listen((_) {
      setState(() {});
      _onGenerate();
      setState(() {});
    });
    _doStop.stream.listen((_) {
      setState(() {});
      _onStop();
      setState(() {});
    });

    _channel = ClientChannel(
      'brick',
      port: 8227,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _client = pb.LlamaCppClient(_channel);

    _ctx = () async {
      final resp = await _client.newContext(
        pb.NewContextArgs(
          nCtx: 2048,
          nBatch: 512,
          // ropeScalingType: 1,
          // ropeFreqScale: 0.50,
        ),
      );

      assert(resp.hasCtx());
      return resp.ctx;
    }();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCtl.dispose();
    _undoCtl.dispose();
    _completionsCtl.dispose();
    () async {
      _client.freeContext(pb.FreeContextArgs(ctx: await _ctx));
      _channel.shutdown();
    }();
  }

  String _contextString() {
    StringBuffer buf = StringBuffer();
    _decodedTokens.forEach((tok) => buf.write(tok.text));
    return buf.toString();
  }

  String _runesToString(Iterable<int> runes) {
    final buf = StringBuffer();
    runes.forEach(buf.writeCharCode);
    return buf.toString();
  }

  void Function(Object) _onGrpcError(String task) {
    return (Object o) {
      // This is commonly triggered when the call is canceled client-side.
      final GrpcError e = o as GrpcError;
      if (_isPreparing() || _isGenerating()) _doStop();
      switch (e.code) {
        case StatusCode.cancelled:
          _log.info('$task was cancelled');
          _log.finest(e);
        default:
          _log.severe(e);
      }
    };
  }

  Future<void> _onPrepare() async {
    // TODO(crasm): should trimming be a configurable option?
    final buf = _completionsCtl.text;
    final ctx = await _ctx;

    //
    // Figure out if we need to trim the context, and how much text to add
    var i = 0; // token index
    var j = 0; // rune index
    if (_decodedTokens.isNotEmpty) {
      final bufRunes = buf.runes.toList(growable: false);

      // Match the completions buffer against our prior decoded tokens to see
      // what has already been decoded.
      while (i < _decodedTokens.length) {
        final tokRunes = _decodedTokens[i].text.runes.toList(growable: false);

        if (j + tokRunes.length <= bufRunes.length) {
          final bufTokMatch = bufRunes.sublist(j, j + tokRunes.length);
          if (listEquals(tokRunes, bufTokMatch)) {
            // The text is unchanged, so we can skip decoding this token again.
            i++;
            j += tokRunes.length;
            continue;
          } else {
            _log.fine('First token that has changed:'
                ' `${_runesToString(tokRunes)}`'
                ' != `${_runesToString(bufTokMatch)}`');
          }
        }

        break;
      }
    }

    _log.info('Trimming context window to $i tokens');
    _decodedTokens.length = i;
    await _client.trim(pb.TrimArgs(ctx: ctx, length: i));

    //
    // Add needed text, and decode
    _log.info('Adding and tokenizing ${buf.runes.length - j} runes');
    final addedTokens = await _client.addText(pb.AddTextArgs(
      ctx: ctx,
      text: _runesToString(buf.runes.skip(j)),
    ));
    _log.info('Added ${addedTokens.toks.length} tokens');
    _decodedTokens.addAll(addedTokens.toks);

    _log.info('Ingesting context');
    bool wasInterrupted = false;
    _ingestResp = _client.ingest(pb.IngestArgs(ctx: ctx))
      ..listen(
        (progress) {
          _log.info('Ingesting progress: ${progress.done}/${progress.total} '
              '(batch size: ${progress.batchSize})');
        },
        onError: (e) {
          wasInterrupted = true;
          setState(() => _completionsCtl.pop());
          _onGrpcError('Ingestion')(e);
        },
        onDone: () {
          if (!wasInterrupted) _doGenerate();
        },
      );
  }

  /// Generates new tokens
  Future<void> _onGenerate() async {
    _log.info('Generating started');
    _generateResp = _client.generate(pb.GenerateArgs(
      ctx: await _ctx,
      samplers: _samplers.map((a) => a.pbSampler).toList(),
    ))
      ..listen(
        (tok) {
          if (tok.hasText()) {
            _decodedTokens.add(tok);
            _completionsCtl.text = _contextString();

            final s = _scrollCtl;
            if (s.hasClients) {
              final max = s.position.maxScrollExtent;
              final delta = max - s.offset;
              // _log.finer('scroll distance to end: $delta');
              // Noticed 18.0 delta in log files
              if (!_fingerTouchingScrollArea && delta <= 36.0) {
                s.jumpTo(max);
              }
            }

            setState(() {/* Added a generated token */});
          }
        },
        onDone: () {
          _log.fine('Generating done');
          _completionsCtl.save();
          _doStop();
        },
        onError: (e) {
          _completionsCtl.save();
          _onGrpcError('Generation')(e);
        },
        cancelOnError: true,
      );
  }

  Future<void> _onStop() async {
    await _ingestResp?.cancel();
    await _generateResp?.cancel();
    _ingestResp = null;
    _generateResp = null;
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
                child: _ControlPane(_completionsCtl, _undoCtl)),
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

      final genText = TextSpan(text: _completionsCtl.text, style: style);
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
            _isGenerating()
                ? Text(_contextString(), style: style)
                : TextField(
                    focusNode: _genFocusNode,
                    controller: _completionsCtl,
                    undoController: _undoCtl,
                    style: style,
                    maxLines: null,
                    decoration: null,
                  ),
            // ),
            SizedBox(
              height: mustScroll ? _divTop / 2 : _divTop - textHeightPadded,
              child: GestureDetector(
                onTap: () => _isGenerating() ? _doStop() : _focusGenTail(),
              ),
            ),
          ],
        ),
      );

      return Listener(
        onPointerDown: (_) => _fingerTouchingScrollArea = true,
        onPointerUp: (_) => _fingerTouchingScrollArea = false,
        child: GestureDetector(
          onTap: () => _isGenerating() ? _doStop() : null,
          child:
              SingleChildScrollView(controller: _scrollCtl, child: mainColumn),
        ),
      );
    });
  }

  void _focusGenTail() {
    if (!_genFocusNode.hasPrimaryFocus) {
      _genFocusNode.requestFocus();
      _completionsCtl.selection = TextSelection.fromPosition(
          TextPosition(offset: _completionsCtl.text.length));
    } else {
      _genFocusNode.unfocus();
    }
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

class _ControlPane extends StatefulWidget {
  final _CompletionsController _completionsCtl;
  final UndoHistoryController _undoCtl;
  const _ControlPane(this._completionsCtl, this._undoCtl);
  @override
  State<_ControlPane> createState() => _ControlPaneState();
}

class _ControlPaneState extends State<_ControlPane> {
  bool _doFlip = false;
  @override
  Widget build(BuildContext context) {
    final contextDirection = Directionality.of(context);
    final flipBar = GestureDetector(
      onTap: withSetState(() => _doFlip = !_doFlip),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chevron_left, size: 16.0),
          Icon(Icons.chevron_right, size: 16.0),
        ],
      ),
    );
    return Container(
      color: context.color.surfaceVariant,
      padding: EdgeInsets.symmetric(horizontal: 3.0),
      child: Directionality(
        textDirection: _doFlip
            ? TextDirection.values[(contextDirection.index + 1) % 2]
            : contextDirection,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            flipBar,
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) newIndex--;
                  _samplers.insert(newIndex, _samplers.removeAt(oldIndex));
                  setState(() {});
                },
                children:
                    _samplers.map((a) => a.buildListChild(context)).toList(),
              ),
            ),
            Column(children: [
              IconButton.filled(
                onPressed: () {
                  if (_isPreparing() || _isGenerating()) {
                    _doStop();
                  } else {
                    _doPrepare();
                  }
                },
                iconSize: 48,
                icon: Icon(_isPreparing() || _isGenerating()
                    ? Icons.pause
                    : Icons.play_arrow),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: withSetState(widget._completionsCtl.pin),
                    icon: Icon(!_isPreparing() &&
                            !_isGenerating() &&
                            widget._completionsCtl.isPinned
                        ? Icons.push_pin
                        : Icons.push_pin_outlined),
                  ),
                  IconButton(
                    onPressed: withSetState(widget._completionsCtl.goToPin),
                    icon: Icon(Icons.refresh),
                  )
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: withSetState(widget._completionsCtl.goBackward),
                    icon: Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: withSetState(widget._completionsCtl.goForward),
                    icon: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: widget._undoCtl.undo, icon: Icon(Icons.undo)),
                  IconButton(
                      onPressed: widget._undoCtl.redo, icon: Icon(Icons.redo)),
                ],
              ),
            ]),
            flipBar,
          ]
              .map((a) =>
                  Directionality(textDirection: contextDirection, child: a))
              .toList(growable: false),
        ),
      ),
    );
  }
}
