// This is a generated file - do not edit.
//
// Generated from proto/display.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use deviceTypeDescriptor instead')
const DeviceType$json = {
  '1': 'DeviceType',
  '2': [
    {'1': 'DEVICE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'DEVICE_TYPE_ANDROID_PHONE', '2': 1},
    {'1': 'DEVICE_TYPE_MACOS_LAPTOP', '2': 2},
    {'1': 'DEVICE_TYPE_IOS_PHONE', '2': 3},
  ],
};

/// Descriptor for `DeviceType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deviceTypeDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VUeXBlEhsKF0RFVklDRV9UWVBFX1VOU1BFQ0lGSUVEEAASHQoZREVWSUNFX1RZUE'
    'VfQU5EUk9JRF9QSE9ORRABEhwKGERFVklDRV9UWVBFX01BQ09TX0xBUFRPUBACEhkKFURFVklD'
    'RV9UWVBFX0lPU19QSE9ORRAD');

@$core.Deprecated('Use videoCodecDescriptor instead')
const VideoCodec$json = {
  '1': 'VideoCodec',
  '2': [
    {'1': 'VIDEO_CODEC_UNSPECIFIED', '2': 0},
    {'1': 'VIDEO_CODEC_H264', '2': 1},
    {'1': 'VIDEO_CODEC_H265', '2': 2},
    {'1': 'VIDEO_CODEC_VP8', '2': 3},
    {'1': 'VIDEO_CODEC_VP9', '2': 4},
  ],
};

/// Descriptor for `VideoCodec`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List videoCodecDescriptor = $convert.base64Decode(
    'CgpWaWRlb0NvZGVjEhsKF1ZJREVPX0NPREVDX1VOU1BFQ0lGSUVEEAASFAoQVklERU9fQ09ERU'
    'NfSDI2NBABEhQKEFZJREVPX0NPREVDX0gyNjUQAhITCg9WSURFT19DT0RFQ19WUDgQAxITCg9W'
    'SURFT19DT0RFQ19WUDkQBA==');

@$core.Deprecated('Use frameRequestTypeDescriptor instead')
const FrameRequestType$json = {
  '1': 'FrameRequestType',
  '2': [
    {'1': 'FRAME_REQUEST_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'FRAME_REQUEST_TYPE_CONTINUE', '2': 1},
    {'1': 'FRAME_REQUEST_TYPE_KEYFRAME', '2': 2},
    {'1': 'FRAME_REQUEST_TYPE_PAUSE', '2': 3},
    {'1': 'FRAME_REQUEST_TYPE_RESUME', '2': 4},
  ],
};

/// Descriptor for `FrameRequestType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List frameRequestTypeDescriptor = $convert.base64Decode(
    'ChBGcmFtZVJlcXVlc3RUeXBlEiIKHkZSQU1FX1JFUVVFU1RfVFlQRV9VTlNQRUNJRklFRBAAEh'
    '8KG0ZSQU1FX1JFUVVFU1RfVFlQRV9DT05USU5VRRABEh8KG0ZSQU1FX1JFUVVFU1RfVFlQRV9L'
    'RVlGUkFNRRACEhwKGEZSQU1FX1JFUVVFU1RfVFlQRV9QQVVTRRADEh0KGUZSQU1FX1JFUVVFU1'
    'RfVFlQRV9SRVNVTUUQBA==');

@$core.Deprecated('Use frameTypeDescriptor instead')
const FrameType$json = {
  '1': 'FrameType',
  '2': [
    {'1': 'FRAME_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'FRAME_TYPE_KEYFRAME', '2': 1},
    {'1': 'FRAME_TYPE_DELTA', '2': 2},
  ],
};

/// Descriptor for `FrameType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List frameTypeDescriptor = $convert.base64Decode(
    'CglGcmFtZVR5cGUSGgoWRlJBTUVfVFlQRV9VTlNQRUNJRklFRBAAEhcKE0ZSQU1FX1RZUEVfS0'
    'VZRlJBTUUQARIUChBGUkFNRV9UWVBFX0RFTFRBEAI=');

