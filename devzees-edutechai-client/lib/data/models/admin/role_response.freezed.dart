// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoleResponse {

 String get id; String get name; List<PrivilegeResponse> get privileges;@JsonKey(name: 'created_at') DateTime get createdAt; bool get retired;@JsonKey(name: 'retired_at') DateTime? get retiredAt;@JsonKey(name: 'retired_by') String? get retiredBy;
/// Create a copy of RoleResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleResponseCopyWith<RoleResponse> get copyWith => _$RoleResponseCopyWithImpl<RoleResponse>(this as RoleResponse, _$identity);

  /// Serializes this RoleResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.privileges, privileges)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.retired, retired) || other.retired == retired)&&(identical(other.retiredAt, retiredAt) || other.retiredAt == retiredAt)&&(identical(other.retiredBy, retiredBy) || other.retiredBy == retiredBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(privileges),createdAt,retired,retiredAt,retiredBy);

@override
String toString() {
  return 'RoleResponse(id: $id, name: $name, privileges: $privileges, createdAt: $createdAt, retired: $retired, retiredAt: $retiredAt, retiredBy: $retiredBy)';
}


}

/// @nodoc
abstract mixin class $RoleResponseCopyWith<$Res>  {
  factory $RoleResponseCopyWith(RoleResponse value, $Res Function(RoleResponse) _then) = _$RoleResponseCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<PrivilegeResponse> privileges,@JsonKey(name: 'created_at') DateTime createdAt, bool retired,@JsonKey(name: 'retired_at') DateTime? retiredAt,@JsonKey(name: 'retired_by') String? retiredBy
});




}
/// @nodoc
class _$RoleResponseCopyWithImpl<$Res>
    implements $RoleResponseCopyWith<$Res> {
  _$RoleResponseCopyWithImpl(this._self, this._then);

  final RoleResponse _self;
  final $Res Function(RoleResponse) _then;

/// Create a copy of RoleResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? privileges = null,Object? createdAt = null,Object? retired = null,Object? retiredAt = freezed,Object? retiredBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,privileges: null == privileges ? _self.privileges : privileges // ignore: cast_nullable_to_non_nullable
as List<PrivilegeResponse>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,retired: null == retired ? _self.retired : retired // ignore: cast_nullable_to_non_nullable
as bool,retiredAt: freezed == retiredAt ? _self.retiredAt : retiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retiredBy: freezed == retiredBy ? _self.retiredBy : retiredBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoleResponse].
extension RoleResponsePatterns on RoleResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoleResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoleResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoleResponse value)  $default,){
final _that = this;
switch (_that) {
case _RoleResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoleResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RoleResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<PrivilegeResponse> privileges, @JsonKey(name: 'created_at')  DateTime createdAt,  bool retired, @JsonKey(name: 'retired_at')  DateTime? retiredAt, @JsonKey(name: 'retired_by')  String? retiredBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoleResponse() when $default != null:
return $default(_that.id,_that.name,_that.privileges,_that.createdAt,_that.retired,_that.retiredAt,_that.retiredBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<PrivilegeResponse> privileges, @JsonKey(name: 'created_at')  DateTime createdAt,  bool retired, @JsonKey(name: 'retired_at')  DateTime? retiredAt, @JsonKey(name: 'retired_by')  String? retiredBy)  $default,) {final _that = this;
switch (_that) {
case _RoleResponse():
return $default(_that.id,_that.name,_that.privileges,_that.createdAt,_that.retired,_that.retiredAt,_that.retiredBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<PrivilegeResponse> privileges, @JsonKey(name: 'created_at')  DateTime createdAt,  bool retired, @JsonKey(name: 'retired_at')  DateTime? retiredAt, @JsonKey(name: 'retired_by')  String? retiredBy)?  $default,) {final _that = this;
switch (_that) {
case _RoleResponse() when $default != null:
return $default(_that.id,_that.name,_that.privileges,_that.createdAt,_that.retired,_that.retiredAt,_that.retiredBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoleResponse implements RoleResponse {
  const _RoleResponse({required this.id, required this.name, final  List<PrivilegeResponse> privileges = const [], @JsonKey(name: 'created_at') required this.createdAt, this.retired = false, @JsonKey(name: 'retired_at') this.retiredAt, @JsonKey(name: 'retired_by') this.retiredBy}): _privileges = privileges;
  factory _RoleResponse.fromJson(Map<String, dynamic> json) => _$RoleResponseFromJson(json);

@override final  String id;
@override final  String name;
 final  List<PrivilegeResponse> _privileges;
@override@JsonKey() List<PrivilegeResponse> get privileges {
  if (_privileges is EqualUnmodifiableListView) return _privileges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_privileges);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey() final  bool retired;
@override@JsonKey(name: 'retired_at') final  DateTime? retiredAt;
@override@JsonKey(name: 'retired_by') final  String? retiredBy;

/// Create a copy of RoleResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleResponseCopyWith<_RoleResponse> get copyWith => __$RoleResponseCopyWithImpl<_RoleResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoleResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._privileges, _privileges)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.retired, retired) || other.retired == retired)&&(identical(other.retiredAt, retiredAt) || other.retiredAt == retiredAt)&&(identical(other.retiredBy, retiredBy) || other.retiredBy == retiredBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_privileges),createdAt,retired,retiredAt,retiredBy);

@override
String toString() {
  return 'RoleResponse(id: $id, name: $name, privileges: $privileges, createdAt: $createdAt, retired: $retired, retiredAt: $retiredAt, retiredBy: $retiredBy)';
}


}

/// @nodoc
abstract mixin class _$RoleResponseCopyWith<$Res> implements $RoleResponseCopyWith<$Res> {
  factory _$RoleResponseCopyWith(_RoleResponse value, $Res Function(_RoleResponse) _then) = __$RoleResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<PrivilegeResponse> privileges,@JsonKey(name: 'created_at') DateTime createdAt, bool retired,@JsonKey(name: 'retired_at') DateTime? retiredAt,@JsonKey(name: 'retired_by') String? retiredBy
});




}
/// @nodoc
class __$RoleResponseCopyWithImpl<$Res>
    implements _$RoleResponseCopyWith<$Res> {
  __$RoleResponseCopyWithImpl(this._self, this._then);

  final _RoleResponse _self;
  final $Res Function(_RoleResponse) _then;

/// Create a copy of RoleResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? privileges = null,Object? createdAt = null,Object? retired = null,Object? retiredAt = freezed,Object? retiredBy = freezed,}) {
  return _then(_RoleResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,privileges: null == privileges ? _self._privileges : privileges // ignore: cast_nullable_to_non_nullable
as List<PrivilegeResponse>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,retired: null == retired ? _self.retired : retired // ignore: cast_nullable_to_non_nullable
as bool,retiredAt: freezed == retiredAt ? _self.retiredAt : retiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retiredBy: freezed == retiredBy ? _self.retiredBy : retiredBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
