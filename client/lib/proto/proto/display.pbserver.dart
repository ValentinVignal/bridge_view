// This is a generated file - do not edit.
//
// Generated from proto/display.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'display.pb.dart' as $0;
import 'display.pbjson.dart';

export 'display.pb.dart';

abstract class DisplayServiceBase extends $pb.GeneratedService {
  $async.Future<$0.DisplayConfig> registerClient(
      $pb.ServerContext ctx, $0.ClientRegistration request);
  $async.Future<$0.VideoFrame> streamFrames(
      $pb.ServerContext ctx, $0.FrameRequest request);
  $async.Future<$0.InputResponse> sendInput(
      $pb.ServerContext ctx, $0.InputEvent request);
  $async.Future<$0.ControlResponse> sendControl(
      $pb.ServerContext ctx, $0.ControlMessage request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'RegisterClient':
        return $0.ClientRegistration();
      case 'StreamFrames':
        return $0.FrameRequest();
      case 'SendInput':
        return $0.InputEvent();
      case 'SendControl':
        return $0.ControlMessage();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'RegisterClient':
        return registerClient(ctx, request as $0.ClientRegistration);
      case 'StreamFrames':
        return streamFrames(ctx, request as $0.FrameRequest);
      case 'SendInput':
        return sendInput(ctx, request as $0.InputEvent);
      case 'SendControl':
        return sendControl(ctx, request as $0.ControlMessage);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => DisplayServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => DisplayServiceBase$messageJson;
}