@$core.Deprecated('Use mouseEventTypeDescriptor instead')
const MouseEventType$json = {
  '1': 'MouseEventType',
  '2': [
    {'1': 'MOUSE_EVENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'MOUSE_EVENT_TYPE_MOVE', '2': 1},
    {'1': 'MOUSE_EVENT_TYPE_DOWN', '2': 2},
    {'1': 'MOUSE_EVENT_TYPE_UP', '2': 3},
    {'1': 'MOUSE_EVENT_TYPE_SCROLL', '2': 4},
    {'1': 'MOUSE_EVENT_TYPE_DRAG', '2': 5},
  ],
};

/// Descriptor for `MouseEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List mouseEventTypeDescriptor = $convert.base64Decode(
    'Cg5Nb3VzZUV2ZW50VHlwZRIgChxNT1VTRV9FVkVOVF9UWVBFX1VOU1BFQ0lGSUVEEAASGQoVTU'
    '9VU0VfRVZFTlRfVFlQRV9NT1ZFEAESGQoVTU9VU0VfRVZFTlRfVFlQRV9ET1dOEAISFwoTTU9V'
    'U0VfRVZFTlRfVFlQRV9VUBADEhsKF01PVVNFX0VWRU5UX1RZUEVfU0NST0xMEAQSGQoVTU9VU0'
    'VfRVZFTlRfVFlQRV9EUkFHEAU=');

@$core.Deprecated('Use mouseButtonDescriptor instead')
const MouseButton$json = {
  '1': 'MouseButton',
  '2': [
    {'1': 'MOUSE_BUTTON_UNSPECIFIED', '2': 0},
    {'1': 'MOUSE_BUTTON_LEFT', '2': 1},
    {'1': 'MOUSE_BUTTON_RIGHT', '2': 2},
    {'1': 'MOUSE_BUTTON_MIDDLE', '2': 3},
  ],
};

/// Descriptor for `MouseButton`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List mouseButtonDescriptor = $convert.base64Decode(
    'CgtNb3VzZUJ1dHRvbhIcChhNT1VTRV9CVVRUT05fVU5TUEVDSUZJRUQQABIVChFNT1VTRV9CVV'
    'RUT05fTEVGVBABEhYKEk1PVVNFX0JVVFRPTl9SSUdIVBACEhcKE01PVVNFX0JVVFRPTl9NSURE'
    'TEUQAw==');

@$core.Deprecated('Use keyboardEventTypeDescriptor instead')
const KeyboardEventType$json = {
  '1': 'KeyboardEventType',
  '2': [
    {'1': 'KEYBOARD_EVENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'KEYBOARD_EVENT_TYPE_DOWN', '2': 1},
    {'1': 'KEYBOARD_EVENT_TYPE_UP', '2': 2},
    {'1': 'KEYBOARD_EVENT_TYPE_PRESS', '2': 3},
  ],
};

/// Descriptor for `KeyboardEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List keyboardEventTypeDescriptor = $convert.base64Decode(
    'ChFLZXlib2FyZEV2ZW50VHlwZRIjCh9LRVlCT0FSRF9FVkVOVF9UWVBFX1VOU1BFQ0lGSUVEEA'
    'ASHAoYS0VZQk9BUkRfRVZFTlRfVFlQRV9ET1dOEAESGgoWS0VZQk9BUkRfRVZFTlRfVFlQRV9V'
    'UBACEh0KGUtFWUJPQVJEX0VWRU5UX1RZUEVfUFJFU1MQAw==');

