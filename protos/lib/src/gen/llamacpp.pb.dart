//
//  Generated code. Do not modify.
//  source: llamacpp.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Void extends $pb.GeneratedMessage {
  factory Void() => create();
  Void._() : super();
  factory Void.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Void.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Void', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Void clone() => Void()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Void copyWith(void Function(Void) updates) => super.copyWith((message) => updates(message as Void)) as Void;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Void create() => Void._();
  Void createEmptyInstance() => create();
  static $pb.PbList<Void> createRepeated() => $pb.PbList<Void>();
  @$core.pragma('dart2js:noInline')
  static Void getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Void>(create);
  static Void? _defaultInstance;
}

class NewContextArgs extends $pb.GeneratedMessage {
  factory NewContextArgs({
    $core.int? seed,
    $core.int? nCtx,
    $core.int? nBatch,
    $core.int? nThreads,
    $core.int? nThreadsBatch,
    $core.int? ropeScalingType,
    $core.double? ropeFreqBase,
    $core.double? ropeFreqScale,
    $core.double? yarnExtFactor,
    $core.double? yarnAttnFactor,
    $core.double? yarnBetaFast,
    $core.double? yarnBetaSlow,
    $core.int? yarnOrigCtx,
    $core.int? typeK,
    $core.int? typeV,
    $core.bool? embedding,
    $core.bool? offloadKqv,
  }) {
    final $result = create();
    if (seed != null) {
      $result.seed = seed;
    }
    if (nCtx != null) {
      $result.nCtx = nCtx;
    }
    if (nBatch != null) {
      $result.nBatch = nBatch;
    }
    if (nThreads != null) {
      $result.nThreads = nThreads;
    }
    if (nThreadsBatch != null) {
      $result.nThreadsBatch = nThreadsBatch;
    }
    if (ropeScalingType != null) {
      $result.ropeScalingType = ropeScalingType;
    }
    if (ropeFreqBase != null) {
      $result.ropeFreqBase = ropeFreqBase;
    }
    if (ropeFreqScale != null) {
      $result.ropeFreqScale = ropeFreqScale;
    }
    if (yarnExtFactor != null) {
      $result.yarnExtFactor = yarnExtFactor;
    }
    if (yarnAttnFactor != null) {
      $result.yarnAttnFactor = yarnAttnFactor;
    }
    if (yarnBetaFast != null) {
      $result.yarnBetaFast = yarnBetaFast;
    }
    if (yarnBetaSlow != null) {
      $result.yarnBetaSlow = yarnBetaSlow;
    }
    if (yarnOrigCtx != null) {
      $result.yarnOrigCtx = yarnOrigCtx;
    }
    if (typeK != null) {
      $result.typeK = typeK;
    }
    if (typeV != null) {
      $result.typeV = typeV;
    }
    if (embedding != null) {
      $result.embedding = embedding;
    }
    if (offloadKqv != null) {
      $result.offloadKqv = offloadKqv;
    }
    return $result;
  }
  NewContextArgs._() : super();
  factory NewContextArgs.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NewContextArgs.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NewContextArgs', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'seed', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'nCtx', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'nBatch', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'nThreads', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'nThreadsBatch', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'ropeScalingType', $pb.PbFieldType.O3)
    ..a<$core.double>(8, _omitFieldNames ? '' : 'ropeFreqBase', $pb.PbFieldType.OF)
    ..a<$core.double>(9, _omitFieldNames ? '' : 'ropeFreqScale', $pb.PbFieldType.OF)
    ..a<$core.double>(10, _omitFieldNames ? '' : 'yarnExtFactor', $pb.PbFieldType.OF)
    ..a<$core.double>(11, _omitFieldNames ? '' : 'yarnAttnFactor', $pb.PbFieldType.OF)
    ..a<$core.double>(12, _omitFieldNames ? '' : 'yarnBetaFast', $pb.PbFieldType.OF)
    ..a<$core.double>(13, _omitFieldNames ? '' : 'yarnBetaSlow', $pb.PbFieldType.OF)
    ..a<$core.int>(14, _omitFieldNames ? '' : 'yarnOrigCtx', $pb.PbFieldType.OU3)
    ..a<$core.int>(15, _omitFieldNames ? '' : 'typeK', $pb.PbFieldType.O3)
    ..a<$core.int>(16, _omitFieldNames ? '' : 'typeV', $pb.PbFieldType.O3)
    ..aOB(17, _omitFieldNames ? '' : 'embedding')
    ..aOB(18, _omitFieldNames ? '' : 'offloadKqv')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NewContextArgs clone() => NewContextArgs()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NewContextArgs copyWith(void Function(NewContextArgs) updates) => super.copyWith((message) => updates(message as NewContextArgs)) as NewContextArgs;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NewContextArgs create() => NewContextArgs._();
  NewContextArgs createEmptyInstance() => create();
  static $pb.PbList<NewContextArgs> createRepeated() => $pb.PbList<NewContextArgs>();
  @$core.pragma('dart2js:noInline')
  static NewContextArgs getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NewContextArgs>(create);
  static NewContextArgs? _defaultInstance;

