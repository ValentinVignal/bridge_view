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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'display.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'display.pbenum.dart';

/// Client registration request
class ClientRegistration extends $pb.GeneratedMessage {
  factory ClientRegistration({
    $core.String? clientId,
    DeviceType? deviceType,
    $core.String? deviceName,
    ClientCapabilities? capabilities,
  }) {
    final result = create();
    if (clientId != null) result.clientId = clientId;
    if (deviceType != null) result.deviceType = deviceType;
    if (deviceName != null) result.deviceName = deviceName;
    if (capabilities != null) result.capabilities = capabilities;
    return result;
  }

  ClientRegistration._();

  factory ClientRegistration.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClientRegistration.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientRegistration',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aE<DeviceType>(2, _omitFieldNames ? '' : 'deviceType',
        enumValues: DeviceType.values)
    ..aOS(3, _omitFieldNames ? '' : 'deviceName')
    ..aOM<ClientCapabilities>(4, _omitFieldNames ? '' : 'capabilities',
        subBuilder: ClientCapabilities.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRegistration clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRegistration copyWith(void Function(ClientRegistration) updates) =>
      super.copyWith((message) => updates(message as ClientRegistration))
          as ClientRegistration;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientRegistration create() => ClientRegistration._();
  @$core.override
  ClientRegistration createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClientRegistration getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientRegistration>(create);
  static ClientRegistration? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  @$pb.TagNumber(2)
  DeviceType get deviceType => $_getN(1);
  @$pb.TagNumber(2)
  set deviceType(DeviceType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceName => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceName() => $_clearField(3);

  @$pb.TagNumber(4)
  ClientCapabilities get capabilities => $_getN(3);
  @$pb.TagNumber(4)
  set capabilities(ClientCapabilities value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCapabilities() => $_has(3);
  @$pb.TagNumber(4)
  void clearCapabilities() => $_clearField(4);
  @$pb.TagNumber(4)
  ClientCapabilities ensureCapabilities() => $_ensure(3);
}

/// Client capabilities
class ClientCapabilities extends $pb.GeneratedMessage {
  factory ClientCapabilities({
    $core.int? maxWidth,
    $core.int? maxHeight,
    $core.Iterable<VideoCodec>? supportedCodecs,
    $core.bool? supportsTouch,
    $core.bool? supportsKeyboard,
    $core.bool? supportsMouse,
    $core.int? maxFramerate,
  }) {
    final result = create();
    if (maxWidth != null) result.maxWidth = maxWidth;
    if (maxHeight != null) result.maxHeight = maxHeight;
    if (supportedCodecs != null) result.supportedCodecs.addAll(supportedCodecs);
    if (supportsTouch != null) result.supportsTouch = supportsTouch;
    if (supportsKeyboard != null) result.supportsKeyboard = supportsKeyboard;
    if (supportsMouse != null) result.supportsMouse = supportsMouse;
    if (maxFramerate != null) result.maxFramerate = maxFramerate;
    return result;
  }

  ClientCapabilities._();

  factory ClientCapabilities.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClientCapabilities.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientCapabilities',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'maxWidth', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'maxHeight', fieldType: $pb.PbFieldType.OU3)
    ..pc<VideoCodec>(
        3, _omitFieldNames ? '' : 'supportedCodecs', $pb.PbFieldType.KE,
        valueOf: VideoCodec.valueOf,
        enumValues: VideoCodec.values,
        defaultEnumValue: VideoCodec.VIDEO_CODEC_UNSPECIFIED)
    ..aOB(4, _omitFieldNames ? '' : 'supportsTouch')
    ..aOB(5, _omitFieldNames ? '' : 'supportsKeyboard')
    ..aOB(6, _omitFieldNames ? '' : 'supportsMouse')
    ..aI(7, _omitFieldNames ? '' : 'maxFramerate',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientCapabilities clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientCapabilities copyWith(void Function(ClientCapabilities) updates) =>
      super.copyWith((message) => updates(message as ClientCapabilities))
          as ClientCapabilities;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientCapabilities create() => ClientCapabilities._();
  @$core.override
  ClientCapabilities createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClientCapabilities getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientCapabilities>(create);
  static ClientCapabilities? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get maxWidth => $_getIZ(0);
  @$pb.TagNumber(1)
  set maxWidth($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMaxWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearMaxWidth() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxHeight($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<VideoCodec> get supportedCodecs => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get supportsTouch => $_getBF(3);
  @$pb.TagNumber(4)
  set supportsTouch($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSupportsTouch() => $_has(3);
  @$pb.TagNumber(4)
  void clearSupportsTouch() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get supportsKeyboard => $_getBF(4);
  @$pb.TagNumber(5)
  set supportsKeyboard($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSupportsKeyboard() => $_has(4);
  @$pb.TagNumber(5)
  void clearSupportsKeyboard() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get supportsMouse => $_getBF(5);
  @$pb.TagNumber(6)
  set supportsMouse($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSupportsMouse() => $_has(5);
  @$pb.TagNumber(6)
  void clearSupportsMouse() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get maxFramerate => $_getIZ(6);
  @$pb.TagNumber(7)
  set maxFramerate($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMaxFramerate() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxFramerate() => $_clearField(7);
}

/// Display configuration sent to client
class DisplayConfig extends $pb.GeneratedMessage {
  factory DisplayConfig({
    $core.String? sessionId,
    $core.int? displayWidth,
    $core.int? displayHeight,
    $core.int? framerate,
    VideoCodec? codec,
    DisplayPosition? position,
    CompressionSettings? compression,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (displayWidth != null) result.displayWidth = displayWidth;
    if (displayHeight != null) result.displayHeight = displayHeight;
    if (framerate != null) result.framerate = framerate;
    if (codec != null) result.codec = codec;
    if (position != null) result.position = position;
    if (compression != null) result.compression = compression;
    return result;
  }

  DisplayConfig._();

  factory DisplayConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DisplayConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisplayConfig',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aI(2, _omitFieldNames ? '' : 'displayWidth',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'displayHeight',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'framerate', fieldType: $pb.PbFieldType.OU3)
    ..aE<VideoCodec>(5, _omitFieldNames ? '' : 'codec',
        enumValues: VideoCodec.values)
    ..aOM<DisplayPosition>(6, _omitFieldNames ? '' : 'position',
        subBuilder: DisplayPosition.create)
    ..aOM<CompressionSettings>(7, _omitFieldNames ? '' : 'compression',
        subBuilder: CompressionSettings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisplayConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisplayConfig copyWith(void Function(DisplayConfig) updates) =>
      super.copyWith((message) => updates(message as DisplayConfig))
          as DisplayConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisplayConfig create() => DisplayConfig._();
  @$core.override
  DisplayConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DisplayConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisplayConfig>(create);
  static DisplayConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get displayWidth => $_getIZ(1);
  @$pb.TagNumber(2)
  set displayWidth($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayWidth() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayWidth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get displayHeight => $_getIZ(2);
  @$pb.TagNumber(3)
  set displayHeight($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDisplayHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayHeight() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get framerate => $_getIZ(3);
  @$pb.TagNumber(4)
  set framerate($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFramerate() => $_has(3);
  @$pb.TagNumber(4)
  void clearFramerate() => $_clearField(4);

  @$pb.TagNumber(5)
  VideoCodec get codec => $_getN(4);
  @$pb.TagNumber(5)
  set codec(VideoCodec value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCodec() => $_has(4);
  @$pb.TagNumber(5)
  void clearCodec() => $_clearField(5);

  @$pb.TagNumber(6)
  DisplayPosition get position => $_getN(5);
  @$pb.TagNumber(6)
  set position(DisplayPosition value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasPosition() => $_has(5);
  @$pb.TagNumber(6)
  void clearPosition() => $_clearField(6);
  @$pb.TagNumber(6)
  DisplayPosition ensurePosition() => $_ensure(5);

  @$pb.TagNumber(7)
  CompressionSettings get compression => $_getN(6);
  @$pb.TagNumber(7)
  set compression(CompressionSettings value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCompression() => $_has(6);
  @$pb.TagNumber(7)
  void clearCompression() => $_clearField(7);
  @$pb.TagNumber(7)
  CompressionSettings ensureCompression() => $_ensure(6);
}

/// Display position in extended desktop
class DisplayPosition extends $pb.GeneratedMessage {
  factory DisplayPosition({
    $core.int? xOffset,
    $core.int? yOffset,
    $core.int? width,
    $core.int? height,
  }) {
    final result = create();
    if (xOffset != null) result.xOffset = xOffset;
    if (yOffset != null) result.yOffset = yOffset;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    return result;
  }

  DisplayPosition._();

  factory DisplayPosition.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DisplayPosition.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisplayPosition',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'xOffset')
    ..aI(2, _omitFieldNames ? '' : 'yOffset')
    ..aI(3, _omitFieldNames ? '' : 'width', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisplayPosition clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisplayPosition copyWith(void Function(DisplayPosition) updates) =>
      super.copyWith((message) => updates(message as DisplayPosition))
          as DisplayPosition;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisplayPosition create() => DisplayPosition._();
  @$core.override
  DisplayPosition createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DisplayPosition getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisplayPosition>(create);
  static DisplayPosition? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get xOffset => $_getIZ(0);
  @$pb.TagNumber(1)
  set xOffset($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXOffset() => $_has(0);
  @$pb.TagNumber(1)
  void clearXOffset() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get yOffset => $_getIZ(1);
  @$pb.TagNumber(2)
  set yOffset($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasYOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearYOffset() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(2);
  @$pb.TagNumber(3)
  set width($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);
}

/// Compression settings
class CompressionSettings extends $pb.GeneratedMessage {
  factory CompressionSettings({
    $core.int? bitrateKbps,
    $core.int? quality,
    $core.bool? adaptiveBitrate,
  }) {
    final result = create();
    if (bitrateKbps != null) result.bitrateKbps = bitrateKbps;
    if (quality != null) result.quality = quality;
    if (adaptiveBitrate != null) result.adaptiveBitrate = adaptiveBitrate;
    return result;
  }

  CompressionSettings._();

  factory CompressionSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CompressionSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CompressionSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'bitrateKbps',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'quality', fieldType: $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'adaptiveBitrate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompressionSettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompressionSettings copyWith(void Function(CompressionSettings) updates) =>
      super.copyWith((message) => updates(message as CompressionSettings))
          as CompressionSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CompressionSettings create() => CompressionSettings._();
  @$core.override
  CompressionSettings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CompressionSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CompressionSettings>(create);
  static CompressionSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get bitrateKbps => $_getIZ(0);
  @$pb.TagNumber(1)
  set bitrateKbps($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBitrateKbps() => $_has(0);
  @$pb.TagNumber(1)
  void clearBitrateKbps() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get quality => $_getIZ(1);
  @$pb.TagNumber(2)
  set quality($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuality() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuality() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get adaptiveBitrate => $_getBF(2);
  @$pb.TagNumber(3)
  set adaptiveBitrate($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAdaptiveBitrate() => $_has(2);
  @$pb.TagNumber(3)
  void clearAdaptiveBitrate() => $_clearField(3);
}

/// Frame request from client
class FrameRequest extends $pb.GeneratedMessage {
  factory FrameRequest({
    $core.String? sessionId,
    $fixnum.Int64? lastFrameSequence,
    FrameRequestType? requestType,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (lastFrameSequence != null) result.lastFrameSequence = lastFrameSequence;
    if (requestType != null) result.requestType = requestType;
    return result;
  }

  FrameRequest._();

  factory FrameRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FrameRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FrameRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'lastFrameSequence', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aE<FrameRequestType>(3, _omitFieldNames ? '' : 'requestType',
        enumValues: FrameRequestType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FrameRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FrameRequest copyWith(void Function(FrameRequest) updates) =>
      super.copyWith((message) => updates(message as FrameRequest))
          as FrameRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FrameRequest create() => FrameRequest._();
  @$core.override
  FrameRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FrameRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FrameRequest>(create);
  static FrameRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get lastFrameSequence => $_getI64(1);
  @$pb.TagNumber(2)
  set lastFrameSequence($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastFrameSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastFrameSequence() => $_clearField(2);

  @$pb.TagNumber(3)
  FrameRequestType get requestType => $_getN(2);
  @$pb.TagNumber(3)
  set requestType(FrameRequestType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRequestType() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestType() => $_clearField(3);
}

/// Video frame data
class VideoFrame extends $pb.GeneratedMessage {
  factory VideoFrame({
    $fixnum.Int64? sequenceNumber,
    $fixnum.Int64? timestampUs,
    $core.List<$core.int>? frameData,
    FrameType? frameType,
    $core.int? width,
    $core.int? height,
  }) {
    final result = create();
    if (sequenceNumber != null) result.sequenceNumber = sequenceNumber;
    if (timestampUs != null) result.timestampUs = timestampUs;
    if (frameData != null) result.frameData = frameData;
    if (frameType != null) result.frameType = frameType;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    return result;
  }

  VideoFrame._();

  factory VideoFrame.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VideoFrame.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VideoFrame',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'sequenceNumber', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'timestampUs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'frameData', $pb.PbFieldType.OY)
    ..aE<FrameType>(4, _omitFieldNames ? '' : 'frameType',
        enumValues: FrameType.values)
    ..aI(5, _omitFieldNames ? '' : 'width', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VideoFrame clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VideoFrame copyWith(void Function(VideoFrame) updates) =>
      super.copyWith((message) => updates(message as VideoFrame)) as VideoFrame;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VideoFrame create() => VideoFrame._();
  @$core.override
  VideoFrame createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VideoFrame getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VideoFrame>(create);
  static VideoFrame? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sequenceNumber => $_getI64(0);
  @$pb.TagNumber(1)
  set sequenceNumber($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSequenceNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequenceNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestampUs => $_getI64(1);
  @$pb.TagNumber(2)
  set timestampUs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestampUs() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestampUs() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get frameData => $_getN(2);
  @$pb.TagNumber(3)
  set frameData($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFrameData() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrameData() => $_clearField(3);

  @$pb.TagNumber(4)
  FrameType get frameType => $_getN(3);
  @$pb.TagNumber(4)
  set frameType(FrameType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFrameType() => $_has(3);
  @$pb.TagNumber(4)
  void clearFrameType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get width => $_getIZ(4);
  @$pb.TagNumber(5)
  set width($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWidth() => $_has(4);
  @$pb.TagNumber(5)
  void clearWidth() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get height => $_getIZ(5);
  @$pb.TagNumber(6)
  set height($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearHeight() => $_clearField(6);
}

enum InputEvent_Event { mouse, keyboard, touch, notSet }

/// Input event from client to server
class InputEvent extends $pb.GeneratedMessage {
  factory InputEvent({
    $core.String? sessionId,
    $fixnum.Int64? timestampUs,
    MouseEvent? mouse,
    KeyboardEvent? keyboard,
    TouchEvent? touch,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (timestampUs != null) result.timestampUs = timestampUs;
    if (mouse != null) result.mouse = mouse;
    if (keyboard != null) result.keyboard = keyboard;
    if (touch != null) result.touch = touch;
    return result;
  }

  InputEvent._();

  factory InputEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InputEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, InputEvent_Event> _InputEvent_EventByTag = {
    3: InputEvent_Event.mouse,
    4: InputEvent_Event.keyboard,
    5: InputEvent_Event.touch,
    0: InputEvent_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InputEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..oo(0, [3, 4, 5])
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'timestampUs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<MouseEvent>(3, _omitFieldNames ? '' : 'mouse',
        subBuilder: MouseEvent.create)
    ..aOM<KeyboardEvent>(4, _omitFieldNames ? '' : 'keyboard',
        subBuilder: KeyboardEvent.create)
    ..aOM<TouchEvent>(5, _omitFieldNames ? '' : 'touch',
        subBuilder: TouchEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InputEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InputEvent copyWith(void Function(InputEvent) updates) =>
      super.copyWith((message) => updates(message as InputEvent)) as InputEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InputEvent create() => InputEvent._();
  @$core.override
  InputEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InputEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InputEvent>(create);
  static InputEvent? _defaultInstance;

  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  InputEvent_Event whichEvent() => _InputEvent_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestampUs => $_getI64(1);
  @$pb.TagNumber(2)
  set timestampUs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestampUs() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestampUs() => $_clearField(2);

  @$pb.TagNumber(3)
  MouseEvent get mouse => $_getN(2);
  @$pb.TagNumber(3)
  set mouse(MouseEvent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMouse() => $_has(2);
  @$pb.TagNumber(3)
  void clearMouse() => $_clearField(3);
  @$pb.TagNumber(3)
  MouseEvent ensureMouse() => $_ensure(2);

  @$pb.TagNumber(4)
  KeyboardEvent get keyboard => $_getN(3);
  @$pb.TagNumber(4)
  set keyboard(KeyboardEvent value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasKeyboard() => $_has(3);
  @$pb.TagNumber(4)
  void clearKeyboard() => $_clearField(4);
  @$pb.TagNumber(4)
  KeyboardEvent ensureKeyboard() => $_ensure(3);

  @$pb.TagNumber(5)
  TouchEvent get touch => $_getN(4);
  @$pb.TagNumber(5)
  set touch(TouchEvent value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasTouch() => $_has(4);
  @$pb.TagNumber(5)
  void clearTouch() => $_clearField(5);
  @$pb.TagNumber(5)
  TouchEvent ensureTouch() => $_ensure(4);
}

/// Mouse event
class MouseEvent extends $pb.GeneratedMessage {
  factory MouseEvent({
    MouseEventType? type,
    $core.double? x,
    $core.double? y,
    MouseButton? button,
    $core.int? scrollDeltaX,
    $core.int? scrollDeltaY,
    KeyModifiers? modifiers,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    if (button != null) result.button = button;
    if (scrollDeltaX != null) result.scrollDeltaX = scrollDeltaX;
    if (scrollDeltaY != null) result.scrollDeltaY = scrollDeltaY;
    if (modifiers != null) result.modifiers = modifiers;
    return result;
  }

  MouseEvent._();

  factory MouseEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MouseEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MouseEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aE<MouseEventType>(1, _omitFieldNames ? '' : 'type',
        enumValues: MouseEventType.values)
    ..aD(2, _omitFieldNames ? '' : 'x', fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'y', fieldType: $pb.PbFieldType.OF)
    ..aE<MouseButton>(4, _omitFieldNames ? '' : 'button',
        enumValues: MouseButton.values)
    ..aI(5, _omitFieldNames ? '' : 'scrollDeltaX')
    ..aI(6, _omitFieldNames ? '' : 'scrollDeltaY')
    ..aOM<KeyModifiers>(7, _omitFieldNames ? '' : 'modifiers',
        subBuilder: KeyModifiers.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MouseEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MouseEvent copyWith(void Function(MouseEvent) updates) =>
      super.copyWith((message) => updates(message as MouseEvent)) as MouseEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MouseEvent create() => MouseEvent._();
  @$core.override
  MouseEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MouseEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MouseEvent>(create);
  static MouseEvent? _defaultInstance;

  @$pb.TagNumber(1)
  MouseEventType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(MouseEventType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get x => $_getN(1);
  @$pb.TagNumber(2)
  set x($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasX() => $_has(1);
  @$pb.TagNumber(2)
  void clearX() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get y => $_getN(2);
  @$pb.TagNumber(3)
  set y($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasY() => $_has(2);
  @$pb.TagNumber(3)
  void clearY() => $_clearField(3);

  @$pb.TagNumber(4)
  MouseButton get button => $_getN(3);
  @$pb.TagNumber(4)
  set button(MouseButton value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasButton() => $_has(3);
  @$pb.TagNumber(4)
  void clearButton() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get scrollDeltaX => $_getIZ(4);
  @$pb.TagNumber(5)
  set scrollDeltaX($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasScrollDeltaX() => $_has(4);
  @$pb.TagNumber(5)
  void clearScrollDeltaX() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get scrollDeltaY => $_getIZ(5);
  @$pb.TagNumber(6)
  set scrollDeltaY($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScrollDeltaY() => $_has(5);
  @$pb.TagNumber(6)
  void clearScrollDeltaY() => $_clearField(6);

  @$pb.TagNumber(7)
  KeyModifiers get modifiers => $_getN(6);
  @$pb.TagNumber(7)
  set modifiers(KeyModifiers value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasModifiers() => $_has(6);
  @$pb.TagNumber(7)
  void clearModifiers() => $_clearField(7);
  @$pb.TagNumber(7)
  KeyModifiers ensureModifiers() => $_ensure(6);
}

/// Keyboard event
class KeyboardEvent extends $pb.GeneratedMessage {
  factory KeyboardEvent({
    KeyboardEventType? type,
    $core.int? keyCode,
    $core.String? keyChar,
    KeyModifiers? modifiers,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (keyCode != null) result.keyCode = keyCode;
    if (keyChar != null) result.keyChar = keyChar;
    if (modifiers != null) result.modifiers = modifiers;
    return result;
  }

  KeyboardEvent._();

  factory KeyboardEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KeyboardEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KeyboardEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aE<KeyboardEventType>(1, _omitFieldNames ? '' : 'type',
        enumValues: KeyboardEventType.values)
    ..aI(2, _omitFieldNames ? '' : 'keyCode', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'keyChar')
    ..aOM<KeyModifiers>(4, _omitFieldNames ? '' : 'modifiers',
        subBuilder: KeyModifiers.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyboardEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyboardEvent copyWith(void Function(KeyboardEvent) updates) =>
      super.copyWith((message) => updates(message as KeyboardEvent))
          as KeyboardEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyboardEvent create() => KeyboardEvent._();
  @$core.override
  KeyboardEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static KeyboardEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KeyboardEvent>(create);
  static KeyboardEvent? _defaultInstance;

  @$pb.TagNumber(1)
  KeyboardEventType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(KeyboardEventType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get keyCode => $_getIZ(1);
  @$pb.TagNumber(2)
  set keyCode($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKeyCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearKeyCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get keyChar => $_getSZ(2);
  @$pb.TagNumber(3)
  set keyChar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKeyChar() => $_has(2);
  @$pb.TagNumber(3)
  void clearKeyChar() => $_clearField(3);

  @$pb.TagNumber(4)
  KeyModifiers get modifiers => $_getN(3);
  @$pb.TagNumber(4)
  set modifiers(KeyModifiers value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasModifiers() => $_has(3);
  @$pb.TagNumber(4)
  void clearModifiers() => $_clearField(4);
  @$pb.TagNumber(4)
  KeyModifiers ensureModifiers() => $_ensure(3);
}

/// Keyboard modifiers
class KeyModifiers extends $pb.GeneratedMessage {
  factory KeyModifiers({
    $core.bool? shift,
    $core.bool? ctrl,
    $core.bool? alt,
    $core.bool? meta,
  }) {
    final result = create();
    if (shift != null) result.shift = shift;
    if (ctrl != null) result.ctrl = ctrl;
    if (alt != null) result.alt = alt;
    if (meta != null) result.meta = meta;
    return result;
  }

  KeyModifiers._();

  factory KeyModifiers.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KeyModifiers.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KeyModifiers',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'shift')
    ..aOB(2, _omitFieldNames ? '' : 'ctrl')
    ..aOB(3, _omitFieldNames ? '' : 'alt')
    ..aOB(4, _omitFieldNames ? '' : 'meta')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyModifiers clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyModifiers copyWith(void Function(KeyModifiers) updates) =>
      super.copyWith((message) => updates(message as KeyModifiers))
          as KeyModifiers;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyModifiers create() => KeyModifiers._();
  @$core.override
  KeyModifiers createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static KeyModifiers getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KeyModifiers>(create);
  static KeyModifiers? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get shift => $_getBF(0);
  @$pb.TagNumber(1)
  set shift($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShift() => $_has(0);
  @$pb.TagNumber(1)
  void clearShift() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get ctrl => $_getBF(1);
  @$pb.TagNumber(2)
  set ctrl($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCtrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearCtrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get alt => $_getBF(2);
  @$pb.TagNumber(3)
  set alt($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAlt() => $_has(2);
  @$pb.TagNumber(3)
  void clearAlt() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get meta => $_getBF(3);
  @$pb.TagNumber(4)
  set meta($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMeta() => $_has(3);
  @$pb.TagNumber(4)
  void clearMeta() => $_clearField(4);
}

/// Touch event
class TouchEvent extends $pb.GeneratedMessage {
  factory TouchEvent({
    TouchEventType? type,
    $core.Iterable<TouchPoint>? touches,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (touches != null) result.touches.addAll(touches);
    return result;
  }

  TouchEvent._();

  factory TouchEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TouchEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TouchEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aE<TouchEventType>(1, _omitFieldNames ? '' : 'type',
        enumValues: TouchEventType.values)
    ..pPM<TouchPoint>(2, _omitFieldNames ? '' : 'touches',
        subBuilder: TouchPoint.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchEvent copyWith(void Function(TouchEvent) updates) =>
      super.copyWith((message) => updates(message as TouchEvent)) as TouchEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TouchEvent create() => TouchEvent._();
  @$core.override
  TouchEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TouchEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TouchEvent>(create);
  static TouchEvent? _defaultInstance;

  @$pb.TagNumber(1)
  TouchEventType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(TouchEventType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<TouchPoint> get touches => $_getList(1);
}

/// Touch point
class TouchPoint extends $pb.GeneratedMessage {
  factory TouchPoint({
    $core.int? id,
    $core.double? x,
    $core.double? y,
    $core.double? pressure,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    if (pressure != null) result.pressure = pressure;
    return result;
  }

  TouchPoint._();

  factory TouchPoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TouchPoint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TouchPoint',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aD(2, _omitFieldNames ? '' : 'x', fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'y', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'pressure', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchPoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchPoint copyWith(void Function(TouchPoint) updates) =>
      super.copyWith((message) => updates(message as TouchPoint)) as TouchPoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TouchPoint create() => TouchPoint._();
  @$core.override
  TouchPoint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TouchPoint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TouchPoint>(create);
  static TouchPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get x => $_getN(1);
  @$pb.TagNumber(2)
  set x($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasX() => $_has(1);
  @$pb.TagNumber(2)
  void clearX() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get y => $_getN(2);
  @$pb.TagNumber(3)
  set y($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasY() => $_has(2);
  @$pb.TagNumber(3)
  void clearY() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get pressure => $_getN(3);
  @$pb.TagNumber(4)
  set pressure($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPressure() => $_has(3);
  @$pb.TagNumber(4)
  void clearPressure() => $_clearField(4);
}

/// Input response
class InputResponse extends $pb.GeneratedMessage {
  factory InputResponse({
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  InputResponse._();

  factory InputResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InputResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InputResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InputResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InputResponse copyWith(void Function(InputResponse) updates) =>
      super.copyWith((message) => updates(message as InputResponse))
          as InputResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InputResponse create() => InputResponse._();
  @$core.override
  InputResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InputResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InputResponse>(create);
  static InputResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);
}

/// Control message
class ControlMessage extends $pb.GeneratedMessage {
  factory ControlMessage({
    $core.String? sessionId,
    ControlMessageType? type,
    $core.String? payload,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (type != null) result.type = type;
    if (payload != null) result.payload = payload;
    return result;
  }

  ControlMessage._();

  factory ControlMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ControlMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ControlMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aE<ControlMessageType>(2, _omitFieldNames ? '' : 'type',
        enumValues: ControlMessageType.values)
    ..aOS(3, _omitFieldNames ? '' : 'payload')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ControlMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ControlMessage copyWith(void Function(ControlMessage) updates) =>
      super.copyWith((message) => updates(message as ControlMessage))
          as ControlMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ControlMessage create() => ControlMessage._();
  @$core.override
  ControlMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ControlMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ControlMessage>(create);
  static ControlMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  ControlMessageType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ControlMessageType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get payload => $_getSZ(2);
  @$pb.TagNumber(3)
  set payload($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayload() => $_clearField(3);
}

/// Control response
class ControlResponse extends $pb.GeneratedMessage {
  factory ControlResponse({
    $core.bool? success,
    $core.String? message,
    $fixnum.Int64? timestampUs,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (timestampUs != null) result.timestampUs = timestampUs;
    return result;
  }

  ControlResponse._();

  factory ControlResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ControlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ControlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bridge_view'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'timestampUs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ControlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ControlResponse copyWith(void Function(ControlResponse) updates) =>
      super.copyWith((message) => updates(message as ControlResponse))
          as ControlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ControlResponse create() => ControlResponse._();
  @$core.override
  ControlResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ControlResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ControlResponse>(create);
  static ControlResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestampUs => $_getI64(2);
  @$pb.TagNumber(3)
  set timestampUs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestampUs() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestampUs() => $_clearField(3);
}

/// Service definition for display streaming
class DisplayServiceApi {
  final $pb.RpcClient _client;

  DisplayServiceApi(this._client);

  /// Client registers and receives display configuration
  $async.Future<DisplayConfig> registerClient(
          $pb.ClientContext? ctx, ClientRegistration request) =>
      _client.invoke<DisplayConfig>(
          ctx, 'DisplayService', 'RegisterClient', request, DisplayConfig());

  /// Stream video frames from server to client
  $async.Future<VideoFrame> streamFrames(
          $pb.ClientContext? ctx, FrameRequest request) =>
      _client.invoke<VideoFrame>(
          ctx, 'DisplayService', 'StreamFrames', request, VideoFrame());

  /// Send input events from client to server
  $async.Future<InputResponse> sendInput(
          $pb.ClientContext? ctx, InputEvent request) =>
      _client.invoke<InputResponse>(
          ctx, 'DisplayService', 'SendInput', request, InputResponse());

  /// Control messages for connection management
  $async.Future<ControlResponse> sendControl(
          $pb.ClientContext? ctx, ControlMessage request) =>
      _client.invoke<ControlResponse>(
          ctx, 'DisplayService', 'SendControl', request, ControlResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