@$core.Deprecated('Use touchEventTypeDescriptor instead')
const TouchEventType$json = {
  '1': 'TouchEventType',
  '2': [
    {'1': 'TOUCH_EVENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'TOUCH_EVENT_TYPE_DOWN', '2': 1},
    {'1': 'TOUCH_EVENT_TYPE_MOVE', '2': 2},
    {'1': 'TOUCH_EVENT_TYPE_UP', '2': 3},
    {'1': 'TOUCH_EVENT_TYPE_CANCEL', '2': 4},
  ],
};

/// Descriptor for `TouchEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List touchEventTypeDescriptor = $convert.base64Decode(
    'Cg5Ub3VjaEV2ZW50VHlwZRIgChxUT1VDSF9FVkVOVF9UWVBFX1VOU1BFQ0lGSUVEEAASGQoVVE'
    '9VQ0hfRVZFTlRfVFlQRV9ET1dOEAESGQoVVE9VQ0hfRVZFTlRfVFlQRV9NT1ZFEAISFwoTVE9V'
    'Q0hfRVZFTlRfVFlQRV9VUBADEhsKF1RPVUNIX0VWRU5UX1RZUEVfQ0FOQ0VMEAQ=');

@$core.Deprecated('Use controlMessageTypeDescriptor instead')
const ControlMessageType$json = {
  '1': 'ControlMessageType',
  '2': [
    {'1': 'CONTROL_MESSAGE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'CONTROL_MESSAGE_TYPE_HEARTBEAT', '2': 1},
    {'1': 'CONTROL_MESSAGE_TYPE_DISCONNECT', '2': 2},
    {'1': 'CONTROL_MESSAGE_TYPE_RECONFIGURE', '2': 3},
    {'1': 'CONTROL_MESSAGE_TYPE_ERROR', '2': 4},
  ],
};

/// Descriptor for `ControlMessageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List controlMessageTypeDescriptor = $convert.base64Decode(
    'ChJDb250cm9sTWVzc2FnZVR5cGUSJAogQ09OVFJPTF9NRVNTQUdFX1RZUEVfVU5TUEVDSUZJRU'
    'QQABIiCh5DT05UUk9MX01FU1NBR0VfVFlQRV9IRUFSVEJFQVQQARIjCh9DT05UUk9MX01FU1NB'
    'R0VfVFlQRV9ESVNDT05ORUNUEAISJAogQ09OVFJPTF9NRVNTQUdFX1RZUEVfUkVDT05GSUdVUk'
    'UQAxIeChpDT05UUk9MX01FU1NBR0VfVFlQRV9FUlJPUhAE');

@$core.Deprecated('Use clientRegistrationDescriptor instead')
const ClientRegistration$json = {
  '1': 'ClientRegistration',
  '2': [
    {'1': 'client_id', '3': 1, '4': 1, '5': 9, '10': 'clientId'},
    {
      '1': 'device_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.bridge_view.DeviceType',
      '10': 'deviceType'
    },
    {'1': 'device_name', '3': 3, '4': 1, '5': 9, '10': 'deviceName'},
    {
      '1': 'capabilities',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.bridge_view.ClientCapabilities',
      '10': 'capabilities'
    },
  ],
};

/// Descriptor for `ClientRegistration`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientRegistrationDescriptor = $convert.base64Decode(
    'ChJDbGllbnRSZWdpc3RyYXRpb24SGwoJY2xpZW50X2lkGAEgASgJUghjbGllbnRJZBI4CgtkZX'
    'ZpY2VfdHlwZRgCIAEoDjIXLmJyaWRnZV92aWV3LkRldmljZVR5cGVSCmRldmljZVR5cGUSHwoL'
    'ZGV2aWNlX25hbWUYAyABKAlSCmRldmljZU5hbWUSQwoMY2FwYWJpbGl0aWVzGAQgASgLMh8uYn'
    'JpZGdlX3ZpZXcuQ2xpZW50Q2FwYWJpbGl0aWVzUgxjYXBhYmlsaXRpZXM=');

