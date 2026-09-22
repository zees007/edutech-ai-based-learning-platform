// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_role_assign_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserRoleAssignRequest {

@JsonKey(name: 'role_ids') List<String> get roleIds;
/// Create a copy of UserRoleAssignRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserRoleAssignRequestCopyWith<UserRoleAssignRequest> get copyWith => _$UserRoleAssignRequestCopyWithImpl<UserRoleAssignRequest>(this as UserRoleAssignRequest, _$identity);

  /// Serializes this UserRoleAssignRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserRoleAssignRequest&&const DeepCollectionEquality().equals(other.roleIds, roleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(roleIds));

@override
String toString() {
  return 'UserRoleAssignRequest(roleIds: $roleIds)';
}


}

/// @nodoc
abstract mixin class $UserRoleAssignRequestCopyWith<$Res>  {
  factory $UserRoleAssignRequestCopyWith(UserRoleAssignRequest value, $Res Function(UserRoleAssignRequest) _then) = _$UserRoleAssignRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'role_ids') List<String> roleIds
});




}
/// @nodoc
class _$UserRoleAssignRequestCopyWithImpl<$Res>
    implements $UserRoleAssignRequestCopyWith<$Res> {
  _$UserRoleAssignRequestCopyWithImpl(this._self, this._then);

  final UserRoleAssignRequest _self;
  final $Res Function(UserRoleAssignRequest) _then;

/// Create a copy of UserRoleAssignRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roleIds = null,}) {
  return _then(_self.copyWith(
roleIds: null == roleIds ? _self.roleIds : roleIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserRoleAssignRequest].
extension UserRoleAssignRequestPatterns on UserRoleAssignRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserRoleAssignRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserRoleAssignRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserRoleAssignRequest value)  $default,){
final _that = this;
switch (_that) {
case _UserRoleAssignRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserRoleAssignRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UserRoleAssignRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'role_ids')  List<String> roleIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserRoleAssignRequest() when $default != null:
return $default(_that.roleIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'role_ids')  List<String> roleIds)  $default,) {final _that = this;
switch (_that) {
case _UserRoleAssignRequest():
return $default(_that.roleIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'role_ids')  List<String> roleIds)?  $default,) {final _that = this;
switch (_that) {
case _UserRoleAssignRequest() when $default != null:
return $default(_that.roleIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserRoleAssignRequest implements UserRoleAssignRequest {
  const _UserRoleAssignRequest({@JsonKey(name: 'role_ids') required final  List<String> roleIds}): _roleIds = roleIds;
  factory _UserRoleAssignRequest.fromJson(Map<String, dynamic> json) => _$UserRoleAssignRequestFromJson(json);

 final  List<String> _roleIds;
@override@JsonKey(name: 'role_ids') List<String> get roleIds {
  if (_roleIds is EqualUnmodifiableListView) return _roleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roleIds);
}


/// Create a copy of UserRoleAssignRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserRoleAssignRequestCopyWith<_UserRoleAssignRequest> get copyWith => __$UserRoleAssignRequestCopyWithImpl<_UserRoleAssignRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserRoleAssignRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserRoleAssignRequest&&const DeepCollectionEquality().equals(other._roleIds, _roleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_roleIds));

@override
String toString() {
  return 'UserRoleAssignRequest(roleIds: $roleIds)';
}


}

/// @nodoc
abstract mixin class _$UserRoleAssignRequestCopyWith<$Res> implements $UserRoleAssignRequestCopyWith<$Res> {
  factory _$UserRoleAssignRequestCopyWith(_UserRoleAssignRequest value, $Res Function(_UserRoleAssignRequest) _then) = __$UserRoleAssignRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'role_ids') List<String> roleIds
});




}
/// @nodoc
class __$UserRoleAssignRequestCopyWithImpl<$Res>
    implements _$UserRoleAssignRequestCopyWith<$Res> {
  __$UserRoleAssignRequestCopyWithImpl(this._self, this._then);

  final _UserRoleAssignRequest _self;
  final $Res Function(_UserRoleAssignRequest) _then;

/// Create a copy of UserRoleAssignRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roleIds = null,}) {
  return _then(_UserRoleAssignRequest(
roleIds: null == roleIds ? _self._roleIds : roleIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
