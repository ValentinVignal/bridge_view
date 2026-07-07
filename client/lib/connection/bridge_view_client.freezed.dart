// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bridge_view_client.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BridgeViewClientState implements DiagnosticableTreeMixin {

 ConnectionStatus get status; String? get sessionId; DisplayConfig? get displayConfig; String? get errorMessage; int get reconnectAttempts; int get framesReceived; String get webSocketUrl;
/// Create a copy of BridgeViewClientState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeViewClientStateCopyWith<BridgeViewClientState> get copyWith => _$BridgeViewClientStateCopyWithImpl<BridgeViewClientState>(this as BridgeViewClientState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'BridgeViewClientState'))
    ..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('sessionId', sessionId))..add(DiagnosticsProperty('displayConfig', displayConfig))..add(DiagnosticsProperty('errorMessage', errorMessage))..add(DiagnosticsProperty('reconnectAttempts', reconnectAttempts))..add(DiagnosticsProperty('framesReceived', framesReceived))..add(DiagnosticsProperty('webSocketUrl', webSocketUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeViewClientState&&(identical(other.status, status) || other.status == status)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.displayConfig, displayConfig) || other.displayConfig == displayConfig)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.reconnectAttempts, reconnectAttempts) || other.reconnectAttempts == reconnectAttempts)&&(identical(other.framesReceived, framesReceived) || other.framesReceived == framesReceived)&&(identical(other.webSocketUrl, webSocketUrl) || other.webSocketUrl == webSocketUrl));
}


@override
int get hashCode => Object.hash(runtimeType,status,sessionId,displayConfig,errorMessage,reconnectAttempts,framesReceived,webSocketUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'BridgeViewClientState(status: $status, sessionId: $sessionId, displayConfig: $displayConfig, errorMessage: $errorMessage, reconnectAttempts: $reconnectAttempts, framesReceived: $framesReceived, webSocketUrl: $webSocketUrl)';
}


}

/// @nodoc
abstract mixin class $BridgeViewClientStateCopyWith<$Res>  {
  factory $BridgeViewClientStateCopyWith(BridgeViewClientState value, $Res Function(BridgeViewClientState) _then) = _$BridgeViewClientStateCopyWithImpl;
@useResult
$Res call({
 ConnectionStatus status, String? sessionId, DisplayConfig? displayConfig, String? errorMessage, int reconnectAttempts, int framesReceived, String webSocketUrl
});




}
/// @nodoc
class _$BridgeViewClientStateCopyWithImpl<$Res>
    implements $BridgeViewClientStateCopyWith<$Res> {
  _$BridgeViewClientStateCopyWithImpl(this._self, this._then);

  final BridgeViewClientState _self;
  final $Res Function(BridgeViewClientState) _then;

/// Create a copy of BridgeViewClientState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? sessionId = freezed,Object? displayConfig = freezed,Object? errorMessage = freezed,Object? reconnectAttempts = null,Object? framesReceived = null,Object? webSocketUrl = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,displayConfig: freezed == displayConfig ? _self.displayConfig : displayConfig // ignore: cast_nullable_to_non_nullable
as DisplayConfig?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,reconnectAttempts: null == reconnectAttempts ? _self.reconnectAttempts : reconnectAttempts // ignore: cast_nullable_to_non_nullable
as int,framesReceived: null == framesReceived ? _self.framesReceived : framesReceived // ignore: cast_nullable_to_non_nullable
as int,webSocketUrl: null == webSocketUrl ? _self.webSocketUrl : webSocketUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BridgeViewClientState].
extension BridgeViewClientStatePatterns on BridgeViewClientState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BridgeViewClientState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BridgeViewClientState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BridgeViewClientState value)  $default,){
final _that = this;
switch (_that) {
case _BridgeViewClientState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BridgeViewClientState value)?  $default,){
final _that = this;
switch (_that) {
case _BridgeViewClientState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConnectionStatus status,  String? sessionId,  DisplayConfig? displayConfig,  String? errorMessage,  int reconnectAttempts,  int framesReceived,  String webSocketUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BridgeViewClientState() when $default != null:
return $default(_that.status,_that.sessionId,_that.displayConfig,_that.errorMessage,_that.reconnectAttempts,_that.framesReceived,_that.webSocketUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConnectionStatus status,  String? sessionId,  DisplayConfig? displayConfig,  String? errorMessage,  int reconnectAttempts,  int framesReceived,  String webSocketUrl)  $default,) {final _that = this;
switch (_that) {
case _BridgeViewClientState():
return $default(_that.status,_that.sessionId,_that.displayConfig,_that.errorMessage,_that.reconnectAttempts,_that.framesReceived,_that.webSocketUrl);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConnectionStatus status,  String? sessionId,  DisplayConfig? displayConfig,  String? errorMessage,  int reconnectAttempts,  int framesReceived,  String webSocketUrl)?  $default,) {final _that = this;
switch (_that) {
case _BridgeViewClientState() when $default != null:
return $default(_that.status,_that.sessionId,_that.displayConfig,_that.errorMessage,_that.reconnectAttempts,_that.framesReceived,_that.webSocketUrl);case _:
  return null;

}
}

}