@$core.Deprecated('Use clientCapabilitiesDescriptor instead')
const ClientCapabilities$json = {
  '1': 'ClientCapabilities',
  '2': [
    {'1': 'max_width', '3': 1, '4': 1, '5': 13, '10': 'maxWidth'},
    {'1': 'max_height', '3': 2, '4': 1, '5': 13, '10': 'maxHeight'},
    {
      '1': 'supported_codecs',
      '3': 3,
      '4': 3,
      '5': 14,
      '6': '.bridge_view.VideoCodec',
      '10': 'supportedCodecs'
    },
    {'1': 'supports_touch', '3': 4, '4': 1, '5': 8, '10': 'supportsTouch'},
    {
      '1': 'supports_keyboard',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'supportsKeyboard'
    },
    {'1': 'supports_mouse', '3': 6, '4': 1, '5': 8, '10': 'supportsMouse'},
    {'1': 'max_framerate', '3': 7, '4': 1, '5': 13, '10': 'maxFramerate'},
  ],
};

/// Descriptor for `ClientCapabilities`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientCapabilitiesDescriptor = $convert.base64Decode(
    'ChJDbGllbnRDYXBhYmlsaXRpZXMSGwoJbWF4X3dpZHRoGAEgASgNUghtYXhXaWR0aBIdCgptYX'
    'hfaGVpZ2h0GAIgASgNUgltYXhIZWlnaHQSQgoQc3VwcG9ydGVkX2NvZGVjcxgDIAMoDjIXLmJy'
    'aWRnZV92aWV3LlZpZGVvQ29kZWNSD3N1cHBvcnRlZENvZGVjcxIlCg5zdXBwb3J0c190b3VjaB'
    'gEIAEoCFINc3VwcG9ydHNUb3VjaBIrChFzdXBwb3J0c19rZXlib2FyZBgFIAEoCFIQc3VwcG9y'
    'dHNLZXlib2FyZBIlCg5zdXBwb3J0c19tb3VzZRgGIAEoCFINc3VwcG9ydHNNb3VzZRIjCg1tYX'
    'hfZnJhbWVyYXRlGAcgASgNUgxtYXhGcmFtZXJhdGU=');

@$core.Deprecated('Use displayConfigDescriptor instead')
const DisplayConfig$json = {
  '1': 'DisplayConfig',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'display_width', '3': 2, '4': 1, '5': 13, '10': 'displayWidth'},
    {'1': 'display_height', '3': 3, '4': 1, '5': 13, '10': 'displayHeight'},
    {'1': 'framerate', '3': 4, '4': 1, '5': 13, '10': 'framerate'},
    {
      '1': 'codec',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.bridge_view.VideoCodec',
      '10': 'codec'
    },
    {
      '1': 'position',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.bridge_view.DisplayPosition',
      '10': 'position'
    },
    {
      '1': 'compression',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.bridge_view.CompressionSettings',
      '10': 'compression'
    },
  ],
};

/// Descriptor for `DisplayConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List displayConfigDescriptor = $convert.base64Decode(
    'Cg1EaXNwbGF5Q29uZmlnEh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZBIjCg1kaXNwbG'
    'F5X3dpZHRoGAIgASgNUgxkaXNwbGF5V2lkdGgSJQoOZGlzcGxheV9oZWlnaHQYAyABKA1SDWRp'
    'c3BsYXlIZWlnaHQSHAoJZnJhbWVyYXRlGAQgASgNUglmcmFtZXJhdGUSLQoFY29kZWMYBSABKA'
    '4yFy5icmlkZ2Vfdmlldy5WaWRlb0NvZGVjUgVjb2RlYxI4Cghwb3NpdGlvbhgGIAEoCzIcLmJy'
    'aWRnZV92aWV3LkRpc3BsYXlQb3NpdGlvblIIcG9zaXRpb24SQgoLY29tcHJlc3Npb24YByABKA'
    'syIC5icmlkZ2Vfdmlldy5Db21wcmVzc2lvblNldHRpbmdzUgtjb21wcmVzc2lvbg==');

@$core.Deprecated('Use displayPositionDescriptor instead')
const DisplayPosition$json = {
  '1': 'DisplayPosition',
  '2': [
    {'1': 'x_offset', '3': 1, '4': 1, '5': 5, '10': 'xOffset'},
    {'1': 'y_offset', '3': 2, '4': 1, '5': 5, '10': 'yOffset'},
    {'1': 'width', '3': 3, '4': 1, '5': 13, '10': 'width'},
    {'1': 'height', '3': 4, '4': 1, '5': 13, '10': 'height'},
  ],
};

