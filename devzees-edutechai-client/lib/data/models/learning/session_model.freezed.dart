// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionModel {

@JsonKey(name: 'session_id') String get sessionId; String get topic;@JsonKey(name: 'learning_mode') String get learningMode;@JsonKey(name: 'student_level') String get studentLevel;@JsonKey(name: 'is_complete') bool get isComplete;@JsonKey(name: 'completed_steps') int get stepsCompleted;@JsonKey(name: 'xp_earned') int get xpEarned;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionModelCopyWith<SessionModel> get copyWith => _$SessionModelCopyWithImpl<SessionModel>(this as SessionModel, _$identity);

  /// Serializes this SessionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionModel&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.learningMode, learningMode) || other.learningMode == learningMode)&&(identical(other.studentLevel, studentLevel) || other.studentLevel == studentLevel)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.stepsCompleted, stepsCompleted) || other.stepsCompleted == stepsCompleted)&&(identical(other.xpEarned, xpEarned) || other.xpEarned == xpEarned)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,topic,learningMode,studentLevel,isComplete,stepsCompleted,xpEarned,createdAt,updatedAt);

@override
String toString() {
  return 'SessionModel(sessionId: $sessionId, topic: $topic, learningMode: $learningMode, studentLevel: $studentLevel, isComplete: $isComplete, stepsCompleted: $stepsCompleted, xpEarned: $xpEarned, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SessionModelCopyWith<$Res>  {
  factory $SessionModelCopyWith(SessionModel value, $Res Function(SessionModel) _then) = _$SessionModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId, String topic,@JsonKey(name: 'learning_mode') String learningMode,@JsonKey(name: 'student_level') String studentLevel,@JsonKey(name: 'is_complete') bool isComplete,@JsonKey(name: 'completed_steps') int stepsCompleted,@JsonKey(name: 'xp_earned') int xpEarned,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$SessionModelCopyWithImpl<$Res>
    implements $SessionModelCopyWith<$Res> {
  _$SessionModelCopyWithImpl(this._self, this._then);

  final SessionModel _self;
  final $Res Function(SessionModel) _then;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? topic = null,Object? learningMode = null,Object? studentLevel = null,Object? isComplete = null,Object? stepsCompleted = null,Object? xpEarned = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,learningMode: null == learningMode ? _self.learningMode : learningMode // ignore: cast_nullable_to_non_nullable
as String,studentLevel: null == studentLevel ? _self.studentLevel : studentLevel // ignore: cast_nullable_to_non_nullable
as String,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,stepsCompleted: null == stepsCompleted ? _self.stepsCompleted : stepsCompleted // ignore: cast_nullable_to_non_nullable
as int,xpEarned: null == xpEarned ? _self.xpEarned : xpEarned // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionModel].
extension SessionModelPatterns on SessionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionModel value)  $default,){
final _that = this;
switch (_that) {
case _SessionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId,  String topic, @JsonKey(name: 'learning_mode')  String learningMode, @JsonKey(name: 'student_level')  String studentLevel, @JsonKey(name: 'is_complete')  bool isComplete, @JsonKey(name: 'completed_steps')  int stepsCompleted, @JsonKey(name: 'xp_earned')  int xpEarned, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that.sessionId,_that.topic,_that.learningMode,_that.studentLevel,_that.isComplete,_that.stepsCompleted,_that.xpEarned,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId,  String topic, @JsonKey(name: 'learning_mode')  String learningMode, @JsonKey(name: 'student_level')  String studentLevel, @JsonKey(name: 'is_complete')  bool isComplete, @JsonKey(name: 'completed_steps')  int stepsCompleted, @JsonKey(name: 'xp_earned')  int xpEarned, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SessionModel():
return $default(_that.sessionId,_that.topic,_that.learningMode,_that.studentLevel,_that.isComplete,_that.stepsCompleted,_that.xpEarned,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_id')  String sessionId,  String topic, @JsonKey(name: 'learning_mode')  String learningMode, @JsonKey(name: 'student_level')  String studentLevel, @JsonKey(name: 'is_complete')  bool isComplete, @JsonKey(name: 'completed_steps')  int stepsCompleted, @JsonKey(name: 'xp_earned')  int xpEarned, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that.sessionId,_that.topic,_that.learningMode,_that.studentLevel,_that.isComplete,_that.stepsCompleted,_that.xpEarned,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionModel implements SessionModel {
  const _SessionModel({@JsonKey(name: 'session_id') required this.sessionId, required this.topic, @JsonKey(name: 'learning_mode') required this.learningMode, @JsonKey(name: 'student_level') required this.studentLevel, @JsonKey(name: 'is_complete') required this.isComplete, @JsonKey(name: 'completed_steps') required this.stepsCompleted, @JsonKey(name: 'xp_earned') required this.xpEarned, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);

@override@JsonKey(name: 'session_id') final  String sessionId;
@override final  String topic;
@override@JsonKey(name: 'learning_mode') final  String learningMode;
@override@JsonKey(name: 'student_level') final  String studentLevel;
@override@JsonKey(name: 'is_complete') final  bool isComplete;
@override@JsonKey(name: 'completed_steps') final  int stepsCompleted;
@override@JsonKey(name: 'xp_earned') final  int xpEarned;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionModelCopyWith<_SessionModel> get copyWith => __$SessionModelCopyWithImpl<_SessionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionModel&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.learningMode, learningMode) || other.learningMode == learningMode)&&(identical(other.studentLevel, studentLevel) || other.studentLevel == studentLevel)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.stepsCompleted, stepsCompleted) || other.stepsCompleted == stepsCompleted)&&(identical(other.xpEarned, xpEarned) || other.xpEarned == xpEarned)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,topic,learningMode,studentLevel,isComplete,stepsCompleted,xpEarned,createdAt,updatedAt);