/// @nodoc


class _BridgeViewClientState with DiagnosticableTreeMixin implements BridgeViewClientState {
  const _BridgeViewClientState({required this.status, this.sessionId, this.displayConfig, this.errorMessage, required this.reconnectAttempts, required this.framesReceived, required this.webSocketUrl});
  

@override final  ConnectionStatus status;
@override final  String? sessionId;
@override final  DisplayConfig? displayConfig;
@override final  String? errorMessage;
@override final  int reconnectAttempts;
@override final  int framesReceived;
@override final  String webSocketUrl;

/// Create a copy of BridgeViewClientState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BridgeViewClientStateCopyWith<_BridgeViewClientState> get copyWith => __$BridgeViewClientStateCopyWithImpl<_BridgeViewClientState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'BridgeViewClientState'))
    ..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('sessionId', sessionId))..add(DiagnosticsProperty('displayConfig', displayConfig))..add(DiagnosticsProperty('errorMessage', errorMessage))..add(DiagnosticsProperty('reconnectAttempts', reconnectAttempts))..add(DiagnosticsProperty('framesReceived', framesReceived))..add(DiagnosticsProperty('webSocketUrl', webSocketUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BridgeViewClientState&&(identical(other.status, status) || other.status == status)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.displayConfig, displayConfig) || other.displayConfig == displayConfig)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.reconnectAttempts, reconnectAttempts) || other.reconnectAttempts == reconnectAttempts)&&(identical(other.framesReceived, framesReceived) || other.framesReceived == framesReceived)&&(identical(other.webSocketUrl, webSocketUrl) || other.webSocketUrl == webSocketUrl));
}


@override
int get hashCode => Object.hash(runtimeType,status,sessionId,displayConfig,errorMessage,reconnectAttempts,framesReceived,webSocketUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'BridgeViewClientState(status: $status, sessionId: $sessionId, displayConfig: $displayConfig, errorMessage: $errorMessage, reconnectAttempts: $reconnectAttempts, framesReceived: $framesReceived, webSocketUrl: $webSocketUrl)';
}


}

/// @nodoc
abstract mixin class _$BridgeViewClientStateCopyWith<$Res> implements $BridgeViewClientStateCopyWith<$Res> {
  factory _$BridgeViewClientStateCopyWith(_BridgeViewClientState value, $Res Function(_BridgeViewClientState) _then) = __$BridgeViewClientStateCopyWithImpl;
@override @useResult
$Res call({
 ConnectionStatus status, String? sessionId, DisplayConfig? displayConfig, String? errorMessage, int reconnectAttempts, int framesReceived, String webSocketUrl
});




}
/// @nodoc
class __$BridgeViewClientStateCopyWithImpl<$Res>
    implements _$BridgeViewClientStateCopyWith<$Res> {
  __$BridgeViewClientStateCopyWithImpl(this._self, this._then);

  final _BridgeViewClientState _self;
  final $Res Function(_BridgeViewClientState) _then;

/// Create a copy of BridgeViewClientState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? sessionId = freezed,Object? displayConfig = freezed,Object? errorMessage = freezed,Object? reconnectAttempts = null,Object? framesReceived = null,Object? webSocketUrl = null,}) {
  return _then(_BridgeViewClientState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,displayConfig: freezed == displayConfig ? _self.displayConfig : displayConfig // ignore: cast_nullable_to_non_nullable
as DisplayConfig?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,reconnectAttempts: null == reconnectAttempts ? _self.reconnectAttempts : reconnectAttempts // ignore: cast_nullable_to_non_nullable
as int,framesReceived: null == framesReceived ? _self.framesReceived : framesReceived // ignore: cast_nullable_to_non_nullable
as int,webSocketUrl: null == webSocketUrl ? _self.webSocketUrl : webSocketUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
