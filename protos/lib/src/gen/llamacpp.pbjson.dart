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
  '2': [
    {'1': 'seed', '3': 2, '4': 1, '5': 13, '9': 0, '10': 'seed', '17': true},
    {'1': 'n_ctx', '3': 3, '4': 1, '5': 13, '9': 1, '10': 'nCtx', '17': true},
    {'1': 'n_batch', '3': 4, '4': 1, '5': 13, '9': 2, '10': 'nBatch', '17': true},
    {'1': 'n_threads', '3': 5, '4': 1, '5': 13, '9': 3, '10': 'nThreads', '17': true},
    {'1': 'n_threads_batch', '3': 6, '4': 1, '5': 13, '9': 4, '10': 'nThreadsBatch', '17': true},
    {'1': 'rope_scaling_type', '3': 7, '4': 1, '5': 5, '9': 5, '10': 'ropeScalingType', '17': true},
    {'1': 'rope_freq_base', '3': 8, '4': 1, '5': 2, '9': 6, '10': 'ropeFreqBase', '17': true},
    {'1': 'rope_freq_scale', '3': 9, '4': 1, '5': 2, '9': 7, '10': 'ropeFreqScale', '17': true},
    {'1': 'yarn_ext_factor', '3': 10, '4': 1, '5': 2, '9': 8, '10': 'yarnExtFactor', '17': true},
    {'1': 'yarn_attn_factor', '3': 11, '4': 1, '5': 2, '9': 9, '10': 'yarnAttnFactor', '17': true},
    {'1': 'yarn_beta_fast', '3': 12, '4': 1, '5': 2, '9': 10, '10': 'yarnBetaFast', '17': true},
    {'1': 'yarn_beta_slow', '3': 13, '4': 1, '5': 2, '9': 11, '10': 'yarnBetaSlow', '17': true},
    {'1': 'yarn_orig_ctx', '3': 14, '4': 1, '5': 13, '9': 12, '10': 'yarnOrigCtx', '17': true},
    {'1': 'type_k', '3': 15, '4': 1, '5': 5, '9': 13, '10': 'typeK', '17': true},
    {'1': 'type_v', '3': 16, '4': 1, '5': 5, '9': 14, '10': 'typeV', '17': true},
    {'1': 'embedding', '3': 17, '4': 1, '5': 8, '9': 15, '10': 'embedding', '17': true},
    {'1': 'offload_kqv', '3': 18, '4': 1, '5': 8, '9': 16, '10': 'offloadKqv', '17': true},
  ],
  '8': [
    {'1': '_seed'},
    {'1': '_n_ctx'},
    {'1': '_n_batch'},
    {'1': '_n_threads'},
    {'1': '_n_threads_batch'},
    {'1': '_rope_scaling_type'},
    {'1': '_rope_freq_base'},
    {'1': '_rope_freq_scale'},
    {'1': '_yarn_ext_factor'},
    {'1': '_yarn_attn_factor'},
    {'1': '_yarn_beta_fast'},
    {'1': '_yarn_beta_slow'},
    {'1': '_yarn_orig_ctx'},
    {'1': '_type_k'},
    {'1': '_type_v'},
    {'1': '_embedding'},
    {'1': '_offload_kqv'},
  ],
  '9': [
    {'1': 1, '2': 2},
  ],
};

/// Descriptor for `NewContextRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List newContextRequestDescriptor = $convert.base64Decode(
    'ChFOZXdDb250ZXh0UmVxdWVzdBIXCgRzZWVkGAIgASgNSABSBHNlZWSIAQESGAoFbl9jdHgYAy'
    'ABKA1IAVIEbkN0eIgBARIcCgduX2JhdGNoGAQgASgNSAJSBm5CYXRjaIgBARIgCgluX3RocmVh'
    'ZHMYBSABKA1IA1IIblRocmVhZHOIAQESKwoPbl90aHJlYWRzX2JhdGNoGAYgASgNSARSDW5UaH'
    'JlYWRzQmF0Y2iIAQESLwoRcm9wZV9zY2FsaW5nX3R5cGUYByABKAVIBVIPcm9wZVNjYWxpbmdU'
    'eXBliAEBEikKDnJvcGVfZnJlcV9iYXNlGAggASgCSAZSDHJvcGVGcmVxQmFzZYgBARIrCg9yb3'
    'BlX2ZyZXFfc2NhbGUYCSABKAJIB1INcm9wZUZyZXFTY2FsZYgBARIrCg95YXJuX2V4dF9mYWN0'
    'b3IYCiABKAJICFINeWFybkV4dEZhY3RvcogBARItChB5YXJuX2F0dG5fZmFjdG9yGAsgASgCSA'
    'lSDnlhcm5BdHRuRmFjdG9yiAEBEikKDnlhcm5fYmV0YV9mYXN0GAwgASgCSApSDHlhcm5CZXRh'
    'RmFzdIgBARIpCg55YXJuX2JldGFfc2xvdxgNIAEoAkgLUgx5YXJuQmV0YVNsb3eIAQESJwoNeW'
    'Fybl9vcmlnX2N0eBgOIAEoDUgMUgt5YXJuT3JpZ0N0eIgBARIaCgZ0eXBlX2sYDyABKAVIDVIF'
    'dHlwZUuIAQESGgoGdHlwZV92GBAgASgFSA5SBXR5cGVWiAEBEiEKCWVtYmVkZGluZxgRIAEoCE'
    'gPUgllbWJlZGRpbmeIAQESJAoLb2ZmbG9hZF9rcXYYEiABKAhIEFIKb2ZmbG9hZEtxdogBAUIH'
    'CgVfc2VlZEIICgZfbl9jdHhCCgoIX25fYmF0Y2hCDAoKX25fdGhyZWFkc0ISChBfbl90aHJlYW'
    'RzX2JhdGNoQhQKEl9yb3BlX3NjYWxpbmdfdHlwZUIRCg9fcm9wZV9mcmVxX2Jhc2VCEgoQX3Jv'
    'cGVfZnJlcV9zY2FsZUISChBfeWFybl9leHRfZmFjdG9yQhMKEV95YXJuX2F0dG5fZmFjdG9yQh'
    'EKD195YXJuX2JldGFfZmFzdEIRCg9feWFybl9iZXRhX3Nsb3dCEAoOX3lhcm5fb3JpZ19jdHhC'
    'CQoHX3R5cGVfa0IJCgdfdHlwZV92QgwKCl9lbWJlZGRpbmdCDgoMX29mZmxvYWRfa3F2SgQIAR'
    'AC');

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