@override
String toString() {
  return 'SessionModel(sessionId: $sessionId, topic: $topic, learningMode: $learningMode, studentLevel: $studentLevel, isComplete: $isComplete, stepsCompleted: $stepsCompleted, xpEarned: $xpEarned, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SessionModelCopyWith<$Res> implements $SessionModelCopyWith<$Res> {
  factory _$SessionModelCopyWith(_SessionModel value, $Res Function(_SessionModel) _then) = __$SessionModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId, String topic,@JsonKey(name: 'learning_mode') String learningMode,@JsonKey(name: 'student_level') String studentLevel,@JsonKey(name: 'is_complete') bool isComplete,@JsonKey(name: 'completed_steps') int stepsCompleted,@JsonKey(name: 'xp_earned') int xpEarned,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$SessionModelCopyWithImpl<$Res>
    implements _$SessionModelCopyWith<$Res> {
  __$SessionModelCopyWithImpl(this._self, this._then);

  final _SessionModel _self;
  final $Res Function(_SessionModel) _then;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? topic = null,Object? learningMode = null,Object? studentLevel = null,Object? isComplete = null,Object? stepsCompleted = null,Object? xpEarned = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_SessionModel(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,learningMode: null == learningMode ? _self.learningMode : learningMode // ignore: cast_nullable_to_non_nullable
as String,studentLevel: null == studentLevel ? _self.studentLevel : studentLevel // ignore: cast_nullable_to_non_nullable
as String,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,stepsCompleted: null == stepsCompleted ? _self.stepsCompleted : stepsCompleted // ignore: cast_nullable_to_non_nullable
as int,xpEarned: null == xpEarned ? _self.xpEarned : xpEarned // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PaginatedSessionResponse {

 List<SessionModel> get items; int get total; int get page; int get size;
/// Create a copy of PaginatedSessionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedSessionResponseCopyWith<PaginatedSessionResponse> get copyWith => _$PaginatedSessionResponseCopyWithImpl<PaginatedSessionResponse>(this as PaginatedSessionResponse, _$identity);

  /// Serializes this PaginatedSessionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedSessionResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page,size);

@override
String toString() {
  return 'PaginatedSessionResponse(items: $items, total: $total, page: $page, size: $size)';
}


}

/// @nodoc
abstract mixin class $PaginatedSessionResponseCopyWith<$Res>  {
  factory $PaginatedSessionResponseCopyWith(PaginatedSessionResponse value, $Res Function(PaginatedSessionResponse) _then) = _$PaginatedSessionResponseCopyWithImpl;
@useResult
$Res call({
 List<SessionModel> items, int total, int page, int size
});




}
/// @nodoc
class _$PaginatedSessionResponseCopyWithImpl<$Res>
    implements $PaginatedSessionResponseCopyWith<$Res> {
  _$PaginatedSessionResponseCopyWithImpl(this._self, this._then);

  final PaginatedSessionResponse _self;
  final $Res Function(PaginatedSessionResponse) _then;

/// Create a copy of PaginatedSessionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? size = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SessionModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedSessionResponse].
extension PaginatedSessionResponsePatterns on PaginatedSessionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedSessionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedSessionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedSessionResponse value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedSessionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedSessionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedSessionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SessionModel> items,  int total,  int page,  int size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedSessionResponse() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SessionModel> items,  int total,  int page,  int size)  $default,) {final _that = this;
switch (_that) {
case _PaginatedSessionResponse():
return $default(_that.items,_that.total,_that.page,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SessionModel> items,  int total,  int page,  int size)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedSessionResponse() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedSessionResponse implements PaginatedSessionResponse {
  const _PaginatedSessionResponse({required final  List<SessionModel> items, required this.total, required this.page, required this.size}): _items = items;
  factory _PaginatedSessionResponse.fromJson(Map<String, dynamic> json) => _$PaginatedSessionResponseFromJson(json);

 final  List<SessionModel> _items;
@override List<SessionModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  int page;
@override final  int size;

/// Create a copy of PaginatedSessionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedSessionResponseCopyWith<_PaginatedSessionResponse> get copyWith => __$PaginatedSessionResponseCopyWithImpl<_PaginatedSessionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedSessionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedSessionResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,size);

@override
String toString() {
  return 'PaginatedSessionResponse(items: $items, total: $total, page: $page, size: $size)';
}


}

/// @nodoc
abstract mixin class _$PaginatedSessionResponseCopyWith<$Res> implements $PaginatedSessionResponseCopyWith<$Res> {
  factory _$PaginatedSessionResponseCopyWith(_PaginatedSessionResponse value, $Res Function(_PaginatedSessionResponse) _then) = __$PaginatedSessionResponseCopyWithImpl;
@override @useResult
$Res call({
 List<SessionModel> items, int total, int page, int size
});




}
/// @nodoc
class __$PaginatedSessionResponseCopyWithImpl<$Res>
    implements _$PaginatedSessionResponseCopyWith<$Res> {
  __$PaginatedSessionResponseCopyWithImpl(this._self, this._then);

  final _PaginatedSessionResponse _self;
  final $Res Function(_PaginatedSessionResponse) _then;

/// Create a copy of PaginatedSessionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? size = null,}) {
  return _then(_PaginatedSessionResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SessionModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
