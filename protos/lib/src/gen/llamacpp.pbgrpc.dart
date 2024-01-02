//
//  Generated code. Do not modify.
//  source: llamacpp.proto
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

import 'llamacpp.pb.dart' as $0;

export 'llamacpp.pb.dart';

@$pb.GrpcServiceName('LlamaCpp.LlamaCpp')
class LlamaCppClient extends $grpc.Client {
  static final _$generate = $grpc.ClientMethod<$0.Prompt, $0.Token>(
      '/LlamaCpp.LlamaCpp/Generate',
      ($0.Prompt value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Token.fromBuffer(value));

  LlamaCppClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseStream<$0.Token> generate($0.Prompt request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$generate, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('LlamaCpp.LlamaCpp')
abstract class LlamaCppServiceBase extends $grpc.Service {
  $core.String get $name => 'LlamaCpp.LlamaCpp';

  LlamaCppServiceBase() {
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
