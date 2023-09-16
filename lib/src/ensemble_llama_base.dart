import 'dart:io';
import 'dart:isolate';

void main() {
  var llama = Llama();
  llama.listen();
}

class Llama {
  final ReceivePort _msg = ReceivePort("I receive messages");
  late Future<SendPort> _control;
  Llama() {
    final controlHelperRecvPort = ReceivePort("I help set up the control port");
    _control = controlHelperRecvPort.first.then((sp) => sp as SendPort);
    Isolate.spawn(_isolateEntryPoint,
        [controlHelperRecvPort.sendPort, _msg.sendPort]);
  }

  void listen() async {
    var i = 0;
    _msg.listen((m) {
      print(m.toString());
      if (i++ >= 2) {
        dispose();
      }
    });
  }

  void dispose() {
    _msg.close();
    _control.then((ctl) => ctl.send(0));
  }
}

void _isolateEntryPoint(List<dynamic> values) {
  final SendPort controlHelper = values[0];
  final control = ReceivePort("I receive control messages");
  controlHelper.send(control.sendPort);

  final SendPort msgs = values[1];

  var exit = false;
  control.single.then((value) => exit = true);
  while (!exit) {
    msgs.send("hello, ${DateTime.now().millisecondsSinceEpoch ~/ 1000}");
    sleep(Duration(seconds: 1));
  }
}
