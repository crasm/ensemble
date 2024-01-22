//
//  Generated code. Do not modify.
//  source: llamacpp_samplers.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use samplerDescriptor instead')
const Sampler$json = {
  '1': 'Sampler',
  '2': [
    {'1': 'temperature', '3': 1, '4': 1, '5': 11, '6': '.LlamaCpp.Temperature', '9': 0, '10': 'temperature'},
    {'1': 'top_k', '3': 2, '4': 1, '5': 11, '6': '.LlamaCpp.TopK', '9': 0, '10': 'topK'},
    {'1': 'top_p', '3': 3, '4': 1, '5': 11, '6': '.LlamaCpp.TopP', '9': 0, '10': 'topP'},
    {'1': 'min_p', '3': 4, '4': 1, '5': 11, '6': '.LlamaCpp.MinP', '9': 0, '10': 'minP'},
    {'1': 'tail_free', '3': 5, '4': 1, '5': 11, '6': '.LlamaCpp.TailFree', '9': 0, '10': 'tailFree'},
    {'1': 'locally_typical', '3': 6, '4': 1, '5': 11, '6': '.LlamaCpp.LocallyTypical', '9': 0, '10': 'locallyTypical'},
    {'1': 'repetition_penalty', '3': 7, '4': 1, '5': 11, '6': '.LlamaCpp.RepetitionPenalty', '9': 0, '10': 'repetitionPenalty'},
    {'1': 'mirostat_v1', '3': 8, '4': 1, '5': 11, '6': '.LlamaCpp.MirostatV1', '9': 0, '10': 'mirostatV1'},
    {'1': 'mirostat_v2', '3': 9, '4': 1, '5': 11, '6': '.LlamaCpp.MirostatV2', '9': 0, '10': 'mirostatV2'},
    {'1': 'logit_bias', '3': 10, '4': 1, '5': 11, '6': '.LlamaCpp.LogitBias', '9': 0, '10': 'logitBias'},
  ],
  '8': [
    {'1': 'sampler'},
  ],
};

/// Descriptor for `Sampler`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List samplerDescriptor = $convert.base64Decode(
    'CgdTYW1wbGVyEjkKC3RlbXBlcmF0dXJlGAEgASgLMhUuTGxhbWFDcHAuVGVtcGVyYXR1cmVIAF'
    'ILdGVtcGVyYXR1cmUSJQoFdG9wX2sYAiABKAsyDi5MbGFtYUNwcC5Ub3BLSABSBHRvcEsSJQoF'
    'dG9wX3AYAyABKAsyDi5MbGFtYUNwcC5Ub3BQSABSBHRvcFASJQoFbWluX3AYBCABKAsyDi5MbG'
    'FtYUNwcC5NaW5QSABSBG1pblASMQoJdGFpbF9mcmVlGAUgASgLMhIuTGxhbWFDcHAuVGFpbEZy'
    'ZWVIAFIIdGFpbEZyZWUSQwoPbG9jYWxseV90eXBpY2FsGAYgASgLMhguTGxhbWFDcHAuTG9jYW'
    'xseVR5cGljYWxIAFIObG9jYWxseVR5cGljYWwSTAoScmVwZXRpdGlvbl9wZW5hbHR5GAcgASgL'
    'MhsuTGxhbWFDcHAuUmVwZXRpdGlvblBlbmFsdHlIAFIRcmVwZXRpdGlvblBlbmFsdHkSNwoLbW'
    'lyb3N0YXRfdjEYCCABKAsyFC5MbGFtYUNwcC5NaXJvc3RhdFYxSABSCm1pcm9zdGF0VjESNwoL'
    'bWlyb3N0YXRfdjIYCSABKAsyFC5MbGFtYUNwcC5NaXJvc3RhdFYySABSCm1pcm9zdGF0VjISNA'
    'oKbG9naXRfYmlhcxgKIAEoCzITLkxsYW1hQ3BwLkxvZ2l0Qmlhc0gAUglsb2dpdEJpYXNCCQoH'
    'c2FtcGxlcg==');

@$core.Deprecated('Use temperatureDescriptor instead')
const Temperature$json = {
  '1': 'Temperature',
  '2': [
    {'1': 'temp', '3': 1, '4': 1, '5': 2, '10': 'temp'},
  ],
};

/// Descriptor for `Temperature`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List temperatureDescriptor = $convert.base64Decode(
    'CgtUZW1wZXJhdHVyZRISCgR0ZW1wGAEgASgCUgR0ZW1w');

@$core.Deprecated('Use topKDescriptor instead')
const TopK$json = {
  '1': 'TopK',
  '2': [
    {'1': 'top_k', '3': 1, '4': 1, '5': 5, '10': 'topK'},
  ],
};

/// Descriptor for `TopK`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List topKDescriptor = $convert.base64Decode(
    'CgRUb3BLEhMKBXRvcF9rGAEgASgFUgR0b3BL');

@$core.Deprecated('Use topPDescriptor instead')
const TopP$json = {
  '1': 'TopP',
  '2': [
    {'1': 'top_p', '3': 1, '4': 1, '5': 2, '10': 'topP'},
  ],
};

