//
//  Generated code. Do not modify.
//  source: text_append.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class TextAppendCheckPoint extends $pb.GeneratedMessage {
  factory TextAppendCheckPoint({
    $core.String? checkpointText,
  }) {
    final $result = create();
    if (checkpointText != null) {
      $result.checkpointText = checkpointText;
    }
    return $result;
  }
  TextAppendCheckPoint._() : super();
  factory TextAppendCheckPoint.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TextAppendCheckPoint.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TextAppendCheckPoint', package: const $pb.PackageName(_omitMessageNames ? '' : 'TextAppend'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'checkpointText')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TextAppendCheckPoint clone() => TextAppendCheckPoint()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TextAppendCheckPoint copyWith(void Function(TextAppendCheckPoint) updates) => super.copyWith((message) => updates(message as TextAppendCheckPoint)) as TextAppendCheckPoint;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TextAppendCheckPoint create() => TextAppendCheckPoint._();
  TextAppendCheckPoint createEmptyInstance() => create();
  static $pb.PbList<TextAppendCheckPoint> createRepeated() => $pb.PbList<TextAppendCheckPoint>();
  @$core.pragma('dart2js:noInline')
  static TextAppendCheckPoint getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TextAppendCheckPoint>(create);
  static TextAppendCheckPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get checkpointText => $_getSZ(0);
  @$pb.TagNumber(1)
  set checkpointText($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCheckpointText() => $_has(0);
  @$pb.TagNumber(1)
  void clearCheckpointText() => clearField(1);
}

class TextAppendDelta extends $pb.GeneratedMessage {
  factory TextAppendDelta({
    $core.String? appendedText,
  }) {
    final $result = create();
    if (appendedText != null) {
      $result.appendedText = appendedText;
    }
    return $result;
  }
  TextAppendDelta._() : super();
  factory TextAppendDelta.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TextAppendDelta.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TextAppendDelta', package: const $pb.PackageName(_omitMessageNames ? '' : 'TextAppend'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'appendedText')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TextAppendDelta clone() => TextAppendDelta()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TextAppendDelta copyWith(void Function(TextAppendDelta) updates) => super.copyWith((message) => updates(message as TextAppendDelta)) as TextAppendDelta;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TextAppendDelta create() => TextAppendDelta._();
  TextAppendDelta createEmptyInstance() => create();
  static $pb.PbList<TextAppendDelta> createRepeated() => $pb.PbList<TextAppendDelta>();
  @$core.pragma('dart2js:noInline')
  static TextAppendDelta getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TextAppendDelta>(create);
  static TextAppendDelta? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appendedText => $_getSZ(0);
  @$pb.TagNumber(1)
  set appendedText($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAppendedText() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppendedText() => clearField(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
