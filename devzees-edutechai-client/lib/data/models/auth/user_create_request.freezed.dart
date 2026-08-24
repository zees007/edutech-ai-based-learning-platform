// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserCreateRequest {

@JsonKey(name: 'first_name') String get firstName;@JsonKey(name: 'last_name') String get lastName; String get email; String get password; String? get mobile; String? get country;
/// Create a copy of UserCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCreateRequestCopyWith<UserCreateRequest> get copyWith => _$UserCreateRequestCopyWithImpl<UserCreateRequest>(this as UserCreateRequest, _$identity);

  /// Serializes this UserCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserCreateRequest&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,email,password,mobile,country);

@override
String toString() {
  return 'UserCreateRequest(firstName: $firstName, lastName: $lastName, email: $email, password: $password, mobile: $mobile, country: $country)';
}


}

/// @nodoc
abstract mixin class $UserCreateRequestCopyWith<$Res>  {
  factory $UserCreateRequestCopyWith(UserCreateRequest value, $Res Function(UserCreateRequest) _then) = _$UserCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName, String email, String password, String? mobile, String? country
});




}
/// @nodoc
class _$UserCreateRequestCopyWithImpl<$Res>
    implements $UserCreateRequestCopyWith<$Res> {
  _$UserCreateRequestCopyWithImpl(this._self, this._then);

  final UserCreateRequest _self;
  final $Res Function(UserCreateRequest) _then;

/// Create a copy of UserCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = null,Object? lastName = null,Object? email = null,Object? password = null,Object? mobile = freezed,Object? country = freezed,}) {
  return _then(_self.copyWith(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserCreateRequest].
extension UserCreateRequestPatterns on UserCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _UserCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UserCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName,  String email,  String password,  String? mobile,  String? country)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserCreateRequest() when $default != null:
return $default(_that.firstName,_that.lastName,_that.email,_that.password,_that.mobile,_that.country);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName,  String email,  String password,  String? mobile,  String? country)  $default,) {final _that = this;
switch (_that) {
case _UserCreateRequest():
return $default(_that.firstName,_that.lastName,_that.email,_that.password,_that.mobile,_that.country);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName,  String email,  String password,  String? mobile,  String? country)?  $default,) {final _that = this;
switch (_that) {
case _UserCreateRequest() when $default != null:
return $default(_that.firstName,_that.lastName,_that.email,_that.password,_that.mobile,_that.country);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserCreateRequest implements UserCreateRequest {
  const _UserCreateRequest({@JsonKey(name: 'first_name') required this.firstName, @JsonKey(name: 'last_name') required this.lastName, required this.email, required this.password, this.mobile, this.country});
  factory _UserCreateRequest.fromJson(Map<String, dynamic> json) => _$UserCreateRequestFromJson(json);

@override@JsonKey(name: 'first_name') final  String firstName;
@override@JsonKey(name: 'last_name') final  String lastName;
@override final  String email;
@override final  String password;
@override final  String? mobile;
@override final  String? country;

/// Create a copy of UserCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCreateRequestCopyWith<_UserCreateRequest> get copyWith => __$UserCreateRequestCopyWithImpl<_UserCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserCreateRequest&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,email,password,mobile,country);

@override
String toString() {
  return 'UserCreateRequest(firstName: $firstName, lastName: $lastName, email: $email, password: $password, mobile: $mobile, country: $country)';
}


}

/// @nodoc
abstract mixin class _$UserCreateRequestCopyWith<$Res> implements $UserCreateRequestCopyWith<$Res> {
  factory _$UserCreateRequestCopyWith(_UserCreateRequest value, $Res Function(_UserCreateRequest) _then) = __$UserCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName, String email, String password, String? mobile, String? country
});




}
/// @nodoc
class __$UserCreateRequestCopyWithImpl<$Res>
    implements _$UserCreateRequestCopyWith<$Res> {
  __$UserCreateRequestCopyWithImpl(this._self, this._then);

  final _UserCreateRequest _self;
  final $Res Function(_UserCreateRequest) _then;

/// Create a copy of UserCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = null,Object? lastName = null,Object? email = null,Object? password = null,Object? mobile = freezed,Object? country = freezed,}) {
  return _then(_UserCreateRequest(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
