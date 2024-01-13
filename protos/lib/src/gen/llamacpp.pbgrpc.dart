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
  static final _$newContext = $grpc.ClientMethod<$0.NewContextArgs, $0.NewContextResp>(
      '/LlamaCpp.LlamaCpp/NewContext',
      ($0.NewContextArgs value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.NewContextResp.fromBuffer(value));
  static final _$freeContext = $grpc.ClientMethod<$0.FreeContextArgs, $0.Void>(
      '/LlamaCpp.LlamaCpp/FreeContext',
      ($0.FreeContextArgs value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Void.fromBuffer(value));
  static final _$addText = $grpc.ClientMethod<$0.AddTextArgs, $0.AddTextResp>(
      '/LlamaCpp.LlamaCpp/AddText',
      ($0.AddTextArgs value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddTextResp.fromBuffer(value));
  static final _$trim = $grpc.ClientMethod<$0.TrimArgs, $0.Void>(
      '/LlamaCpp.LlamaCpp/Trim',
      ($0.TrimArgs value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Void.fromBuffer(value));
  static final _$ingest = $grpc.ClientMethod<$0.IngestArgs, $0.Void>(
      '/LlamaCpp.LlamaCpp/Ingest',
      ($0.IngestArgs value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Void.fromBuffer(value));
  static final _$generate = $grpc.ClientMethod<$0.GenerateArgs, $0.Token>(
      '/LlamaCpp.LlamaCpp/Generate',
      ($0.GenerateArgs value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Token.fromBuffer(value));

  LlamaCppClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.NewContextResp> newContext($0.NewContextArgs request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$newContext, request, options: options);
  }

  $grpc.ResponseFuture<$0.Void> freeContext($0.FreeContextArgs request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$freeContext, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddTextResp> addText($0.AddTextArgs request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$addText, request, options: options);
  }

  $grpc.ResponseFuture<$0.Void> trim($0.TrimArgs request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$trim, request, options: options);
  }

  $grpc.ResponseFuture<$0.Void> ingest($0.IngestArgs request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ingest, request, options: options);
  }

  $grpc.ResponseStream<$0.Token> generate($0.GenerateArgs request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$generate, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('LlamaCpp.LlamaCpp')
abstract class LlamaCppServiceBase extends $grpc.Service {
  $core.String get $name => 'LlamaCpp.LlamaCpp';

  LlamaCppServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.NewContextArgs, $0.NewContextResp>(
        'NewContext',
        newContext_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.NewContextArgs.fromBuffer(value),
        ($0.NewContextResp value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FreeContextArgs, $0.Void>(
        'FreeContext',
        freeContext_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FreeContextArgs.fromBuffer(value),
        ($0.Void value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddTextArgs, $0.AddTextResp>(
        'AddText',
        addText_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddTextArgs.fromBuffer(value),
        ($0.AddTextResp value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TrimArgs, $0.Void>(
        'Trim',
        trim_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TrimArgs.fromBuffer(value),
        ($0.Void value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.IngestArgs, $0.Void>(
        'Ingest',
        ingest_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.IngestArgs.fromBuffer(value),
        ($0.Void value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GenerateArgs, $0.Token>(
        'Generate',
        generate_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.GenerateArgs.fromBuffer(value),
        ($0.Token value) => value.writeToBuffer()));
  }

  $async.Future<$0.NewContextResp> newContext_Pre($grpc.ServiceCall call, $async.Future<$0.NewContextArgs> request) async {
    return newContext(call, await request);
  }

  $async.Future<$0.Void> freeContext_Pre($grpc.ServiceCall call, $async.Future<$0.FreeContextArgs> request) async {
    return freeContext(call, await request);
  }

  $async.Future<$0.AddTextResp> addText_Pre($grpc.ServiceCall call, $async.Future<$0.AddTextArgs> request) async {
    return addText(call, await request);
  }

  $async.Future<$0.Void> trim_Pre($grpc.ServiceCall call, $async.Future<$0.TrimArgs> request) async {
    return trim(call, await request);
  }

  $async.Future<$0.Void> ingest_Pre($grpc.ServiceCall call, $async.Future<$0.IngestArgs> request) async {
    return ingest(call, await request);
  }

  $async.Stream<$0.Token> generate_Pre($grpc.ServiceCall call, $async.Future<$0.GenerateArgs> request) async* {
    yield* generate(call, await request);
  }

  $async.Future<$0.NewContextResp> newContext($grpc.ServiceCall call, $0.NewContextArgs request);
  $async.Future<$0.Void> freeContext($grpc.ServiceCall call, $0.FreeContextArgs request);
  $async.Future<$0.AddTextResp> addText($grpc.ServiceCall call, $0.AddTextArgs request);
  $async.Future<$0.Void> trim($grpc.ServiceCall call, $0.TrimArgs request);
  $async.Future<$0.Void> ingest($grpc.ServiceCall call, $0.IngestArgs request);
  $async.Stream<$0.Token> generate($grpc.ServiceCall call, $0.GenerateArgs request);
}