  @$pb.TagNumber(2)
  $core.int get seed => $_getIZ(0);
  @$pb.TagNumber(2)
  set seed($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(2)
  $core.bool hasSeed() => $_has(0);
  @$pb.TagNumber(2)
  void clearSeed() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get nCtx => $_getIZ(1);
  @$pb.TagNumber(3)
  set nCtx($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasNCtx() => $_has(1);
  @$pb.TagNumber(3)
  void clearNCtx() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get nBatch => $_getIZ(2);
  @$pb.TagNumber(4)
  set nBatch($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(4)
  $core.bool hasNBatch() => $_has(2);
  @$pb.TagNumber(4)
  void clearNBatch() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get nThreads => $_getIZ(3);
  @$pb.TagNumber(5)
  set nThreads($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasNThreads() => $_has(3);
  @$pb.TagNumber(5)
  void clearNThreads() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get nThreadsBatch => $_getIZ(4);
  @$pb.TagNumber(6)
  set nThreadsBatch($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasNThreadsBatch() => $_has(4);
  @$pb.TagNumber(6)
  void clearNThreadsBatch() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get ropeScalingType => $_getIZ(5);
  @$pb.TagNumber(7)
  set ropeScalingType($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(7)
  $core.bool hasRopeScalingType() => $_has(5);
  @$pb.TagNumber(7)
  void clearRopeScalingType() => clearField(7);

  @$pb.TagNumber(8)
  $core.double get ropeFreqBase => $_getN(6);
  @$pb.TagNumber(8)
  set ropeFreqBase($core.double v) { $_setFloat(6, v); }
  @$pb.TagNumber(8)
  $core.bool hasRopeFreqBase() => $_has(6);
  @$pb.TagNumber(8)
  void clearRopeFreqBase() => clearField(8);

  @$pb.TagNumber(9)
  $core.double get ropeFreqScale => $_getN(7);
  @$pb.TagNumber(9)
  set ropeFreqScale($core.double v) { $_setFloat(7, v); }
  @$pb.TagNumber(9)
  $core.bool hasRopeFreqScale() => $_has(7);
  @$pb.TagNumber(9)
  void clearRopeFreqScale() => clearField(9);

  @$pb.TagNumber(10)
  $core.double get yarnExtFactor => $_getN(8);
  @$pb.TagNumber(10)
  set yarnExtFactor($core.double v) { $_setFloat(8, v); }
  @$pb.TagNumber(10)
  $core.bool hasYarnExtFactor() => $_has(8);
  @$pb.TagNumber(10)
  void clearYarnExtFactor() => clearField(10);

  @$pb.TagNumber(11)
  $core.double get yarnAttnFactor => $_getN(9);
  @$pb.TagNumber(11)
  set yarnAttnFactor($core.double v) { $_setFloat(9, v); }
  @$pb.TagNumber(11)
  $core.bool hasYarnAttnFactor() => $_has(9);
  @$pb.TagNumber(11)
  void clearYarnAttnFactor() => clearField(11);

  @$pb.TagNumber(12)
  $core.double get yarnBetaFast => $_getN(10);
  @$pb.TagNumber(12)
  set yarnBetaFast($core.double v) { $_setFloat(10, v); }
  @$pb.TagNumber(12)
  $core.bool hasYarnBetaFast() => $_has(10);
  @$pb.TagNumber(12)
  void clearYarnBetaFast() => clearField(12);

  @$pb.TagNumber(13)
  $core.double get yarnBetaSlow => $_getN(11);
  @$pb.TagNumber(13)
  set yarnBetaSlow($core.double v) { $_setFloat(11, v); }
  @$pb.TagNumber(13)
  $core.bool hasYarnBetaSlow() => $_has(11);
  @$pb.TagNumber(13)
  void clearYarnBetaSlow() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get yarnOrigCtx => $_getIZ(12);
  @$pb.TagNumber(14)
  set yarnOrigCtx($core.int v) { $_setUnsignedInt32(12, v); }
  @$pb.TagNumber(14)
  $core.bool hasYarnOrigCtx() => $_has(12);
  @$pb.TagNumber(14)
  void clearYarnOrigCtx() => clearField(14);

  @$pb.TagNumber(15)
  $core.int get typeK => $_getIZ(13);
  @$pb.TagNumber(15)
  set typeK($core.int v) { $_setSignedInt32(13, v); }
  @$pb.TagNumber(15)
  $core.bool hasTypeK() => $_has(13);
  @$pb.TagNumber(15)
  void clearTypeK() => clearField(15);

  @$pb.TagNumber(16)
  $core.int get typeV => $_getIZ(14);
  @$pb.TagNumber(16)
  set typeV($core.int v) { $_setSignedInt32(14, v); }
  @$pb.TagNumber(16)
  $core.bool hasTypeV() => $_has(14);
  @$pb.TagNumber(16)
  void clearTypeV() => clearField(16);

  @$pb.TagNumber(17)
  $core.bool get embedding => $_getBF(15);
  @$pb.TagNumber(17)
  set embedding($core.bool v) { $_setBool(15, v); }
  @$pb.TagNumber(17)
  $core.bool hasEmbedding() => $_has(15);
  @$pb.TagNumber(17)
  void clearEmbedding() => clearField(17);

  @$pb.TagNumber(18)
  $core.bool get offloadKqv => $_getBF(16);
  @$pb.TagNumber(18)
  set offloadKqv($core.bool v) { $_setBool(16, v); }
  @$pb.TagNumber(18)
  $core.bool hasOffloadKqv() => $_has(16);
  @$pb.TagNumber(18)
  void clearOffloadKqv() => clearField(18);
}

class FreeContextArgs extends $pb.GeneratedMessage {
  factory FreeContextArgs({
    $core.int? ctx,
  }) {
    final $result = create();
    if (ctx != null) {
      $result.ctx = ctx;
    }
    return $result;
  }
  FreeContextArgs._() : super();
  factory FreeContextArgs.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FreeContextArgs.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FreeContextArgs', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'ctx', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FreeContextArgs clone() => FreeContextArgs()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FreeContextArgs copyWith(void Function(FreeContextArgs) updates) => super.copyWith((message) => updates(message as FreeContextArgs)) as FreeContextArgs;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FreeContextArgs create() => FreeContextArgs._();
  FreeContextArgs createEmptyInstance() => create();
  static $pb.PbList<FreeContextArgs> createRepeated() => $pb.PbList<FreeContextArgs>();
  @$core.pragma('dart2js:noInline')
  static FreeContextArgs getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FreeContextArgs>(create);
  static FreeContextArgs? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get ctx => $_getIZ(0);
  @$pb.TagNumber(1)
  set ctx($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCtx() => $_has(0);
  @$pb.TagNumber(1)
  void clearCtx() => clearField(1);
}

class AddTextArgs extends $pb.GeneratedMessage {
  factory AddTextArgs({
    $core.int? ctx,
    $core.String? text,
  }) {
    final $result = create();
    if (ctx != null) {
      $result.ctx = ctx;
    }
    if (text != null) {
      $result.text = text;
    }
    return $result;
  }
  AddTextArgs._() : super();
  factory AddTextArgs.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddTextArgs.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddTextArgs', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'ctx', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddTextArgs clone() => AddTextArgs()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddTextArgs copyWith(void Function(AddTextArgs) updates) => super.copyWith((message) => updates(message as AddTextArgs)) as AddTextArgs;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddTextArgs create() => AddTextArgs._();
  AddTextArgs createEmptyInstance() => create();
  static $pb.PbList<AddTextArgs> createRepeated() => $pb.PbList<AddTextArgs>();
  @$core.pragma('dart2js:noInline')
  static AddTextArgs getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddTextArgs>(create);
  static AddTextArgs? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get ctx => $_getIZ(0);
  @$pb.TagNumber(1)
  set ctx($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCtx() => $_has(0);
  @$pb.TagNumber(1)
  void clearCtx() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => clearField(2);
}

class TrimArgs extends $pb.GeneratedMessage {
  factory TrimArgs({
    $core.int? ctx,
    $core.int? length,
  }) {
    final $result = create();
    if (ctx != null) {
      $result.ctx = ctx;
    }
    if (length != null) {
      $result.length = length;
    }
    return $result;
  }
  TrimArgs._() : super();
  factory TrimArgs.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TrimArgs.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TrimArgs', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'ctx', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'length', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TrimArgs clone() => TrimArgs()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TrimArgs copyWith(void Function(TrimArgs) updates) => super.copyWith((message) => updates(message as TrimArgs)) as TrimArgs;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrimArgs create() => TrimArgs._();
  TrimArgs createEmptyInstance() => create();
  static $pb.PbList<TrimArgs> createRepeated() => $pb.PbList<TrimArgs>();
  @$core.pragma('dart2js:noInline')
  static TrimArgs getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrimArgs>(create);
  static TrimArgs? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get ctx => $_getIZ(0);
  @$pb.TagNumber(1)
  set ctx($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCtx() => $_has(0);
  @$pb.TagNumber(1)
  void clearCtx() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get length => $_getIZ(1);
  @$pb.TagNumber(2)
  set length($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLength() => $_has(1);
  @$pb.TagNumber(2)
  void clearLength() => clearField(2);
}

class IngestArgs extends $pb.GeneratedMessage {
  factory IngestArgs({
    $core.int? ctx,
  }) {
    final $result = create();
    if (ctx != null) {
      $result.ctx = ctx;
    }
    return $result;
  }
  IngestArgs._() : super();
  factory IngestArgs.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory IngestArgs.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'IngestArgs', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'ctx', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  IngestArgs clone() => IngestArgs()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  IngestArgs copyWith(void Function(IngestArgs) updates) => super.copyWith((message) => updates(message as IngestArgs)) as IngestArgs;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IngestArgs create() => IngestArgs._();
  IngestArgs createEmptyInstance() => create();
  static $pb.PbList<IngestArgs> createRepeated() => $pb.PbList<IngestArgs>();
  @$core.pragma('dart2js:noInline')
  static IngestArgs getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IngestArgs>(create);
  static IngestArgs? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get ctx => $_getIZ(0);
  @$pb.TagNumber(1)
  set ctx($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCtx() => $_has(0);
  @$pb.TagNumber(1)
  void clearCtx() => clearField(1);
}

class GenerateArgs extends $pb.GeneratedMessage {
  factory GenerateArgs({
    $core.int? ctx,
  }) {
    final $result = create();
    if (ctx != null) {
      $result.ctx = ctx;
    }
    return $result;
  }
  GenerateArgs._() : super();
  factory GenerateArgs.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenerateArgs.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateArgs', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'ctx', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GenerateArgs clone() => GenerateArgs()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GenerateArgs copyWith(void Function(GenerateArgs) updates) => super.copyWith((message) => updates(message as GenerateArgs)) as GenerateArgs;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateArgs create() => GenerateArgs._();
  GenerateArgs createEmptyInstance() => create();
  static $pb.PbList<GenerateArgs> createRepeated() => $pb.PbList<GenerateArgs>();
  @$core.pragma('dart2js:noInline')
  static GenerateArgs getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GenerateArgs>(create);
  static GenerateArgs? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get ctx => $_getIZ(0);
  @$pb.TagNumber(1)
  set ctx($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCtx() => $_has(0);
  @$pb.TagNumber(1)
  void clearCtx() => clearField(1);
}

class NewContextResp extends $pb.GeneratedMessage {
  factory NewContextResp({
    $core.int? ctx,
  }) {
    final $result = create();
    if (ctx != null) {
      $result.ctx = ctx;
    }
    return $result;
  }
  NewContextResp._() : super();
  factory NewContextResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NewContextResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NewContextResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'ctx', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NewContextResp clone() => NewContextResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NewContextResp copyWith(void Function(NewContextResp) updates) => super.copyWith((message) => updates(message as NewContextResp)) as NewContextResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NewContextResp create() => NewContextResp._();
  NewContextResp createEmptyInstance() => create();
  static $pb.PbList<NewContextResp> createRepeated() => $pb.PbList<NewContextResp>();
  @$core.pragma('dart2js:noInline')
  static NewContextResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NewContextResp>(create);
  static NewContextResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get ctx => $_getIZ(0);
  @$pb.TagNumber(1)
  set ctx($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCtx() => $_has(0);
  @$pb.TagNumber(1)
  void clearCtx() => clearField(1);
}

class AddTextResp extends $pb.GeneratedMessage {
  factory AddTextResp({
    $core.Iterable<Token>? toks,
  }) {
    final $result = create();
    if (toks != null) {
      $result.toks.addAll(toks);
    }
    return $result;
  }
  AddTextResp._() : super();
  factory AddTextResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddTextResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddTextResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..pc<Token>(1, _omitFieldNames ? '' : 'toks', $pb.PbFieldType.PM, subBuilder: Token.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddTextResp clone() => AddTextResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddTextResp copyWith(void Function(AddTextResp) updates) => super.copyWith((message) => updates(message as AddTextResp)) as AddTextResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddTextResp create() => AddTextResp._();
  AddTextResp createEmptyInstance() => create();
  static $pb.PbList<AddTextResp> createRepeated() => $pb.PbList<AddTextResp>();
  @$core.pragma('dart2js:noInline')
  static AddTextResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddTextResp>(create);
  static AddTextResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Token> get toks => $_getList(0);
}

class IngestProgressResp extends $pb.GeneratedMessage {
  factory IngestProgressResp({
    $core.int? done,
    $core.int? total,
    $core.int? batchSize,
  }) {
    final $result = create();
    if (done != null) {
      $result.done = done;
    }
    if (total != null) {
      $result.total = total;
    }
    if (batchSize != null) {
      $result.batchSize = batchSize;
    }
    return $result;
  }
  IngestProgressResp._() : super();
  factory IngestProgressResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory IngestProgressResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'IngestProgressResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'done', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'total', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'batchSize', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  IngestProgressResp clone() => IngestProgressResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  IngestProgressResp copyWith(void Function(IngestProgressResp) updates) => super.copyWith((message) => updates(message as IngestProgressResp)) as IngestProgressResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IngestProgressResp create() => IngestProgressResp._();
  IngestProgressResp createEmptyInstance() => create();
  static $pb.PbList<IngestProgressResp> createRepeated() => $pb.PbList<IngestProgressResp>();
  @$core.pragma('dart2js:noInline')
  static IngestProgressResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IngestProgressResp>(create);
  static IngestProgressResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get done => $_getIZ(0);
  @$pb.TagNumber(1)
  set done($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDone() => $_has(0);
  @$pb.TagNumber(1)
  void clearDone() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get batchSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set batchSize($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBatchSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearBatchSize() => clearField(3);
}

class Token extends $pb.GeneratedMessage {
  factory Token({
    $core.int? id,
    $core.String? text,
    $core.String? rawText,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (text != null) {
      $result.text = text;
    }
    if (rawText != null) {
      $result.rawText = rawText;
    }
    return $result;
  }
  Token._() : super();
  factory Token.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Token.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Token', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aOS(3, _omitFieldNames ? '' : 'rawText')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Token clone() => Token()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Token copyWith(void Function(Token) updates) => super.copyWith((message) => updates(message as Token)) as Token;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Token create() => Token._();
  Token createEmptyInstance() => create();
  static $pb.PbList<Token> createRepeated() => $pb.PbList<Token>();
  @$core.pragma('dart2js:noInline')
  static Token getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Token>(create);
  static Token? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get rawText => $_getSZ(2);
  @$pb.TagNumber(3)
  set rawText($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRawText() => $_has(2);
  @$pb.TagNumber(3)
  void clearRawText() => clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
