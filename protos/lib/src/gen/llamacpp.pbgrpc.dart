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
  static final _$newContext = $grpc.ClientMethod<$0.NewContextRequest, $0.Context>(
      '/LlamaCpp.LlamaCpp/NewContext',
      ($0.NewContextRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Context.fromBuffer(value));
  static final _$freeContext = $grpc.ClientMethod<$0.Context, $0.Void>(
      '/LlamaCpp.LlamaCpp/FreeContext',
      ($0.Context value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Void.fromBuffer(value));
  static final _$addText = $grpc.ClientMethod<$0.AddTextRequest, $0.TokenList>(
      '/LlamaCpp.LlamaCpp/AddText',
      ($0.AddTextRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.TokenList.fromBuffer(value));
  static final _$ingest = $grpc.ClientMethod<$0.Context, $0.Void>(
      '/LlamaCpp.LlamaCpp/Ingest',
      ($0.Context value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Void.fromBuffer(value));
  static final _$generate = $grpc.ClientMethod<$0.Context, $0.Token>(
      '/LlamaCpp.LlamaCpp/Generate',
      ($0.Context value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Token.fromBuffer(value));

  LlamaCppClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.Context> newContext($0.NewContextRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$newContext, request, options: options);
  }

  $grpc.ResponseFuture<$0.Void> freeContext($0.Context request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$freeContext, request, options: options);
  }

  $grpc.ResponseFuture<$0.TokenList> addText($0.AddTextRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$addText, request, options: options);
  }

  $grpc.ResponseFuture<$0.Void> ingest($0.Context request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ingest, request, options: options);
  }

  $grpc.ResponseStream<$0.Token> generate($0.Context request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$generate, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('LlamaCpp.LlamaCpp')
abstract class LlamaCppServiceBase extends $grpc.Service {
  $core.String get $name => 'LlamaCpp.LlamaCpp';

  LlamaCppServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.NewContextRequest, $0.Context>(
        'NewContext',
        newContext_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.NewContextRequest.fromBuffer(value),
        ($0.Context value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Context, $0.Void>(
        'FreeContext',
        freeContext_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Context.fromBuffer(value),
        ($0.Void value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddTextRequest, $0.TokenList>(
        'AddText',
        addText_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddTextRequest.fromBuffer(value),
        ($0.TokenList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Context, $0.Void>(
        'Ingest',
        ingest_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Context.fromBuffer(value),
        ($0.Void value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Context, $0.Token>(
        'Generate',
        generate_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Context.fromBuffer(value),
        ($0.Token value) => value.writeToBuffer()));
  }

  $async.Future<$0.Context> newContext_Pre($grpc.ServiceCall call, $async.Future<$0.NewContextRequest> request) async {
    return newContext(call, await request);
  }

  $async.Future<$0.Void> freeContext_Pre($grpc.ServiceCall call, $async.Future<$0.Context> request) async {
    return freeContext(call, await request);
  }

  $async.Future<$0.TokenList> addText_Pre($grpc.ServiceCall call, $async.Future<$0.AddTextRequest> request) async {
    return addText(call, await request);
  }

  $async.Future<$0.Void> ingest_Pre($grpc.ServiceCall call, $async.Future<$0.Context> request) async {
    return ingest(call, await request);
  }

  $async.Stream<$0.Token> generate_Pre($grpc.ServiceCall call, $async.Future<$0.Context> request) async* {
    yield* generate(call, await request);
  }

  $async.Future<$0.Context> newContext($grpc.ServiceCall call, $0.NewContextRequest request);
  $async.Future<$0.Void> freeContext($grpc.ServiceCall call, $0.Context request);
  $async.Future<$0.TokenList> addText($grpc.ServiceCall call, $0.AddTextRequest request);
  $async.Future<$0.Void> ingest($grpc.ServiceCall call, $0.Context request);
  $async.Stream<$0.Token> generate($grpc.ServiceCall call, $0.Context request);
}
