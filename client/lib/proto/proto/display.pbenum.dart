// This is a generated file - do not edit.
//
// Generated from proto/display.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Device type enumeration
class DeviceType extends $pb.ProtobufEnum {
  static const DeviceType DEVICE_TYPE_UNSPECIFIED =
      DeviceType._(0, _omitEnumNames ? '' : 'DEVICE_TYPE_UNSPECIFIED');
  static const DeviceType DEVICE_TYPE_ANDROID_PHONE =
      DeviceType._(1, _omitEnumNames ? '' : 'DEVICE_TYPE_ANDROID_PHONE');
  static const DeviceType DEVICE_TYPE_MACOS_LAPTOP =
      DeviceType._(2, _omitEnumNames ? '' : 'DEVICE_TYPE_MACOS_LAPTOP');
  static const DeviceType DEVICE_TYPE_IOS_PHONE =
      DeviceType._(3, _omitEnumNames ? '' : 'DEVICE_TYPE_IOS_PHONE');

  static const $core.List<DeviceType> values = <DeviceType>[
    DEVICE_TYPE_UNSPECIFIED,
    DEVICE_TYPE_ANDROID_PHONE,
    DEVICE_TYPE_MACOS_LAPTOP,
    DEVICE_TYPE_IOS_PHONE,
  ];

  static final $core.List<DeviceType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static DeviceType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DeviceType._(super.value, super.name);
}

/// Video codec enumeration
class VideoCodec extends $pb.ProtobufEnum {
  static const VideoCodec VIDEO_CODEC_UNSPECIFIED =
      VideoCodec._(0, _omitEnumNames ? '' : 'VIDEO_CODEC_UNSPECIFIED');
  static const VideoCodec VIDEO_CODEC_H264 =
      VideoCodec._(1, _omitEnumNames ? '' : 'VIDEO_CODEC_H264');
  static const VideoCodec VIDEO_CODEC_H265 =
      VideoCodec._(2, _omitEnumNames ? '' : 'VIDEO_CODEC_H265');
  static const VideoCodec VIDEO_CODEC_VP8 =
      VideoCodec._(3, _omitEnumNames ? '' : 'VIDEO_CODEC_VP8');
  static const VideoCodec VIDEO_CODEC_VP9 =
      VideoCodec._(4, _omitEnumNames ? '' : 'VIDEO_CODEC_VP9');

  static const $core.List<VideoCodec> values = <VideoCodec>[
    VIDEO_CODEC_UNSPECIFIED,
    VIDEO_CODEC_H264,
    VIDEO_CODEC_H265,
    VIDEO_CODEC_VP8,
    VIDEO_CODEC_VP9,
  ];

  static final $core.List<VideoCodec?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static VideoCodec? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const VideoCodec._(super.value, super.name);
}

/// Frame request type
class FrameRequestType extends $pb.ProtobufEnum {
  static const FrameRequestType FRAME_REQUEST_TYPE_UNSPECIFIED =
      FrameRequestType._(
          0, _omitEnumNames ? '' : 'FRAME_REQUEST_TYPE_UNSPECIFIED');
  static const FrameRequestType FRAME_REQUEST_TYPE_CONTINUE =
      FrameRequestType._(
          1, _omitEnumNames ? '' : 'FRAME_REQUEST_TYPE_CONTINUE');
  static const FrameRequestType FRAME_REQUEST_TYPE_KEYFRAME =
      FrameRequestType._(
          2, _omitEnumNames ? '' : 'FRAME_REQUEST_TYPE_KEYFRAME');
  static const FrameRequestType FRAME_REQUEST_TYPE_PAUSE =
      FrameRequestType._(3, _omitEnumNames ? '' : 'FRAME_REQUEST_TYPE_PAUSE');
  static const FrameRequestType FRAME_REQUEST_TYPE_RESUME =
      FrameRequestType._(4, _omitEnumNames ? '' : 'FRAME_REQUEST_TYPE_RESUME');

  static const $core.List<FrameRequestType> values = <FrameRequestType>[
    FRAME_REQUEST_TYPE_UNSPECIFIED,
    FRAME_REQUEST_TYPE_CONTINUE,
    FRAME_REQUEST_TYPE_KEYFRAME,
    FRAME_REQUEST_TYPE_PAUSE,
    FRAME_REQUEST_TYPE_RESUME,
  ];

  static final $core.List<FrameRequestType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static FrameRequestType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FrameRequestType._(super.value, super.name);
}

