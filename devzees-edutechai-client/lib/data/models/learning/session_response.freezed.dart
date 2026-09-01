// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionResponse {

@JsonKey(name: 'session_id') String get sessionId; String get topic;@JsonKey(name: 'learning_mode') String get learningMode;@JsonKey(name: 'student_level') String get studentLevel;@JsonKey(name: 'created_at') DateTime get createdAt; List<MilestoneStep> get steps;@JsonKey(name: 'current_step_index') int get currentStepIndex;@JsonKey(name: 'xp_earned') int get xpEarned;@JsonKey(name: 'steps_completed') int get stepsCompleted;
/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionResponseCopyWith<SessionResponse> get copyWith => _$SessionResponseCopyWithImpl<SessionResponse>(this as SessionResponse, _$identity);

  /// Serializes this SessionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionResponse&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.learningMode, learningMode) || other.learningMode == learningMode)&&(identical(other.studentLevel, studentLevel) || other.studentLevel == studentLevel)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.steps, steps)&&(identical(other.currentStepIndex, currentStepIndex) || other.currentStepIndex == currentStepIndex)&&(identical(other.xpEarned, xpEarned) || other.xpEarned == xpEarned)&&(identical(other.stepsCompleted, stepsCompleted) || other.stepsCompleted == stepsCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,topic,learningMode,studentLevel,createdAt,const DeepCollectionEquality().hash(steps),currentStepIndex,xpEarned,stepsCompleted);

@override
String toString() {
  return 'SessionResponse(sessionId: $sessionId, topic: $topic, learningMode: $learningMode, studentLevel: $studentLevel, createdAt: $createdAt, steps: $steps, currentStepIndex: $currentStepIndex, xpEarned: $xpEarned, stepsCompleted: $stepsCompleted)';
}


}

