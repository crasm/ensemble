//
//  Generated code. Do not modify.
//  source: text_append.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use textAppendCheckPointDescriptor instead')
const TextAppendCheckPoint$json = {
  '1': 'TextAppendCheckPoint',
  '2': [
    {'1': 'checkpoint_text', '3': 1, '4': 1, '5': 9, '10': 'checkpointText'},
  ],
};

/// Descriptor for `TextAppendCheckPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textAppendCheckPointDescriptor = $convert.base64Decode(
    'ChRUZXh0QXBwZW5kQ2hlY2tQb2ludBInCg9jaGVja3BvaW50X3RleHQYASABKAlSDmNoZWNrcG'
    '9pbnRUZXh0');

@$core.Deprecated('Use textAppendDeltaDescriptor instead')
const TextAppendDelta$json = {
  '1': 'TextAppendDelta',
  '2': [
    {'1': 'appended_text', '3': 1, '4': 1, '5': 9, '10': 'appendedText'},
  ],
};

/// Descriptor for `TextAppendDelta`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textAppendDeltaDescriptor = $convert.base64Decode(
    'Cg9UZXh0QXBwZW5kRGVsdGESIwoNYXBwZW5kZWRfdGV4dBgBIAEoCVIMYXBwZW5kZWRUZXh0');