/// Descriptor for `DisplayPosition`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List displayPositionDescriptor = $convert.base64Decode(
    'Cg9EaXNwbGF5UG9zaXRpb24SGQoIeF9vZmZzZXQYASABKAVSB3hPZmZzZXQSGQoIeV9vZmZzZX'
    'QYAiABKAVSB3lPZmZzZXQSFAoFd2lkdGgYAyABKA1SBXdpZHRoEhYKBmhlaWdodBgEIAEoDVIG'
    'aGVpZ2h0');

@$core.Deprecated('Use compressionSettingsDescriptor instead')
const CompressionSettings$json = {
  '1': 'CompressionSettings',
  '2': [
    {'1': 'bitrate_kbps', '3': 1, '4': 1, '5': 13, '10': 'bitrateKbps'},
    {'1': 'quality', '3': 2, '4': 1, '5': 13, '10': 'quality'},
    {'1': 'adaptive_bitrate', '3': 3, '4': 1, '5': 8, '10': 'adaptiveBitrate'},
  ],
};

/// Descriptor for `CompressionSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List compressionSettingsDescriptor = $convert.base64Decode(
    'ChNDb21wcmVzc2lvblNldHRpbmdzEiEKDGJpdHJhdGVfa2JwcxgBIAEoDVILYml0cmF0ZUticH'
    'MSGAoHcXVhbGl0eRgCIAEoDVIHcXVhbGl0eRIpChBhZGFwdGl2ZV9iaXRyYXRlGAMgASgIUg9h'
    'ZGFwdGl2ZUJpdHJhdGU=');

@$core.Deprecated('Use frameRequestDescriptor instead')
const FrameRequest$json = {
  '1': 'FrameRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'last_frame_sequence',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'lastFrameSequence'
    },
    {
      '1': 'request_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.bridge_view.FrameRequestType',
      '10': 'requestType'
    },
  ],
};

/// Descriptor for `FrameRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List frameRequestDescriptor = $convert.base64Decode(
    'CgxGcmFtZVJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEi4KE2xhc3RfZn'
    'JhbWVfc2VxdWVuY2UYAiABKARSEWxhc3RGcmFtZVNlcXVlbmNlEkAKDHJlcXVlc3RfdHlwZRgD'
    'IAEoDjIdLmJyaWRnZV92aWV3LkZyYW1lUmVxdWVzdFR5cGVSC3JlcXVlc3RUeXBl');

@$core.Deprecated('Use videoFrameDescriptor instead')
const VideoFrame$json = {
  '1': 'VideoFrame',
  '2': [
    {'1': 'sequence_number', '3': 1, '4': 1, '5': 4, '10': 'sequenceNumber'},
    {'1': 'timestamp_us', '3': 2, '4': 1, '5': 4, '10': 'timestampUs'},
    {'1': 'frame_data', '3': 3, '4': 1, '5': 12, '10': 'frameData'},
    {
      '1': 'frame_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.bridge_view.FrameType',
      '10': 'frameType'
    },
    {'1': 'width', '3': 5, '4': 1, '5': 13, '10': 'width'},
    {'1': 'height', '3': 6, '4': 1, '5': 13, '10': 'height'},
  ],
};

/// Descriptor for `VideoFrame`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List videoFrameDescriptor = $convert.base64Decode(
    'CgpWaWRlb0ZyYW1lEicKD3NlcXVlbmNlX251bWJlchgBIAEoBFIOc2VxdWVuY2VOdW1iZXISIQ'
    'oMdGltZXN0YW1wX3VzGAIgASgEUgt0aW1lc3RhbXBVcxIdCgpmcmFtZV9kYXRhGAMgASgMUglm'
    'cmFtZURhdGESNQoKZnJhbWVfdHlwZRgEIAEoDjIWLmJyaWRnZV92aWV3LkZyYW1lVHlwZVIJZn'
    'JhbWVUeXBlEhQKBXdpZHRoGAUgASgNUgV3aWR0aBIWCgZoZWlnaHQYBiABKA1SBmhlaWdodA==');

