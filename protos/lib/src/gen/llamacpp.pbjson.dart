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

@$core.Deprecated('Use newContextArgsDescriptor instead')
const NewContextArgs$json = {
  '1': 'NewContextArgs',
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

/// Descriptor for `NewContextArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List newContextArgsDescriptor = $convert.base64Decode(
    'Cg5OZXdDb250ZXh0QXJncxIXCgRzZWVkGAIgASgNSABSBHNlZWSIAQESGAoFbl9jdHgYAyABKA'
    '1IAVIEbkN0eIgBARIcCgduX2JhdGNoGAQgASgNSAJSBm5CYXRjaIgBARIgCgluX3RocmVhZHMY'
    'BSABKA1IA1IIblRocmVhZHOIAQESKwoPbl90aHJlYWRzX2JhdGNoGAYgASgNSARSDW5UaHJlYW'
    'RzQmF0Y2iIAQESLwoRcm9wZV9zY2FsaW5nX3R5cGUYByABKAVIBVIPcm9wZVNjYWxpbmdUeXBl'
    'iAEBEikKDnJvcGVfZnJlcV9iYXNlGAggASgCSAZSDHJvcGVGcmVxQmFzZYgBARIrCg9yb3BlX2'
    'ZyZXFfc2NhbGUYCSABKAJIB1INcm9wZUZyZXFTY2FsZYgBARIrCg95YXJuX2V4dF9mYWN0b3IY'
    'CiABKAJICFINeWFybkV4dEZhY3RvcogBARItChB5YXJuX2F0dG5fZmFjdG9yGAsgASgCSAlSDn'
    'lhcm5BdHRuRmFjdG9yiAEBEikKDnlhcm5fYmV0YV9mYXN0GAwgASgCSApSDHlhcm5CZXRhRmFz'
    'dIgBARIpCg55YXJuX2JldGFfc2xvdxgNIAEoAkgLUgx5YXJuQmV0YVNsb3eIAQESJwoNeWFybl'
    '9vcmlnX2N0eBgOIAEoDUgMUgt5YXJuT3JpZ0N0eIgBARIaCgZ0eXBlX2sYDyABKAVIDVIFdHlw'
    'ZUuIAQESGgoGdHlwZV92GBAgASgFSA5SBXR5cGVWiAEBEiEKCWVtYmVkZGluZxgRIAEoCEgPUg'
    'llbWJlZGRpbmeIAQESJAoLb2ZmbG9hZF9rcXYYEiABKAhIEFIKb2ZmbG9hZEtxdogBAUIHCgVf'
    'c2VlZEIICgZfbl9jdHhCCgoIX25fYmF0Y2hCDAoKX25fdGhyZWFkc0ISChBfbl90aHJlYWRzX2'
    'JhdGNoQhQKEl9yb3BlX3NjYWxpbmdfdHlwZUIRCg9fcm9wZV9mcmVxX2Jhc2VCEgoQX3JvcGVf'
    'ZnJlcV9zY2FsZUISChBfeWFybl9leHRfZmFjdG9yQhMKEV95YXJuX2F0dG5fZmFjdG9yQhEKD1'
    '95YXJuX2JldGFfZmFzdEIRCg9feWFybl9iZXRhX3Nsb3dCEAoOX3lhcm5fb3JpZ19jdHhCCQoH'
    'X3R5cGVfa0IJCgdfdHlwZV92QgwKCl9lbWJlZGRpbmdCDgoMX29mZmxvYWRfa3F2SgQIARAC');

@$core.Deprecated('Use freeContextArgsDescriptor instead')
const FreeContextArgs$json = {
  '1': 'FreeContextArgs',
  '2': [
    {'1': 'ctx', '3': 1, '4': 1, '5': 5, '10': 'ctx'},
  ],
};

/// Descriptor for `FreeContextArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List freeContextArgsDescriptor = $convert.base64Decode(
    'Cg9GcmVlQ29udGV4dEFyZ3MSEAoDY3R4GAEgASgFUgNjdHg=');

