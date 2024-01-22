//
//  Generated code. Do not modify.
//  source: llamacpp_samplers.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

enum Sampler_Sampler {
  temperature, 
  topK, 
  topP, 
  minP, 
  tailFree, 
  locallyTypical, 
  repetitionPenalty, 
  mirostatV1, 
  mirostatV2, 
  logitBias, 
  notSet
}

class Sampler extends $pb.GeneratedMessage {
  factory Sampler({
    Temperature? temperature,
    TopK? topK,
    TopP? topP,
    MinP? minP,
    TailFree? tailFree,
    LocallyTypical? locallyTypical,
    RepetitionPenalty? repetitionPenalty,
    MirostatV1? mirostatV1,
    MirostatV2? mirostatV2,
    LogitBias? logitBias,
  }) {
    final $result = create();
    if (temperature != null) {
      $result.temperature = temperature;
    }
    if (topK != null) {
      $result.topK = topK;
    }
    if (topP != null) {
      $result.topP = topP;
    }
    if (minP != null) {
      $result.minP = minP;
    }
    if (tailFree != null) {
      $result.tailFree = tailFree;
    }
    if (locallyTypical != null) {
      $result.locallyTypical = locallyTypical;
    }
    if (repetitionPenalty != null) {
      $result.repetitionPenalty = repetitionPenalty;
    }
    if (mirostatV1 != null) {
      $result.mirostatV1 = mirostatV1;
    }
    if (mirostatV2 != null) {
      $result.mirostatV2 = mirostatV2;
    }
    if (logitBias != null) {
      $result.logitBias = logitBias;
    }
    return $result;
  }
  Sampler._() : super();
  factory Sampler.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Sampler.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Sampler_Sampler> _Sampler_SamplerByTag = {
    1 : Sampler_Sampler.temperature,
    2 : Sampler_Sampler.topK,
    3 : Sampler_Sampler.topP,
    4 : Sampler_Sampler.minP,
    5 : Sampler_Sampler.tailFree,
    6 : Sampler_Sampler.locallyTypical,
    7 : Sampler_Sampler.repetitionPenalty,
    8 : Sampler_Sampler.mirostatV1,
    9 : Sampler_Sampler.mirostatV2,
    10 : Sampler_Sampler.logitBias,
    0 : Sampler_Sampler.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Sampler', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    ..aOM<Temperature>(1, _omitFieldNames ? '' : 'temperature', subBuilder: Temperature.create)
    ..aOM<TopK>(2, _omitFieldNames ? '' : 'topK', subBuilder: TopK.create)
    ..aOM<TopP>(3, _omitFieldNames ? '' : 'topP', subBuilder: TopP.create)
    ..aOM<MinP>(4, _omitFieldNames ? '' : 'minP', subBuilder: MinP.create)
    ..aOM<TailFree>(5, _omitFieldNames ? '' : 'tailFree', subBuilder: TailFree.create)
    ..aOM<LocallyTypical>(6, _omitFieldNames ? '' : 'locallyTypical', subBuilder: LocallyTypical.create)
    ..aOM<RepetitionPenalty>(7, _omitFieldNames ? '' : 'repetitionPenalty', subBuilder: RepetitionPenalty.create)
    ..aOM<MirostatV1>(8, _omitFieldNames ? '' : 'mirostatV1', subBuilder: MirostatV1.create)
    ..aOM<MirostatV2>(9, _omitFieldNames ? '' : 'mirostatV2', subBuilder: MirostatV2.create)
    ..aOM<LogitBias>(10, _omitFieldNames ? '' : 'logitBias', subBuilder: LogitBias.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Sampler clone() => Sampler()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Sampler copyWith(void Function(Sampler) updates) => super.copyWith((message) => updates(message as Sampler)) as Sampler;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Sampler create() => Sampler._();
  Sampler createEmptyInstance() => create();
  static $pb.PbList<Sampler> createRepeated() => $pb.PbList<Sampler>();
  @$core.pragma('dart2js:noInline')
  static Sampler getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Sampler>(create);
  static Sampler? _defaultInstance;

  Sampler_Sampler whichSampler() => _Sampler_SamplerByTag[$_whichOneof(0)]!;
  void clearSampler() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Temperature get temperature => $_getN(0);
  @$pb.TagNumber(1)
  set temperature(Temperature v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTemperature() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemperature() => clearField(1);
  @$pb.TagNumber(1)
  Temperature ensureTemperature() => $_ensure(0);

  @$pb.TagNumber(2)
  TopK get topK => $_getN(1);
  @$pb.TagNumber(2)
  set topK(TopK v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTopK() => $_has(1);
  @$pb.TagNumber(2)
  void clearTopK() => clearField(2);
  @$pb.TagNumber(2)
  TopK ensureTopK() => $_ensure(1);

  @$pb.TagNumber(3)
  TopP get topP => $_getN(2);
  @$pb.TagNumber(3)
  set topP(TopP v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTopP() => $_has(2);
  @$pb.TagNumber(3)
  void clearTopP() => clearField(3);
  @$pb.TagNumber(3)
  TopP ensureTopP() => $_ensure(2);

  @$pb.TagNumber(4)
  MinP get minP => $_getN(3);
  @$pb.TagNumber(4)
  set minP(MinP v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasMinP() => $_has(3);
  @$pb.TagNumber(4)
  void clearMinP() => clearField(4);
  @$pb.TagNumber(4)
  MinP ensureMinP() => $_ensure(3);

  @$pb.TagNumber(5)
  TailFree get tailFree => $_getN(4);
  @$pb.TagNumber(5)
  set tailFree(TailFree v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasTailFree() => $_has(4);
  @$pb.TagNumber(5)
  void clearTailFree() => clearField(5);
  @$pb.TagNumber(5)
  TailFree ensureTailFree() => $_ensure(4);

  @$pb.TagNumber(6)
  LocallyTypical get locallyTypical => $_getN(5);
  @$pb.TagNumber(6)
  set locallyTypical(LocallyTypical v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasLocallyTypical() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocallyTypical() => clearField(6);
  @$pb.TagNumber(6)
  LocallyTypical ensureLocallyTypical() => $_ensure(5);

  @$pb.TagNumber(7)
  RepetitionPenalty get repetitionPenalty => $_getN(6);
  @$pb.TagNumber(7)
  set repetitionPenalty(RepetitionPenalty v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasRepetitionPenalty() => $_has(6);
  @$pb.TagNumber(7)
  void clearRepetitionPenalty() => clearField(7);
  @$pb.TagNumber(7)
  RepetitionPenalty ensureRepetitionPenalty() => $_ensure(6);

  @$pb.TagNumber(8)
  MirostatV1 get mirostatV1 => $_getN(7);
  @$pb.TagNumber(8)
  set mirostatV1(MirostatV1 v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasMirostatV1() => $_has(7);
  @$pb.TagNumber(8)
  void clearMirostatV1() => clearField(8);
  @$pb.TagNumber(8)
  MirostatV1 ensureMirostatV1() => $_ensure(7);

  @$pb.TagNumber(9)
  MirostatV2 get mirostatV2 => $_getN(8);
  @$pb.TagNumber(9)
  set mirostatV2(MirostatV2 v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasMirostatV2() => $_has(8);
  @$pb.TagNumber(9)
  void clearMirostatV2() => clearField(9);
  @$pb.TagNumber(9)
  MirostatV2 ensureMirostatV2() => $_ensure(8);

  @$pb.TagNumber(10)
  LogitBias get logitBias => $_getN(9);
  @$pb.TagNumber(10)
  set logitBias(LogitBias v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasLogitBias() => $_has(9);
  @$pb.TagNumber(10)
  void clearLogitBias() => clearField(10);
  @$pb.TagNumber(10)
  LogitBias ensureLogitBias() => $_ensure(9);
}

class Temperature extends $pb.GeneratedMessage {
  factory Temperature({
    $core.double? temp,
  }) {
    final $result = create();
    if (temp != null) {
      $result.temp = temp;
    }
    return $result;
  }
  Temperature._() : super();
  factory Temperature.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Temperature.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Temperature', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'temp', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Temperature clone() => Temperature()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Temperature copyWith(void Function(Temperature) updates) => super.copyWith((message) => updates(message as Temperature)) as Temperature;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Temperature create() => Temperature._();
  Temperature createEmptyInstance() => create();
  static $pb.PbList<Temperature> createRepeated() => $pb.PbList<Temperature>();
  @$core.pragma('dart2js:noInline')
  static Temperature getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Temperature>(create);
  static Temperature? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get temp => $_getN(0);
  @$pb.TagNumber(1)
  set temp($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTemp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemp() => clearField(1);
}

class TopK extends $pb.GeneratedMessage {
  factory TopK({
    $core.int? topK,
  }) {
    final $result = create();
    if (topK != null) {
      $result.topK = topK;
    }
    return $result;
  }
  TopK._() : super();
  factory TopK.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TopK.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TopK', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'topK', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TopK clone() => TopK()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TopK copyWith(void Function(TopK) updates) => super.copyWith((message) => updates(message as TopK)) as TopK;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TopK create() => TopK._();
  TopK createEmptyInstance() => create();
  static $pb.PbList<TopK> createRepeated() => $pb.PbList<TopK>();
  @$core.pragma('dart2js:noInline')
  static TopK getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TopK>(create);
  static TopK? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get topK => $_getIZ(0);
  @$pb.TagNumber(1)
  set topK($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTopK() => $_has(0);
  @$pb.TagNumber(1)
  void clearTopK() => clearField(1);
}

class TopP extends $pb.GeneratedMessage {
  factory TopP({
    $core.double? topP,
  }) {
    final $result = create();
    if (topP != null) {
      $result.topP = topP;
    }
    return $result;
  }
  TopP._() : super();
  factory TopP.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TopP.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TopP', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'topP', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TopP clone() => TopP()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TopP copyWith(void Function(TopP) updates) => super.copyWith((message) => updates(message as TopP)) as TopP;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TopP create() => TopP._();
  TopP createEmptyInstance() => create();
  static $pb.PbList<TopP> createRepeated() => $pb.PbList<TopP>();
  @$core.pragma('dart2js:noInline')
  static TopP getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TopP>(create);
  static TopP? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get topP => $_getN(0);
  @$pb.TagNumber(1)
  set topP($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTopP() => $_has(0);
  @$pb.TagNumber(1)
  void clearTopP() => clearField(1);
}

class MinP extends $pb.GeneratedMessage {
  factory MinP({
    $core.double? minP,
  }) {
    final $result = create();
    if (minP != null) {
      $result.minP = minP;
    }
    return $result;
  }
  MinP._() : super();
  factory MinP.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MinP.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MinP', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'minP', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MinP clone() => MinP()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MinP copyWith(void Function(MinP) updates) => super.copyWith((message) => updates(message as MinP)) as MinP;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MinP create() => MinP._();
  MinP createEmptyInstance() => create();
  static $pb.PbList<MinP> createRepeated() => $pb.PbList<MinP>();
  @$core.pragma('dart2js:noInline')
  static MinP getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MinP>(create);
  static MinP? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get minP => $_getN(0);
  @$pb.TagNumber(1)
  set minP($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMinP() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinP() => clearField(1);
}

class TailFree extends $pb.GeneratedMessage {
  factory TailFree({
    $core.double? z,
  }) {
    final $result = create();
    if (z != null) {
      $result.z = z;
    }
    return $result;
  }
  TailFree._() : super();
  factory TailFree.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TailFree.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TailFree', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'z', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TailFree clone() => TailFree()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TailFree copyWith(void Function(TailFree) updates) => super.copyWith((message) => updates(message as TailFree)) as TailFree;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TailFree create() => TailFree._();
  TailFree createEmptyInstance() => create();
  static $pb.PbList<TailFree> createRepeated() => $pb.PbList<TailFree>();
  @$core.pragma('dart2js:noInline')
  static TailFree getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TailFree>(create);
  static TailFree? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get z => $_getN(0);
  @$pb.TagNumber(1)
  set z($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasZ() => $_has(0);
  @$pb.TagNumber(1)
  void clearZ() => clearField(1);
}

class LocallyTypical extends $pb.GeneratedMessage {
  factory LocallyTypical({
    $core.double? p,
  }) {
    final $result = create();
    if (p != null) {
      $result.p = p;
    }
    return $result;
  }
  LocallyTypical._() : super();
  factory LocallyTypical.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LocallyTypical.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LocallyTypical', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'p', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LocallyTypical clone() => LocallyTypical()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LocallyTypical copyWith(void Function(LocallyTypical) updates) => super.copyWith((message) => updates(message as LocallyTypical)) as LocallyTypical;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocallyTypical create() => LocallyTypical._();
  LocallyTypical createEmptyInstance() => create();
  static $pb.PbList<LocallyTypical> createRepeated() => $pb.PbList<LocallyTypical>();
  @$core.pragma('dart2js:noInline')
  static LocallyTypical getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LocallyTypical>(create);
  static LocallyTypical? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get p => $_getN(0);
  @$pb.TagNumber(1)
  set p($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasP() => $_has(0);
  @$pb.TagNumber(1)
  void clearP() => clearField(1);
}

class RepetitionPenalty extends $pb.GeneratedMessage {
  factory RepetitionPenalty({
    $core.int? lastN,
    $core.double? penalty,
    $core.double? frequencyPenalty,
    $core.double? presencePenalty,
    $core.bool? penalizeNewline,
  }) {
    final $result = create();
    if (lastN != null) {
      $result.lastN = lastN;
    }
    if (penalty != null) {
      $result.penalty = penalty;
    }
    if (frequencyPenalty != null) {
      $result.frequencyPenalty = frequencyPenalty;
    }
    if (presencePenalty != null) {
      $result.presencePenalty = presencePenalty;
    }
    if (penalizeNewline != null) {
      $result.penalizeNewline = penalizeNewline;
    }
    return $result;
  }
  RepetitionPenalty._() : super();
  factory RepetitionPenalty.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RepetitionPenalty.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RepetitionPenalty', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'lastN', $pb.PbFieldType.O3)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'penalty', $pb.PbFieldType.OF)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'frequencyPenalty', $pb.PbFieldType.OF)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'presencePenalty', $pb.PbFieldType.OF)
    ..aOB(5, _omitFieldNames ? '' : 'penalizeNewline', protoName: 'penalizeNewline')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RepetitionPenalty clone() => RepetitionPenalty()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RepetitionPenalty copyWith(void Function(RepetitionPenalty) updates) => super.copyWith((message) => updates(message as RepetitionPenalty)) as RepetitionPenalty;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepetitionPenalty create() => RepetitionPenalty._();
  RepetitionPenalty createEmptyInstance() => create();
  static $pb.PbList<RepetitionPenalty> createRepeated() => $pb.PbList<RepetitionPenalty>();
  @$core.pragma('dart2js:noInline')
  static RepetitionPenalty getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RepetitionPenalty>(create);
  static RepetitionPenalty? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get lastN => $_getIZ(0);
  @$pb.TagNumber(1)
  set lastN($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLastN() => $_has(0);
  @$pb.TagNumber(1)
  void clearLastN() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get penalty => $_getN(1);
  @$pb.TagNumber(2)
  set penalty($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPenalty() => $_has(1);
  @$pb.TagNumber(2)
  void clearPenalty() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get frequencyPenalty => $_getN(2);
  @$pb.TagNumber(3)
  set frequencyPenalty($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFrequencyPenalty() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrequencyPenalty() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get presencePenalty => $_getN(3);
  @$pb.TagNumber(4)
  set presencePenalty($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPresencePenalty() => $_has(3);
  @$pb.TagNumber(4)
  void clearPresencePenalty() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get penalizeNewline => $_getBF(4);
  @$pb.TagNumber(5)
  set penalizeNewline($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPenalizeNewline() => $_has(4);
  @$pb.TagNumber(5)
  void clearPenalizeNewline() => clearField(5);
}

class MirostatV1 extends $pb.GeneratedMessage {
  factory MirostatV1({
    $core.double? tau,
    $core.double? eta,
  }) {
    final $result = create();
    if (tau != null) {
      $result.tau = tau;
    }
    if (eta != null) {
      $result.eta = eta;
    }
    return $result;
  }
  MirostatV1._() : super();
  factory MirostatV1.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MirostatV1.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MirostatV1', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'tau', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'eta', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MirostatV1 clone() => MirostatV1()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MirostatV1 copyWith(void Function(MirostatV1) updates) => super.copyWith((message) => updates(message as MirostatV1)) as MirostatV1;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MirostatV1 create() => MirostatV1._();
  MirostatV1 createEmptyInstance() => create();
  static $pb.PbList<MirostatV1> createRepeated() => $pb.PbList<MirostatV1>();
  @$core.pragma('dart2js:noInline')
  static MirostatV1 getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MirostatV1>(create);
  static MirostatV1? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get tau => $_getN(0);
  @$pb.TagNumber(1)
  set tau($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTau() => $_has(0);
  @$pb.TagNumber(1)
  void clearTau() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get eta => $_getN(1);
  @$pb.TagNumber(2)
  set eta($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEta() => $_has(1);
  @$pb.TagNumber(2)
  void clearEta() => clearField(2);
}

class MirostatV2 extends $pb.GeneratedMessage {
  factory MirostatV2({
    $core.double? tau,
    $core.double? eta,
  }) {
    final $result = create();
    if (tau != null) {
      $result.tau = tau;
    }
    if (eta != null) {
      $result.eta = eta;
    }
    return $result;
  }
  MirostatV2._() : super();
  factory MirostatV2.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MirostatV2.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MirostatV2', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'tau', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'eta', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MirostatV2 clone() => MirostatV2()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MirostatV2 copyWith(void Function(MirostatV2) updates) => super.copyWith((message) => updates(message as MirostatV2)) as MirostatV2;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MirostatV2 create() => MirostatV2._();
  MirostatV2 createEmptyInstance() => create();
  static $pb.PbList<MirostatV2> createRepeated() => $pb.PbList<MirostatV2>();
  @$core.pragma('dart2js:noInline')
  static MirostatV2 getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MirostatV2>(create);
  static MirostatV2? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get tau => $_getN(0);
  @$pb.TagNumber(1)
  set tau($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTau() => $_has(0);
  @$pb.TagNumber(1)
  void clearTau() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get eta => $_getN(1);
  @$pb.TagNumber(2)
  set eta($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEta() => $_has(1);
  @$pb.TagNumber(2)
  void clearEta() => clearField(2);
}

class LogitBias extends $pb.GeneratedMessage {
  factory LogitBias({
    $core.Map<$core.int, $core.double>? bias,
  }) {
    final $result = create();
    if (bias != null) {
      $result.bias.addAll(bias);
    }
    return $result;
  }
  LogitBias._() : super();
  factory LogitBias.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LogitBias.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LogitBias', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..m<$core.int, $core.double>(1, _omitFieldNames ? '' : 'bias', entryClassName: 'LogitBias.BiasEntry', keyFieldType: $pb.PbFieldType.O3, valueFieldType: $pb.PbFieldType.OF, packageName: const $pb.PackageName('LlamaCpp'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LogitBias clone() => LogitBias()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LogitBias copyWith(void Function(LogitBias) updates) => super.copyWith((message) => updates(message as LogitBias)) as LogitBias;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogitBias create() => LogitBias._();
  LogitBias createEmptyInstance() => create();
  static $pb.PbList<LogitBias> createRepeated() => $pb.PbList<LogitBias>();
  @$core.pragma('dart2js:noInline')
  static LogitBias getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogitBias>(create);
  static LogitBias? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.int, $core.double> get bias => $_getMap(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