/// Descriptor for `TopP`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List topPDescriptor = $convert.base64Decode(
    'CgRUb3BQEhMKBXRvcF9wGAEgASgCUgR0b3BQ');

@$core.Deprecated('Use minPDescriptor instead')
const MinP$json = {
  '1': 'MinP',
  '2': [
    {'1': 'min_p', '3': 1, '4': 1, '5': 2, '10': 'minP'},
  ],
};

/// Descriptor for `MinP`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List minPDescriptor = $convert.base64Decode(
    'CgRNaW5QEhMKBW1pbl9wGAEgASgCUgRtaW5Q');

@$core.Deprecated('Use tailFreeDescriptor instead')
const TailFree$json = {
  '1': 'TailFree',
  '2': [
    {'1': 'z', '3': 1, '4': 1, '5': 2, '10': 'z'},
  ],
};

/// Descriptor for `TailFree`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tailFreeDescriptor = $convert.base64Decode(
    'CghUYWlsRnJlZRIMCgF6GAEgASgCUgF6');

@$core.Deprecated('Use locallyTypicalDescriptor instead')
const LocallyTypical$json = {
  '1': 'LocallyTypical',
  '2': [
    {'1': 'p', '3': 1, '4': 1, '5': 2, '10': 'p'},
  ],
};

/// Descriptor for `LocallyTypical`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locallyTypicalDescriptor = $convert.base64Decode(
    'Cg5Mb2NhbGx5VHlwaWNhbBIMCgFwGAEgASgCUgFw');

@$core.Deprecated('Use repetitionPenaltyDescriptor instead')
const RepetitionPenalty$json = {
  '1': 'RepetitionPenalty',
  '2': [
    {'1': 'last_n', '3': 1, '4': 1, '5': 5, '10': 'lastN'},
    {'1': 'penalty', '3': 2, '4': 1, '5': 2, '10': 'penalty'},
    {'1': 'frequency_penalty', '3': 3, '4': 1, '5': 2, '10': 'frequencyPenalty'},
    {'1': 'presence_penalty', '3': 4, '4': 1, '5': 2, '10': 'presencePenalty'},
    {'1': 'penalizeNewline', '3': 5, '4': 1, '5': 8, '10': 'penalizeNewline'},
  ],
};

/// Descriptor for `RepetitionPenalty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repetitionPenaltyDescriptor = $convert.base64Decode(
    'ChFSZXBldGl0aW9uUGVuYWx0eRIVCgZsYXN0X24YASABKAVSBWxhc3ROEhgKB3BlbmFsdHkYAi'
    'ABKAJSB3BlbmFsdHkSKwoRZnJlcXVlbmN5X3BlbmFsdHkYAyABKAJSEGZyZXF1ZW5jeVBlbmFs'
    'dHkSKQoQcHJlc2VuY2VfcGVuYWx0eRgEIAEoAlIPcHJlc2VuY2VQZW5hbHR5EigKD3BlbmFsaX'
    'plTmV3bGluZRgFIAEoCFIPcGVuYWxpemVOZXdsaW5l');

@$core.Deprecated('Use mirostatV1Descriptor instead')
const MirostatV1$json = {
  '1': 'MirostatV1',
  '2': [
    {'1': 'tau', '3': 1, '4': 1, '5': 2, '10': 'tau'},
    {'1': 'eta', '3': 2, '4': 1, '5': 2, '10': 'eta'},
  ],
};

/// Descriptor for `MirostatV1`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mirostatV1Descriptor = $convert.base64Decode(
    'CgpNaXJvc3RhdFYxEhAKA3RhdRgBIAEoAlIDdGF1EhAKA2V0YRgCIAEoAlIDZXRh');

@$core.Deprecated('Use mirostatV2Descriptor instead')
const MirostatV2$json = {
  '1': 'MirostatV2',
  '2': [
    {'1': 'tau', '3': 1, '4': 1, '5': 2, '10': 'tau'},
    {'1': 'eta', '3': 2, '4': 1, '5': 2, '10': 'eta'},
  ],
};

/// Descriptor for `MirostatV2`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mirostatV2Descriptor = $convert.base64Decode(
    'CgpNaXJvc3RhdFYyEhAKA3RhdRgBIAEoAlIDdGF1EhAKA2V0YRgCIAEoAlIDZXRh');

@$core.Deprecated('Use logitBiasDescriptor instead')
const LogitBias$json = {
  '1': 'LogitBias',
  '2': [
    {'1': 'bias', '3': 1, '4': 3, '5': 11, '6': '.LlamaCpp.LogitBias.BiasEntry', '10': 'bias'},
  ],
  '3': [LogitBias_BiasEntry$json],
};

@$core.Deprecated('Use logitBiasDescriptor instead')
const LogitBias_BiasEntry$json = {
  '1': 'BiasEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 2, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `LogitBias`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logitBiasDescriptor = $convert.base64Decode(
    'CglMb2dpdEJpYXMSMQoEYmlhcxgBIAMoCzIdLkxsYW1hQ3BwLkxvZ2l0Qmlhcy5CaWFzRW50cn'
    'lSBGJpYXMaNwoJQmlhc0VudHJ5EhAKA2tleRgBIAEoBVIDa2V5EhQKBXZhbHVlGAIgASgCUgV2'
    'YWx1ZToCOAE=');