/// Frame type enumeration
class FrameType extends $pb.ProtobufEnum {
  static const FrameType FRAME_TYPE_UNSPECIFIED =
      FrameType._(0, _omitEnumNames ? '' : 'FRAME_TYPE_UNSPECIFIED');
  static const FrameType FRAME_TYPE_KEYFRAME =
      FrameType._(1, _omitEnumNames ? '' : 'FRAME_TYPE_KEYFRAME');
  static const FrameType FRAME_TYPE_DELTA =
      FrameType._(2, _omitEnumNames ? '' : 'FRAME_TYPE_DELTA');

  static const $core.List<FrameType> values = <FrameType>[
    FRAME_TYPE_UNSPECIFIED,
    FRAME_TYPE_KEYFRAME,
    FRAME_TYPE_DELTA,
  ];

  static final $core.List<FrameType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static FrameType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FrameType._(super.value, super.name);
}

/// Mouse event type
class MouseEventType extends $pb.ProtobufEnum {
  static const MouseEventType MOUSE_EVENT_TYPE_UNSPECIFIED =
      MouseEventType._(0, _omitEnumNames ? '' : 'MOUSE_EVENT_TYPE_UNSPECIFIED');
  static const MouseEventType MOUSE_EVENT_TYPE_MOVE =
      MouseEventType._(1, _omitEnumNames ? '' : 'MOUSE_EVENT_TYPE_MOVE');
  static const MouseEventType MOUSE_EVENT_TYPE_DOWN =
      MouseEventType._(2, _omitEnumNames ? '' : 'MOUSE_EVENT_TYPE_DOWN');
  static const MouseEventType MOUSE_EVENT_TYPE_UP =
      MouseEventType._(3, _omitEnumNames ? '' : 'MOUSE_EVENT_TYPE_UP');
  static const MouseEventType MOUSE_EVENT_TYPE_SCROLL =
      MouseEventType._(4, _omitEnumNames ? '' : 'MOUSE_EVENT_TYPE_SCROLL');
  static const MouseEventType MOUSE_EVENT_TYPE_DRAG =
      MouseEventType._(5, _omitEnumNames ? '' : 'MOUSE_EVENT_TYPE_DRAG');

  static const $core.List<MouseEventType> values = <MouseEventType>[
    MOUSE_EVENT_TYPE_UNSPECIFIED,
    MOUSE_EVENT_TYPE_MOVE,
    MOUSE_EVENT_TYPE_DOWN,
    MOUSE_EVENT_TYPE_UP,
    MOUSE_EVENT_TYPE_SCROLL,
    MOUSE_EVENT_TYPE_DRAG,
  ];

  static final $core.List<MouseEventType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static MouseEventType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MouseEventType._(super.value, super.name);
}

/// Mouse button
class MouseButton extends $pb.ProtobufEnum {
  static const MouseButton MOUSE_BUTTON_UNSPECIFIED =
      MouseButton._(0, _omitEnumNames ? '' : 'MOUSE_BUTTON_UNSPECIFIED');
  static const MouseButton MOUSE_BUTTON_LEFT =
      MouseButton._(1, _omitEnumNames ? '' : 'MOUSE_BUTTON_LEFT');
  static const MouseButton MOUSE_BUTTON_RIGHT =
      MouseButton._(2, _omitEnumNames ? '' : 'MOUSE_BUTTON_RIGHT');
  static const MouseButton MOUSE_BUTTON_MIDDLE =
      MouseButton._(3, _omitEnumNames ? '' : 'MOUSE_BUTTON_MIDDLE');

  static const $core.List<MouseButton> values = <MouseButton>[
    MOUSE_BUTTON_UNSPECIFIED,
    MOUSE_BUTTON_LEFT,
    MOUSE_BUTTON_RIGHT,
    MOUSE_BUTTON_MIDDLE,
  ];

  static final $core.List<MouseButton?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static MouseButton? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MouseButton._(super.value, super.name);
}

