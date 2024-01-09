//
//  Generated code. Do not modify.
//  source: llamacpp.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use voidDescriptor instead')
const Void$json = {
  '1': 'Void',
};

/// Descriptor for `Void`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voidDescriptor = $convert.base64Decode(
    'CgRWb2lk');

@$core.Deprecated('Use newContextRequestDescriptor instead')
const NewContextRequest$json = {
  '1': 'NewContextRequest',
};

/// Descriptor for `NewContextRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List newContextRequestDescriptor = $convert.base64Decode(
    'ChFOZXdDb250ZXh0UmVxdWVzdA==');

@$core.Deprecated('Use addTextRequestDescriptor instead')
const AddTextRequest$json = {
  '1': 'AddTextRequest',
  '2': [
    {'1': 'context', '3': 1, '4': 1, '5': 11, '6': '.LlamaCpp.Context', '10': 'context'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `AddTextRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addTextRequestDescriptor = $convert.base64Decode(
    'Cg5BZGRUZXh0UmVxdWVzdBIrCgdjb250ZXh0GAEgASgLMhEuTGxhbWFDcHAuQ29udGV4dFIHY2'
    '9udGV4dBISCgR0ZXh0GAIgASgJUgR0ZXh0');

@$core.Deprecated('Use trimRequestDescriptor instead')
const TrimRequest$json = {
  '1': 'TrimRequest',
  '2': [
    {'1': 'context', '3': 1, '4': 1, '5': 11, '6': '.LlamaCpp.Context', '10': 'context'},
    {'1': 'length', '3': 2, '4': 1, '5': 5, '10': 'length'},
  ],
};

/// Descriptor for `TrimRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trimRequestDescriptor = $convert.base64Decode(
    'CgtUcmltUmVxdWVzdBIrCgdjb250ZXh0GAEgASgLMhEuTGxhbWFDcHAuQ29udGV4dFIHY29udG'
    'V4dBIWCgZsZW5ndGgYAiABKAVSBmxlbmd0aA==');

@$core.Deprecated('Use contextDescriptor instead')
const Context$json = {
  '1': 'Context',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
  ],
};

/// Descriptor for `Context`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contextDescriptor = $convert.base64Decode(
    'CgdDb250ZXh0Eg4KAmlkGAEgASgFUgJpZA==');

@$core.Deprecated('Use tokenDescriptor instead')
const Token$json = {
  '1': 'Token',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'text', '17': true},
  ],
  '8': [
    {'1': '_text'},
  ],
};

/// Descriptor for `Token`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenDescriptor = $convert.base64Decode(
    'CgVUb2tlbhIOCgJpZBgBIAEoBVICaWQSFwoEdGV4dBgCIAEoCUgAUgR0ZXh0iAEBQgcKBV90ZX'
    'h0');

@$core.Deprecated('Use tokenListDescriptor instead')
const TokenList$json = {
  '1': 'TokenList',
  '2': [
    {'1': 'toks', '3': 1, '4': 3, '5': 11, '6': '.LlamaCpp.Token', '10': 'toks'},
  ],
};

/// Descriptor for `TokenList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenListDescriptor = $convert.base64Decode(
    'CglUb2tlbkxpc3QSIwoEdG9rcxgBIAMoCzIPLkxsYW1hQ3BwLlRva2VuUgR0b2tz');