/// @nodoc
abstract mixin class $SessionResponseCopyWith<$Res>  {
  factory $SessionResponseCopyWith(SessionResponse value, $Res Function(SessionResponse) _then) = _$SessionResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId, String topic,@JsonKey(name: 'learning_mode') String learningMode,@JsonKey(name: 'student_level') String studentLevel,@JsonKey(name: 'created_at') DateTime createdAt, List<MilestoneStep> steps,@JsonKey(name: 'current_step_index') int currentStepIndex,@JsonKey(name: 'xp_earned') int xpEarned,@JsonKey(name: 'steps_completed') int stepsCompleted
});




}
/// @nodoc
class _$SessionResponseCopyWithImpl<$Res>
    implements $SessionResponseCopyWith<$Res> {
  _$SessionResponseCopyWithImpl(this._self, this._then);

  final SessionResponse _self;
  final $Res Function(SessionResponse) _then;

/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? topic = null,Object? learningMode = null,Object? studentLevel = null,Object? createdAt = null,Object? steps = null,Object? currentStepIndex = null,Object? xpEarned = null,Object? stepsCompleted = null,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,learningMode: null == learningMode ? _self.learningMode : learningMode // ignore: cast_nullable_to_non_nullable
as String,studentLevel: null == studentLevel ? _self.studentLevel : studentLevel // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<MilestoneStep>,currentStepIndex: null == currentStepIndex ? _self.currentStepIndex : currentStepIndex // ignore: cast_nullable_to_non_nullable
as int,xpEarned: null == xpEarned ? _self.xpEarned : xpEarned // ignore: cast_nullable_to_non_nullable
as int,stepsCompleted: null == stepsCompleted ? _self.stepsCompleted : stepsCompleted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionResponse].
extension SessionResponsePatterns on SessionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionResponse value)  $default,){
final _that = this;
switch (_that) {
case _SessionResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId,  String topic, @JsonKey(name: 'learning_mode')  String learningMode, @JsonKey(name: 'student_level')  String studentLevel, @JsonKey(name: 'created_at')  DateTime createdAt,  List<MilestoneStep> steps, @JsonKey(name: 'current_step_index')  int currentStepIndex, @JsonKey(name: 'xp_earned')  int xpEarned, @JsonKey(name: 'steps_completed')  int stepsCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
return $default(_that.sessionId,_that.topic,_that.learningMode,_that.studentLevel,_that.createdAt,_that.steps,_that.currentStepIndex,_that.xpEarned,_that.stepsCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId,  String topic, @JsonKey(name: 'learning_mode')  String learningMode, @JsonKey(name: 'student_level')  String studentLevel, @JsonKey(name: 'created_at')  DateTime createdAt,  List<MilestoneStep> steps, @JsonKey(name: 'current_step_index')  int currentStepIndex, @JsonKey(name: 'xp_earned')  int xpEarned, @JsonKey(name: 'steps_completed')  int stepsCompleted)  $default,) {final _that = this;
switch (_that) {
case _SessionResponse():
return $default(_that.sessionId,_that.topic,_that.learningMode,_that.studentLevel,_that.createdAt,_that.steps,_that.currentStepIndex,_that.xpEarned,_that.stepsCompleted);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_id')  String sessionId,  String topic, @JsonKey(name: 'learning_mode')  String learningMode, @JsonKey(name: 'student_level')  String studentLevel, @JsonKey(name: 'created_at')  DateTime createdAt,  List<MilestoneStep> steps, @JsonKey(name: 'current_step_index')  int currentStepIndex, @JsonKey(name: 'xp_earned')  int xpEarned, @JsonKey(name: 'steps_completed')  int stepsCompleted)?  $default,) {final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
return $default(_that.sessionId,_that.topic,_that.learningMode,_that.studentLevel,_that.createdAt,_that.steps,_that.currentStepIndex,_that.xpEarned,_that.stepsCompleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionResponse implements SessionResponse {
  const _SessionResponse({@JsonKey(name: 'session_id') required this.sessionId, required this.topic, @JsonKey(name: 'learning_mode') required this.learningMode, @JsonKey(name: 'student_level') required this.studentLevel, @JsonKey(name: 'created_at') required this.createdAt, final  List<MilestoneStep> steps = const [], @JsonKey(name: 'current_step_index') this.currentStepIndex = 0, @JsonKey(name: 'xp_earned') this.xpEarned = 0, @JsonKey(name: 'steps_completed') this.stepsCompleted = 0}): _steps = steps;
  factory _SessionResponse.fromJson(Map<String, dynamic> json) => _$SessionResponseFromJson(json);

@override@JsonKey(name: 'session_id') final  String sessionId;
@override final  String topic;
@override@JsonKey(name: 'learning_mode') final  String learningMode;
@override@JsonKey(name: 'student_level') final  String studentLevel;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
 final  List<MilestoneStep> _steps;
@override@JsonKey() List<MilestoneStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

@override@JsonKey(name: 'current_step_index') final  int currentStepIndex;
@override@JsonKey(name: 'xp_earned') final  int xpEarned;
@override@JsonKey(name: 'steps_completed') final  int stepsCompleted;

/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionResponseCopyWith<_SessionResponse> get copyWith => __$SessionResponseCopyWithImpl<_SessionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionResponse&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.learningMode, learningMode) || other.learningMode == learningMode)&&(identical(other.studentLevel, studentLevel) || other.studentLevel == studentLevel)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._steps, _steps)&&(identical(other.currentStepIndex, currentStepIndex) || other.currentStepIndex == currentStepIndex)&&(identical(other.xpEarned, xpEarned) || other.xpEarned == xpEarned)&&(identical(other.stepsCompleted, stepsCompleted) || other.stepsCompleted == stepsCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,topic,learningMode,studentLevel,createdAt,const DeepCollectionEquality().hash(_steps),currentStepIndex,xpEarned,stepsCompleted);

@override
String toString() {
  return 'SessionResponse(sessionId: $sessionId, topic: $topic, learningMode: $learningMode, studentLevel: $studentLevel, createdAt: $createdAt, steps: $steps, currentStepIndex: $currentStepIndex, xpEarned: $xpEarned, stepsCompleted: $stepsCompleted)';
}


}

/// @nodoc
abstract mixin class _$SessionResponseCopyWith<$Res> implements $SessionResponseCopyWith<$Res> {
  factory _$SessionResponseCopyWith(_SessionResponse value, $Res Function(_SessionResponse) _then) = __$SessionResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId, String topic,@JsonKey(name: 'learning_mode') String learningMode,@JsonKey(name: 'student_level') String studentLevel,@JsonKey(name: 'created_at') DateTime createdAt, List<MilestoneStep> steps,@JsonKey(name: 'current_step_index') int currentStepIndex,@JsonKey(name: 'xp_earned') int xpEarned,@JsonKey(name: 'steps_completed') int stepsCompleted
});




}
/// @nodoc
class __$SessionResponseCopyWithImpl<$Res>
    implements _$SessionResponseCopyWith<$Res> {
  __$SessionResponseCopyWithImpl(this._self, this._then);

  final _SessionResponse _self;
  final $Res Function(_SessionResponse) _then;

/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? topic = null,Object? learningMode = null,Object? studentLevel = null,Object? createdAt = null,Object? steps = null,Object? currentStepIndex = null,Object? xpEarned = null,Object? stepsCompleted = null,}) {
  return _then(_SessionResponse(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,learningMode: null == learningMode ? _self.learningMode : learningMode // ignore: cast_nullable_to_non_nullable
as String,studentLevel: null == studentLevel ? _self.studentLevel : studentLevel // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<MilestoneStep>,currentStepIndex: null == currentStepIndex ? _self.currentStepIndex : currentStepIndex // ignore: cast_nullable_to_non_nullable
as int,xpEarned: null == xpEarned ? _self.xpEarned : xpEarned // ignore: cast_nullable_to_non_nullable
as int,stepsCompleted: null == stepsCompleted ? _self.stepsCompleted : stepsCompleted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
