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

class NewContextRequest extends $pb.GeneratedMessage {
  factory NewContextRequest({
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
  NewContextRequest._() : super();
  factory NewContextRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NewContextRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NewContextRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
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
  NewContextRequest clone() => NewContextRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NewContextRequest copyWith(void Function(NewContextRequest) updates) => super.copyWith((message) => updates(message as NewContextRequest)) as NewContextRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NewContextRequest create() => NewContextRequest._();
  NewContextRequest createEmptyInstance() => create();
  static $pb.PbList<NewContextRequest> createRepeated() => $pb.PbList<NewContextRequest>();
  @$core.pragma('dart2js:noInline')
  static NewContextRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NewContextRequest>(create);
  static NewContextRequest? _defaultInstance;

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

class AddTextRequest extends $pb.GeneratedMessage {
  factory AddTextRequest({
    Context? context,
    $core.String? text,
  }) {
    final $result = create();
    if (context != null) {
      $result.context = context;
    }
    if (text != null) {
      $result.text = text;
    }
    return $result;
  }
  AddTextRequest._() : super();
  factory AddTextRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddTextRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddTextRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..aOM<Context>(1, _omitFieldNames ? '' : 'context', subBuilder: Context.create)
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddTextRequest clone() => AddTextRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddTextRequest copyWith(void Function(AddTextRequest) updates) => super.copyWith((message) => updates(message as AddTextRequest)) as AddTextRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddTextRequest create() => AddTextRequest._();
  AddTextRequest createEmptyInstance() => create();
  static $pb.PbList<AddTextRequest> createRepeated() => $pb.PbList<AddTextRequest>();
  @$core.pragma('dart2js:noInline')
  static AddTextRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddTextRequest>(create);
  static AddTextRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Context get context => $_getN(0);
  @$pb.TagNumber(1)
  set context(Context v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasContext() => $_has(0);
  @$pb.TagNumber(1)
  void clearContext() => clearField(1);
  @$pb.TagNumber(1)
  Context ensureContext() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => clearField(2);
}

class TrimRequest extends $pb.GeneratedMessage {
  factory TrimRequest({
    Context? context,
    $core.int? length,
  }) {
    final $result = create();
    if (context != null) {
      $result.context = context;
    }
    if (length != null) {
      $result.length = length;
    }
    return $result;
  }
  TrimRequest._() : super();
  factory TrimRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TrimRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TrimRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..aOM<Context>(1, _omitFieldNames ? '' : 'context', subBuilder: Context.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'length', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TrimRequest clone() => TrimRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TrimRequest copyWith(void Function(TrimRequest) updates) => super.copyWith((message) => updates(message as TrimRequest)) as TrimRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrimRequest create() => TrimRequest._();
  TrimRequest createEmptyInstance() => create();
  static $pb.PbList<TrimRequest> createRepeated() => $pb.PbList<TrimRequest>();
  @$core.pragma('dart2js:noInline')
  static TrimRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrimRequest>(create);
  static TrimRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Context get context => $_getN(0);
  @$pb.TagNumber(1)
  set context(Context v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasContext() => $_has(0);
  @$pb.TagNumber(1)
  void clearContext() => clearField(1);
  @$pb.TagNumber(1)
  Context ensureContext() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get length => $_getIZ(1);
  @$pb.TagNumber(2)
  set length($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLength() => $_has(1);
  @$pb.TagNumber(2)
  void clearLength() => clearField(2);
}

class Context extends $pb.GeneratedMessage {
  factory Context({
    $core.int? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  Context._() : super();
  factory Context.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Context.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Context', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Context clone() => Context()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Context copyWith(void Function(Context) updates) => super.copyWith((message) => updates(message as Context)) as Context;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Context create() => Context._();
  Context createEmptyInstance() => create();
  static $pb.PbList<Context> createRepeated() => $pb.PbList<Context>();
  @$core.pragma('dart2js:noInline')
  static Context getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Context>(create);
  static Context? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class Token extends $pb.GeneratedMessage {
  factory Token({
    $core.int? id,
    $core.String? text,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (text != null) {
      $result.text = text;
    }
    return $result;
  }
  Token._() : super();
  factory Token.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Token.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Token', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'text')
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
}

class TokenList extends $pb.GeneratedMessage {
  factory TokenList({
    $core.Iterable<Token>? toks,
  }) {
    final $result = create();
    if (toks != null) {
      $result.toks.addAll(toks);
    }
    return $result;
  }
  TokenList._() : super();
  factory TokenList.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TokenList.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TokenList', package: const $pb.PackageName(_omitMessageNames ? '' : 'LlamaCpp'), createEmptyInstance: create)
    ..pc<Token>(1, _omitFieldNames ? '' : 'toks', $pb.PbFieldType.PM, subBuilder: Token.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TokenList clone() => TokenList()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TokenList copyWith(void Function(TokenList) updates) => super.copyWith((message) => updates(message as TokenList)) as TokenList;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TokenList create() => TokenList._();
  TokenList createEmptyInstance() => create();
  static $pb.PbList<TokenList> createRepeated() => $pb.PbList<TokenList>();
  @$core.pragma('dart2js:noInline')
  static TokenList getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TokenList>(create);
  static TokenList? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Token> get toks => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
