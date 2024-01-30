import 'package:flutter/material.dart';

import 'package:ensemble_protos/llamacpp.dart' as pb;

sealed class Sampler {
  String get name;
  pb.Sampler get pbSampler;
  Widget buildListChild(BuildContext context);
  Dialog buildDialog(BuildContext context);
}

abstract class SamplerWithSingleValue<T> extends Sampler {
  T value;
  SamplerWithSingleValue(this.value);

  Widget buildListChild(BuildContext context) {
    return Card(
      key: Key(name),
      child: ListTile(
        title: Text(name),
        trailing: Container(child: Text(value.toString())),
        onTap: () => showDialog(
          context: context,
          builder: buildDialog,
        ),
      ),
    );
  }

  Dialog buildDialog(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(name),
        ]),
      ),
    );
  }
}

final class SamplerLogitBias extends SamplerWithSingleValue<Map<int, double>> {
  SamplerLogitBias(Map<int, double> bias) : super(bias);
  @override
  String get name => 'Logit Bias';

  @override
  pb.Sampler get pbSampler => pb.Sampler(logitBias: pb.LogitBias(bias: value));
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
    return Card(
      key: Key(name),
      child: ListTile(
        title: Text(name),
        trailing: Container(
          child: Text(
            'lastN=$lastN, penalty=$penalty\n'
            'presencePenalty=$presencePenalty\n'
            'frequencyPenalty=$frequencyPenalty',
          ),
        ),
        onTap: () => showDialog(
          context: context,
          builder: buildDialog,
        ),
      ),
    );
  }

  @override
  Dialog buildDialog(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(name),
        ]),
      ),
    );
  }
}

class SamplerMinP extends SamplerWithSingleValue<double> {
  SamplerMinP(double minP) : super(minP);

  @override
  String get name => 'Min P';

  @override
  pb.Sampler get pbSampler => pb.Sampler(minP: pb.MinP(minP: value));
}

class SamplerTemperature extends SamplerWithSingleValue<double> {
  SamplerTemperature(double temp) : super(temp);

  @override
  String get name => 'Temperature';

  @override
  pb.Sampler get pbSampler =>
      pb.Sampler(temperature: pb.Temperature(temp: value));
}
