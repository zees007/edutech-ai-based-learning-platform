// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'privilege_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrivilegeResponse {

 int get id; String get name; String get code;@JsonKey(name: 'order_number') int get orderNumber;@JsonKey(name: 'parent_id') int? get parentId;
/// Create a copy of PrivilegeResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivilegeResponseCopyWith<PrivilegeResponse> get copyWith => _$PrivilegeResponseCopyWithImpl<PrivilegeResponse>(this as PrivilegeResponse, _$identity);

  /// Serializes this PrivilegeResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivilegeResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,code,orderNumber,parentId);

@override
String toString() {
  return 'PrivilegeResponse(id: $id, name: $name, code: $code, orderNumber: $orderNumber, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $PrivilegeResponseCopyWith<$Res>  {
  factory $PrivilegeResponseCopyWith(PrivilegeResponse value, $Res Function(PrivilegeResponse) _then) = _$PrivilegeResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name, String code,@JsonKey(name: 'order_number') int orderNumber,@JsonKey(name: 'parent_id') int? parentId
});




}
/// @nodoc
class _$PrivilegeResponseCopyWithImpl<$Res>
    implements $PrivilegeResponseCopyWith<$Res> {
  _$PrivilegeResponseCopyWithImpl(this._self, this._then);

  final PrivilegeResponse _self;
  final $Res Function(PrivilegeResponse) _then;

/// Create a copy of PrivilegeResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = null,Object? orderNumber = null,Object? parentId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivilegeResponse].
extension PrivilegeResponsePatterns on PrivilegeResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivilegeResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivilegeResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivilegeResponse value)  $default,){
final _that = this;
switch (_that) {
case _PrivilegeResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivilegeResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PrivilegeResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String code, @JsonKey(name: 'order_number')  int orderNumber, @JsonKey(name: 'parent_id')  int? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivilegeResponse() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.orderNumber,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String code, @JsonKey(name: 'order_number')  int orderNumber, @JsonKey(name: 'parent_id')  int? parentId)  $default,) {final _that = this;
switch (_that) {
case _PrivilegeResponse():
return $default(_that.id,_that.name,_that.code,_that.orderNumber,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String code, @JsonKey(name: 'order_number')  int orderNumber, @JsonKey(name: 'parent_id')  int? parentId)?  $default,) {final _that = this;
switch (_that) {
case _PrivilegeResponse() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.orderNumber,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrivilegeResponse implements PrivilegeResponse {
  const _PrivilegeResponse({required this.id, required this.name, required this.code, @JsonKey(name: 'order_number') this.orderNumber = 0, @JsonKey(name: 'parent_id') this.parentId});
  factory _PrivilegeResponse.fromJson(Map<String, dynamic> json) => _$PrivilegeResponseFromJson(json);

@override final  int id;
@override final  String name;
@override final  String code;
@override@JsonKey(name: 'order_number') final  int orderNumber;
@override@JsonKey(name: 'parent_id') final  int? parentId;

/// Create a copy of PrivilegeResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivilegeResponseCopyWith<_PrivilegeResponse> get copyWith => __$PrivilegeResponseCopyWithImpl<_PrivilegeResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrivilegeResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivilegeResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,code,orderNumber,parentId);

@override
String toString() {
  return 'PrivilegeResponse(id: $id, name: $name, code: $code, orderNumber: $orderNumber, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$PrivilegeResponseCopyWith<$Res> implements $PrivilegeResponseCopyWith<$Res> {
  factory _$PrivilegeResponseCopyWith(_PrivilegeResponse value, $Res Function(_PrivilegeResponse) _then) = __$PrivilegeResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String code,@JsonKey(name: 'order_number') int orderNumber,@JsonKey(name: 'parent_id') int? parentId
});




}
/// @nodoc
class __$PrivilegeResponseCopyWithImpl<$Res>
    implements _$PrivilegeResponseCopyWith<$Res> {
  __$PrivilegeResponseCopyWithImpl(this._self, this._then);

  final _PrivilegeResponse _self;
  final $Res Function(_PrivilegeResponse) _then;

/// Create a copy of PrivilegeResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = null,Object? orderNumber = null,Object? parentId = freezed,}) {
  return _then(_PrivilegeResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