@$core.Deprecated('Use inputEventDescriptor instead')
const InputEvent$json = {
  '1': 'InputEvent',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'timestamp_us', '3': 2, '4': 1, '5': 4, '10': 'timestampUs'},
    {
      '1': 'mouse',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.bridge_view.MouseEvent',
      '9': 0,
      '10': 'mouse'
    },
    {
      '1': 'keyboard',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.bridge_view.KeyboardEvent',
      '9': 0,
      '10': 'keyboard'
    },
    {
      '1': 'touch',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.bridge_view.TouchEvent',
      '9': 0,
      '10': 'touch'
    },
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `InputEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputEventDescriptor = $convert.base64Decode(
    'CgpJbnB1dEV2ZW50Eh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZBIhCgx0aW1lc3RhbX'
    'BfdXMYAiABKARSC3RpbWVzdGFtcFVzEi8KBW1vdXNlGAMgASgLMhcuYnJpZGdlX3ZpZXcuTW91'
    'c2VFdmVudEgAUgVtb3VzZRI4CghrZXlib2FyZBgEIAEoCzIaLmJyaWRnZV92aWV3LktleWJvYX'
    'JkRXZlbnRIAFIIa2V5Ym9hcmQSLwoFdG91Y2gYBSABKAsyFy5icmlkZ2Vfdmlldy5Ub3VjaEV2'
    'ZW50SABSBXRvdWNoQgcKBWV2ZW50');

@$core.Deprecated('Use mouseEventDescriptor instead')
const MouseEvent$json = {
  '1': 'MouseEvent',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.bridge_view.MouseEventType',
      '10': 'type'
    },
    {'1': 'x', '3': 2, '4': 1, '5': 2, '10': 'x'},
    {'1': 'y', '3': 3, '4': 1, '5': 2, '10': 'y'},
    {
      '1': 'button',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.bridge_view.MouseButton',
      '10': 'button'
    },
    {'1': 'scroll_delta_x', '3': 5, '4': 1, '5': 5, '10': 'scrollDeltaX'},
    {'1': 'scroll_delta_y', '3': 6, '4': 1, '5': 5, '10': 'scrollDeltaY'},
    {
      '1': 'modifiers',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.bridge_view.KeyModifiers',
      '10': 'modifiers'
    },
  ],
};

/// Descriptor for `MouseEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mouseEventDescriptor = $convert.base64Decode(
    'CgpNb3VzZUV2ZW50Ei8KBHR5cGUYASABKA4yGy5icmlkZ2Vfdmlldy5Nb3VzZUV2ZW50VHlwZV'
    'IEdHlwZRIMCgF4GAIgASgCUgF4EgwKAXkYAyABKAJSAXkSMAoGYnV0dG9uGAQgASgOMhguYnJp'
    'ZGdlX3ZpZXcuTW91c2VCdXR0b25SBmJ1dHRvbhIkCg5zY3JvbGxfZGVsdGFfeBgFIAEoBVIMc2'
    'Nyb2xsRGVsdGFYEiQKDnNjcm9sbF9kZWx0YV95GAYgASgFUgxzY3JvbGxEZWx0YVkSNwoJbW9k'
    'aWZpZXJzGAcgASgLMhkuYnJpZGdlX3ZpZXcuS2V5TW9kaWZpZXJzUgltb2RpZmllcnM=');

@$core.Deprecated('Use keyboardEventDescriptor instead')
const KeyboardEvent$json = {
  '1': 'KeyboardEvent',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.bridge_view.KeyboardEventType',
      '10': 'type'
    },
    {'1': 'key_code', '3': 2, '4': 1, '5': 13, '10': 'keyCode'},
    {'1': 'key_char', '3': 3, '4': 1, '5': 9, '10': 'keyChar'},
    {
      '1': 'modifiers',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.bridge_view.KeyModifiers',
      '10': 'modifiers'
    },
  ],
};

