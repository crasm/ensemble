//
//  Generated code. Do not modify.
//  source: llm.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'llm.pb.dart' as $0;

export 'llm.pb.dart';

@$pb.GrpcServiceName('llm.Llm')
class LlmClient extends $grpc.Client {
  static final _$generate = $grpc.ClientMethod<$0.Prompt, $0.Token>(
      '/llm.Llm/Generate',
      ($0.Prompt value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Token.fromBuffer(value));

  LlmClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseStream<$0.Token> generate($0.Prompt request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$generate, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('llm.Llm')
abstract class LlmServiceBase extends $grpc.Service {
  $core.String get $name => 'llm.Llm';

  LlmServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Prompt, $0.Token>(
        'Generate',
        generate_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Prompt.fromBuffer(value),
        ($0.Token value) => value.writeToBuffer()));
  }

  $async.Stream<$0.Token> generate_Pre($grpc.ServiceCall call, $async.Future<$0.Prompt> request) async* {
    yield* generate(call, await request);
  }

  $async.Stream<$0.Token> generate($grpc.ServiceCall call, $0.Prompt request);
}
