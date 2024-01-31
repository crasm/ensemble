import 'package:flutter/material.dart';

import 'package:ensemble_protos/llamacpp.dart' as pb;

sealed class Sampler {
  String get name;
  pb.Sampler get pbSampler;

  Widget _buildListChild(
    BuildContext context, {
    required Widget child,
  }) {
    return Card(
      key: Key(name),
      child: ListTile(
        title: Text(name),
        trailing: Container(child: child),
        onTap: () => showDialog(
          context: context,
          builder: buildDialog,
        ),
      ),
    );
  }

  Dialog _buildDialog(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text(name), ...children]),
      ),
    );
  }

  Widget buildListChild(BuildContext context);
  Dialog buildDialog(BuildContext context);
}

abstract class SamplerWithSingleNumValue<T extends num> extends Sampler {
  T value;
  late final TextEditingController _valueController;
  final T Function(String) parser;
  SamplerWithSingleNumValue(this.value, this.parser) {
    _valueController = TextEditingController(text: value.toString());
  }

  void dispose() => _valueController.dispose();

  Widget buildListChild(BuildContext context) =>
      _buildListChild(context, child: Text(value.toString()));

  Dialog buildDialog(BuildContext context) {
    return _buildDialog(context, children: [
      TextField(
        controller: _valueController,
        keyboardType: TextInputType.number,
        onSubmitted: (text) {
          value = parser(text);
        },
      ),
    ]);
  }
}

final class SamplerLogitBias extends Sampler {
  final Map<int, double> bias;
  SamplerLogitBias(this.bias);

  @override
  String get name => 'Logit Bias';

  @override
  pb.Sampler get pbSampler => pb.Sampler(logitBias: pb.LogitBias(bias: bias));

  @override
  Widget buildListChild(BuildContext context) {
    return _buildListChild(context, child: Text(bias.toString()));
  }

  @override
  Dialog buildDialog(BuildContext context) {
    return _buildDialog(context, children: [
      Text('unimplemented'),
    ]);
  }
}

final class SamplerRepetitionPenalty extends Sampler {
  int lastN;
  double penalty;
  double presencePenalty;
  double frequencyPenalty;
  SamplerRepetitionPenalty({
    required this.lastN,
    required this.penalty,
    required this.presencePenalty,
    required this.frequencyPenalty,
  });

  @override
  String get name => 'Repetition Penalty';

  @override
  pb.Sampler get pbSampler {
    return pb.Sampler(
      repetitionPenalty: pb.RepetitionPenalty(
        lastN: lastN,
        penalty: penalty,
        presencePenalty: presencePenalty,
        frequencyPenalty: frequencyPenalty,
      ),
    );
  }

  @override
  Widget buildListChild(BuildContext context) {
    return _buildListChild(
      context,
      child: Container(
        child: Text(
          'lastN=$lastN, penalty=$penalty\n'
          'presencePenalty=$presencePenalty\n'
          'frequencyPenalty=$frequencyPenalty',
        ),
      ),
    );
  }

  @override
  Dialog buildDialog(BuildContext context) {
    return _buildDialog(context, children: [
      Text('unimplemented'),
    ]);
  }
}

class SamplerMinP extends SamplerWithSingleNumValue<double> {
  SamplerMinP(double minP) : super(minP, double.parse);

  @override
  String get name => 'Min P';

  @override
  pb.Sampler get pbSampler => pb.Sampler(minP: pb.MinP(minP: value));
}

class SamplerTemperature extends SamplerWithSingleNumValue<double> {
  SamplerTemperature(double temp) : super(temp, double.parse);

  @override
  String get name => 'Temperature';

  @override
  pb.Sampler get pbSampler =>
      pb.Sampler(temperature: pb.Temperature(temp: value));
}