/// Descriptor for `KeyboardEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyboardEventDescriptor = $convert.base64Decode(
    'Cg1LZXlib2FyZEV2ZW50EjIKBHR5cGUYASABKA4yHi5icmlkZ2Vfdmlldy5LZXlib2FyZEV2ZW'
    '50VHlwZVIEdHlwZRIZCghrZXlfY29kZRgCIAEoDVIHa2V5Q29kZRIZCghrZXlfY2hhchgDIAEo'
    'CVIHa2V5Q2hhchI3Cgltb2RpZmllcnMYBCABKAsyGS5icmlkZ2Vfdmlldy5LZXlNb2RpZmllcn'
    'NSCW1vZGlmaWVycw==');

@$core.Deprecated('Use keyModifiersDescriptor instead')
const KeyModifiers$json = {
  '1': 'KeyModifiers',
  '2': [
    {'1': 'shift', '3': 1, '4': 1, '5': 8, '10': 'shift'},
    {'1': 'ctrl', '3': 2, '4': 1, '5': 8, '10': 'ctrl'},
    {'1': 'alt', '3': 3, '4': 1, '5': 8, '10': 'alt'},
    {'1': 'meta', '3': 4, '4': 1, '5': 8, '10': 'meta'},
  ],
};

/// Descriptor for `KeyModifiers`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyModifiersDescriptor = $convert.base64Decode(
    'CgxLZXlNb2RpZmllcnMSFAoFc2hpZnQYASABKAhSBXNoaWZ0EhIKBGN0cmwYAiABKAhSBGN0cm'
    'wSEAoDYWx0GAMgASgIUgNhbHQSEgoEbWV0YRgEIAEoCFIEbWV0YQ==');

@$core.Deprecated('Use touchEventDescriptor instead')
const TouchEvent$json = {
  '1': 'TouchEvent',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.bridge_view.TouchEventType',
      '10': 'type'
    },
    {
      '1': 'touches',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.bridge_view.TouchPoint',
      '10': 'touches'
    },
  ],
};

/// Descriptor for `TouchEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List touchEventDescriptor = $convert.base64Decode(
    'CgpUb3VjaEV2ZW50Ei8KBHR5cGUYASABKA4yGy5icmlkZ2Vfdmlldy5Ub3VjaEV2ZW50VHlwZV'
    'IEdHlwZRIxCgd0b3VjaGVzGAIgAygLMhcuYnJpZGdlX3ZpZXcuVG91Y2hQb2ludFIHdG91Y2hl'
    'cw==');

@$core.Deprecated('Use touchPointDescriptor instead')
const TouchPoint$json = {
  '1': 'TouchPoint',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'x', '3': 2, '4': 1, '5': 2, '10': 'x'},
    {'1': 'y', '3': 3, '4': 1, '5': 2, '10': 'y'},
    {'1': 'pressure', '3': 4, '4': 1, '5': 2, '10': 'pressure'},
  ],
};

/// Descriptor for `TouchPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List touchPointDescriptor = $convert.base64Decode(
    'CgpUb3VjaFBvaW50Eg4KAmlkGAEgASgNUgJpZBIMCgF4GAIgASgCUgF4EgwKAXkYAyABKAJSAX'
    'kSGgoIcHJlc3N1cmUYBCABKAJSCHByZXNzdXJl');

@$core.Deprecated('Use inputResponseDescriptor instead')
const InputResponse$json = {
  '1': 'InputResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `InputResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputResponseDescriptor = $convert.base64Decode(
    'Cg1JbnB1dFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIwoNZXJyb3JfbWVzc2'
    'FnZRgCIAEoCVIMZXJyb3JNZXNzYWdl');

@$core.Deprecated('Use controlMessageDescriptor instead')
const ControlMessage$json = {
  '1': 'ControlMessage',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.bridge_view.ControlMessageType',
      '10': 'type'
    },
    {'1': 'payload', '3': 3, '4': 1, '5': 9, '10': 'payload'},
  ],
};

