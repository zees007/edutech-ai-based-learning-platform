// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role_edit_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoleEditRequest {

 String? get name;@JsonKey(name: 'privilege_ids') List<int>? get privilegeIds;
/// Create a copy of RoleEditRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleEditRequestCopyWith<RoleEditRequest> get copyWith => _$RoleEditRequestCopyWithImpl<RoleEditRequest>(this as RoleEditRequest, _$identity);

  /// Serializes this RoleEditRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleEditRequest&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.privilegeIds, privilegeIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(privilegeIds));

@override
String toString() {
  return 'RoleEditRequest(name: $name, privilegeIds: $privilegeIds)';
}


}

/// @nodoc
abstract mixin class $RoleEditRequestCopyWith<$Res>  {
  factory $RoleEditRequestCopyWith(RoleEditRequest value, $Res Function(RoleEditRequest) _then) = _$RoleEditRequestCopyWithImpl;
@useResult
$Res call({
 String? name,@JsonKey(name: 'privilege_ids') List<int>? privilegeIds
});




}
/// @nodoc
class _$RoleEditRequestCopyWithImpl<$Res>
    implements $RoleEditRequestCopyWith<$Res> {
  _$RoleEditRequestCopyWithImpl(this._self, this._then);

  final RoleEditRequest _self;
  final $Res Function(RoleEditRequest) _then;

/// Create a copy of RoleEditRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? privilegeIds = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,privilegeIds: freezed == privilegeIds ? _self.privilegeIds : privilegeIds // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoleEditRequest].
extension RoleEditRequestPatterns on RoleEditRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoleEditRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoleEditRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoleEditRequest value)  $default,){
final _that = this;
switch (_that) {
case _RoleEditRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoleEditRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RoleEditRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name, @JsonKey(name: 'privilege_ids')  List<int>? privilegeIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoleEditRequest() when $default != null:
return $default(_that.name,_that.privilegeIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name, @JsonKey(name: 'privilege_ids')  List<int>? privilegeIds)  $default,) {final _that = this;
switch (_that) {
case _RoleEditRequest():
return $default(_that.name,_that.privilegeIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name, @JsonKey(name: 'privilege_ids')  List<int>? privilegeIds)?  $default,) {final _that = this;
switch (_that) {
case _RoleEditRequest() when $default != null:
return $default(_that.name,_that.privilegeIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoleEditRequest implements RoleEditRequest {
  const _RoleEditRequest({this.name, @JsonKey(name: 'privilege_ids') final  List<int>? privilegeIds}): _privilegeIds = privilegeIds;
  factory _RoleEditRequest.fromJson(Map<String, dynamic> json) => _$RoleEditRequestFromJson(json);

@override final  String? name;
 final  List<int>? _privilegeIds;
@override@JsonKey(name: 'privilege_ids') List<int>? get privilegeIds {
  final value = _privilegeIds;
  if (value == null) return null;
  if (_privilegeIds is EqualUnmodifiableListView) return _privilegeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of RoleEditRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleEditRequestCopyWith<_RoleEditRequest> get copyWith => __$RoleEditRequestCopyWithImpl<_RoleEditRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleEditRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoleEditRequest&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._privilegeIds, _privilegeIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_privilegeIds));

@override
String toString() {
  return 'RoleEditRequest(name: $name, privilegeIds: $privilegeIds)';
}


}

/// @nodoc
abstract mixin class _$RoleEditRequestCopyWith<$Res> implements $RoleEditRequestCopyWith<$Res> {
  factory _$RoleEditRequestCopyWith(_RoleEditRequest value, $Res Function(_RoleEditRequest) _then) = __$RoleEditRequestCopyWithImpl;
@override @useResult
$Res call({
 String? name,@JsonKey(name: 'privilege_ids') List<int>? privilegeIds
});




}
/// @nodoc
class __$RoleEditRequestCopyWithImpl<$Res>
    implements _$RoleEditRequestCopyWith<$Res> {
  __$RoleEditRequestCopyWithImpl(this._self, this._then);

  final _RoleEditRequest _self;
  final $Res Function(_RoleEditRequest) _then;

/// Create a copy of RoleEditRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? privilegeIds = freezed,}) {
  return _then(_RoleEditRequest(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,privilegeIds: freezed == privilegeIds ? _self._privilegeIds : privilegeIds // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}


}

// dart format on