/// Keyboard event type
class KeyboardEventType extends $pb.ProtobufEnum {
  static const KeyboardEventType KEYBOARD_EVENT_TYPE_UNSPECIFIED =
      KeyboardEventType._(
          0, _omitEnumNames ? '' : 'KEYBOARD_EVENT_TYPE_UNSPECIFIED');
  static const KeyboardEventType KEYBOARD_EVENT_TYPE_DOWN =
      KeyboardEventType._(1, _omitEnumNames ? '' : 'KEYBOARD_EVENT_TYPE_DOWN');
  static const KeyboardEventType KEYBOARD_EVENT_TYPE_UP =
      KeyboardEventType._(2, _omitEnumNames ? '' : 'KEYBOARD_EVENT_TYPE_UP');
  static const KeyboardEventType KEYBOARD_EVENT_TYPE_PRESS =
      KeyboardEventType._(3, _omitEnumNames ? '' : 'KEYBOARD_EVENT_TYPE_PRESS');

  static const $core.List<KeyboardEventType> values = <KeyboardEventType>[
    KEYBOARD_EVENT_TYPE_UNSPECIFIED,
    KEYBOARD_EVENT_TYPE_DOWN,
    KEYBOARD_EVENT_TYPE_UP,
    KEYBOARD_EVENT_TYPE_PRESS,
  ];

  static final $core.List<KeyboardEventType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static KeyboardEventType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const KeyboardEventType._(super.value, super.name);
}

/// Touch event type
class TouchEventType extends $pb.ProtobufEnum {
  static const TouchEventType TOUCH_EVENT_TYPE_UNSPECIFIED =
      TouchEventType._(0, _omitEnumNames ? '' : 'TOUCH_EVENT_TYPE_UNSPECIFIED');
  static const TouchEventType TOUCH_EVENT_TYPE_DOWN =
      TouchEventType._(1, _omitEnumNames ? '' : 'TOUCH_EVENT_TYPE_DOWN');
  static const TouchEventType TOUCH_EVENT_TYPE_MOVE =
      TouchEventType._(2, _omitEnumNames ? '' : 'TOUCH_EVENT_TYPE_MOVE');
  static const TouchEventType TOUCH_EVENT_TYPE_UP =
      TouchEventType._(3, _omitEnumNames ? '' : 'TOUCH_EVENT_TYPE_UP');
  static const TouchEventType TOUCH_EVENT_TYPE_CANCEL =
      TouchEventType._(4, _omitEnumNames ? '' : 'TOUCH_EVENT_TYPE_CANCEL');

  static const $core.List<TouchEventType> values = <TouchEventType>[
    TOUCH_EVENT_TYPE_UNSPECIFIED,
    TOUCH_EVENT_TYPE_DOWN,
    TOUCH_EVENT_TYPE_MOVE,
    TOUCH_EVENT_TYPE_UP,
    TOUCH_EVENT_TYPE_CANCEL,
  ];

  static final $core.List<TouchEventType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static TouchEventType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TouchEventType._(super.value, super.name);
}

/// Control message type
class ControlMessageType extends $pb.ProtobufEnum {
  static const ControlMessageType CONTROL_MESSAGE_TYPE_UNSPECIFIED =
      ControlMessageType._(
          0, _omitEnumNames ? '' : 'CONTROL_MESSAGE_TYPE_UNSPECIFIED');
  static const ControlMessageType CONTROL_MESSAGE_TYPE_HEARTBEAT =
      ControlMessageType._(
          1, _omitEnumNames ? '' : 'CONTROL_MESSAGE_TYPE_HEARTBEAT');
  static const ControlMessageType CONTROL_MESSAGE_TYPE_DISCONNECT =
      ControlMessageType._(
          2, _omitEnumNames ? '' : 'CONTROL_MESSAGE_TYPE_DISCONNECT');
  static const ControlMessageType CONTROL_MESSAGE_TYPE_RECONFIGURE =
      ControlMessageType._(
          3, _omitEnumNames ? '' : 'CONTROL_MESSAGE_TYPE_RECONFIGURE');
  static const ControlMessageType CONTROL_MESSAGE_TYPE_ERROR =
      ControlMessageType._(
          4, _omitEnumNames ? '' : 'CONTROL_MESSAGE_TYPE_ERROR');

  static const $core.List<ControlMessageType> values = <ControlMessageType>[
    CONTROL_MESSAGE_TYPE_UNSPECIFIED,
    CONTROL_MESSAGE_TYPE_HEARTBEAT,
    CONTROL_MESSAGE_TYPE_DISCONNECT,
    CONTROL_MESSAGE_TYPE_RECONFIGURE,
    CONTROL_MESSAGE_TYPE_ERROR,
  ];

  static final $core.List<ControlMessageType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ControlMessageType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ControlMessageType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