/// Descriptor for `ControlMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List controlMessageDescriptor = $convert.base64Decode(
    'Cg5Db250cm9sTWVzc2FnZRIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSMwoEdHlwZR'
    'gCIAEoDjIfLmJyaWRnZV92aWV3LkNvbnRyb2xNZXNzYWdlVHlwZVIEdHlwZRIYCgdwYXlsb2Fk'
    'GAMgASgJUgdwYXlsb2Fk');

@$core.Deprecated('Use controlResponseDescriptor instead')
const ControlResponse$json = {
  '1': 'ControlResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'timestamp_us', '3': 3, '4': 1, '5': 4, '10': 'timestampUs'},
  ],
};

/// Descriptor for `ControlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List controlResponseDescriptor = $convert.base64Decode(
    'Cg9Db250cm9sUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGA'
    'IgASgJUgdtZXNzYWdlEiEKDHRpbWVzdGFtcF91cxgDIAEoBFILdGltZXN0YW1wVXM=');

const $core.Map<$core.String, $core.dynamic> DisplayServiceBase$json = {
  '1': 'DisplayService',
  '2': [
    {
      '1': 'RegisterClient',
      '2': '.bridge_view.ClientRegistration',
      '3': '.bridge_view.DisplayConfig'
    },
    {
      '1': 'StreamFrames',
      '2': '.bridge_view.FrameRequest',
      '3': '.bridge_view.VideoFrame',
      '5': true,
      '6': true
    },
    {
      '1': 'SendInput',
      '2': '.bridge_view.InputEvent',
      '3': '.bridge_view.InputResponse',
      '5': true,
      '6': true
    },
    {
      '1': 'SendControl',
      '2': '.bridge_view.ControlMessage',
      '3': '.bridge_view.ControlResponse'
    },
  ],
};

@$core.Deprecated('Use displayServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    DisplayServiceBase$messageJson = {
  '.bridge_view.ClientRegistration': ClientRegistration$json,
  '.bridge_view.ClientCapabilities': ClientCapabilities$json,
  '.bridge_view.DisplayConfig': DisplayConfig$json,
  '.bridge_view.DisplayPosition': DisplayPosition$json,
  '.bridge_view.CompressionSettings': CompressionSettings$json,
  '.bridge_view.FrameRequest': FrameRequest$json,
  '.bridge_view.VideoFrame': VideoFrame$json,
  '.bridge_view.InputEvent': InputEvent$json,
  '.bridge_view.MouseEvent': MouseEvent$json,
  '.bridge_view.KeyModifiers': KeyModifiers$json,
  '.bridge_view.KeyboardEvent': KeyboardEvent$json,
  '.bridge_view.TouchEvent': TouchEvent$json,
  '.bridge_view.TouchPoint': TouchPoint$json,
  '.bridge_view.InputResponse': InputResponse$json,
  '.bridge_view.ControlMessage': ControlMessage$json,
  '.bridge_view.ControlResponse': ControlResponse$json,
};

/// Descriptor for `DisplayService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List displayServiceDescriptor = $convert.base64Decode(
    'Cg5EaXNwbGF5U2VydmljZRJNCg5SZWdpc3RlckNsaWVudBIfLmJyaWRnZV92aWV3LkNsaWVudF'
    'JlZ2lzdHJhdGlvbhoaLmJyaWRnZV92aWV3LkRpc3BsYXlDb25maWcSRgoMU3RyZWFtRnJhbWVz'
    'EhkuYnJpZGdlX3ZpZXcuRnJhbWVSZXF1ZXN0GhcuYnJpZGdlX3ZpZXcuVmlkZW9GcmFtZSgBMA'
    'ESRAoJU2VuZElucHV0EhcuYnJpZGdlX3ZpZXcuSW5wdXRFdmVudBoaLmJyaWRnZV92aWV3Lklu'
    'cHV0UmVzcG9uc2UoATABEkgKC1NlbmRDb250cm9sEhsuYnJpZGdlX3ZpZXcuQ29udHJvbE1lc3'
    'NhZ2UaHC5icmlkZ2Vfdmlldy5Db250cm9sUmVzcG9uc2U=');