@$core.Deprecated('Use addTextArgsDescriptor instead')
const AddTextArgs$json = {
  '1': 'AddTextArgs',
  '2': [
    {'1': 'ctx', '3': 1, '4': 1, '5': 5, '10': 'ctx'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `AddTextArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addTextArgsDescriptor = $convert.base64Decode(
    'CgtBZGRUZXh0QXJncxIQCgNjdHgYASABKAVSA2N0eBISCgR0ZXh0GAIgASgJUgR0ZXh0');

@$core.Deprecated('Use trimArgsDescriptor instead')
const TrimArgs$json = {
  '1': 'TrimArgs',
  '2': [
    {'1': 'ctx', '3': 1, '4': 1, '5': 5, '10': 'ctx'},
    {'1': 'length', '3': 2, '4': 1, '5': 5, '10': 'length'},
  ],
};

/// Descriptor for `TrimArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trimArgsDescriptor = $convert.base64Decode(
    'CghUcmltQXJncxIQCgNjdHgYASABKAVSA2N0eBIWCgZsZW5ndGgYAiABKAVSBmxlbmd0aA==');

@$core.Deprecated('Use ingestArgsDescriptor instead')
const IngestArgs$json = {
  '1': 'IngestArgs',
  '2': [
    {'1': 'ctx', '3': 1, '4': 1, '5': 5, '10': 'ctx'},
  ],
};

/// Descriptor for `IngestArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ingestArgsDescriptor = $convert.base64Decode(
    'CgpJbmdlc3RBcmdzEhAKA2N0eBgBIAEoBVIDY3R4');

@$core.Deprecated('Use generateArgsDescriptor instead')
const GenerateArgs$json = {
  '1': 'GenerateArgs',
  '2': [
    {'1': 'ctx', '3': 1, '4': 1, '5': 5, '10': 'ctx'},
  ],
};

/// Descriptor for `GenerateArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateArgsDescriptor = $convert.base64Decode(
    'CgxHZW5lcmF0ZUFyZ3MSEAoDY3R4GAEgASgFUgNjdHg=');

@$core.Deprecated('Use newContextRespDescriptor instead')
const NewContextResp$json = {
  '1': 'NewContextResp',
  '2': [
    {'1': 'ctx', '3': 1, '4': 1, '5': 5, '10': 'ctx'},
  ],
};

/// Descriptor for `NewContextResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List newContextRespDescriptor = $convert.base64Decode(
    'Cg5OZXdDb250ZXh0UmVzcBIQCgNjdHgYASABKAVSA2N0eA==');

@$core.Deprecated('Use addTextRespDescriptor instead')
const AddTextResp$json = {
  '1': 'AddTextResp',
  '2': [
    {'1': 'toks', '3': 1, '4': 3, '5': 11, '6': '.LlamaCpp.Token', '10': 'toks'},
  ],
};

/// Descriptor for `AddTextResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addTextRespDescriptor = $convert.base64Decode(
    'CgtBZGRUZXh0UmVzcBIjCgR0b2tzGAEgAygLMg8uTGxhbWFDcHAuVG9rZW5SBHRva3M=');

@$core.Deprecated('Use ingestProgressRespDescriptor instead')
const IngestProgressResp$json = {
  '1': 'IngestProgressResp',
  '2': [
    {'1': 'done', '3': 1, '4': 1, '5': 13, '10': 'done'},
    {'1': 'total', '3': 2, '4': 1, '5': 13, '10': 'total'},
    {'1': 'batch_size', '3': 3, '4': 1, '5': 13, '10': 'batchSize'},
  ],
};

/// Descriptor for `IngestProgressResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ingestProgressRespDescriptor = $convert.base64Decode(
    'ChJJbmdlc3RQcm9ncmVzc1Jlc3ASEgoEZG9uZRgBIAEoDVIEZG9uZRIUCgV0b3RhbBgCIAEoDV'
    'IFdG90YWwSHQoKYmF0Y2hfc2l6ZRgDIAEoDVIJYmF0Y2hTaXpl');

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

