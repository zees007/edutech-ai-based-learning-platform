// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminUserResponse {

 String get id;@JsonKey(name: 'first_name') String get firstName;@JsonKey(name: 'last_name') String get lastName; String get email; String? get mobile; String? get country; List<RoleResponse> get roles; SubscriptionResponse? get subscription;@JsonKey(name: 'created_at') DateTime get createdAt; bool get retired;@JsonKey(name: 'retired_at') DateTime? get retiredAt;@JsonKey(name: 'retired_by') String? get retiredBy;
/// Create a copy of AdminUserResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserResponseCopyWith<AdminUserResponse> get copyWith => _$AdminUserResponseCopyWithImpl<AdminUserResponse>(this as AdminUserResponse, _$identity);

  /// Serializes this AdminUserResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUserResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.retired, retired) || other.retired == retired)&&(identical(other.retiredAt, retiredAt) || other.retiredAt == retiredAt)&&(identical(other.retiredBy, retiredBy) || other.retiredBy == retiredBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email,mobile,country,const DeepCollectionEquality().hash(roles),subscription,createdAt,retired,retiredAt,retiredBy);

@override
String toString() {
  return 'AdminUserResponse(id: $id, firstName: $firstName, lastName: $lastName, email: $email, mobile: $mobile, country: $country, roles: $roles, subscription: $subscription, createdAt: $createdAt, retired: $retired, retiredAt: $retiredAt, retiredBy: $retiredBy)';
}


}

/// @nodoc
abstract mixin class $AdminUserResponseCopyWith<$Res>  {
  factory $AdminUserResponseCopyWith(AdminUserResponse value, $Res Function(AdminUserResponse) _then) = _$AdminUserResponseCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName, String email, String? mobile, String? country, List<RoleResponse> roles, SubscriptionResponse? subscription,@JsonKey(name: 'created_at') DateTime createdAt, bool retired,@JsonKey(name: 'retired_at') DateTime? retiredAt,@JsonKey(name: 'retired_by') String? retiredBy
});


$SubscriptionResponseCopyWith<$Res>? get subscription;

}
/// @nodoc
class _$AdminUserResponseCopyWithImpl<$Res>
    implements $AdminUserResponseCopyWith<$Res> {
  _$AdminUserResponseCopyWithImpl(this._self, this._then);

  final AdminUserResponse _self;
  final $Res Function(AdminUserResponse) _then;

/// Create a copy of AdminUserResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? mobile = freezed,Object? country = freezed,Object? roles = null,Object? subscription = freezed,Object? createdAt = null,Object? retired = null,Object? retiredAt = freezed,Object? retiredBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<RoleResponse>,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SubscriptionResponse?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,retired: null == retired ? _self.retired : retired // ignore: cast_nullable_to_non_nullable
as bool,retiredAt: freezed == retiredAt ? _self.retiredAt : retiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retiredBy: freezed == retiredBy ? _self.retiredBy : retiredBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AdminUserResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionResponseCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $SubscriptionResponseCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdminUserResponse].
extension AdminUserResponsePatterns on AdminUserResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUserResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUserResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUserResponse value)  $default,){
final _that = this;
switch (_that) {
case _AdminUserResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUserResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUserResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName,  String email,  String? mobile,  String? country,  List<RoleResponse> roles,  SubscriptionResponse? subscription, @JsonKey(name: 'created_at')  DateTime createdAt,  bool retired, @JsonKey(name: 'retired_at')  DateTime? retiredAt, @JsonKey(name: 'retired_by')  String? retiredBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUserResponse() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.mobile,_that.country,_that.roles,_that.subscription,_that.createdAt,_that.retired,_that.retiredAt,_that.retiredBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName,  String email,  String? mobile,  String? country,  List<RoleResponse> roles,  SubscriptionResponse? subscription, @JsonKey(name: 'created_at')  DateTime createdAt,  bool retired, @JsonKey(name: 'retired_at')  DateTime? retiredAt, @JsonKey(name: 'retired_by')  String? retiredBy)  $default,) {final _that = this;
switch (_that) {
case _AdminUserResponse():
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.mobile,_that.country,_that.roles,_that.subscription,_that.createdAt,_that.retired,_that.retiredAt,_that.retiredBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName,  String email,  String? mobile,  String? country,  List<RoleResponse> roles,  SubscriptionResponse? subscription, @JsonKey(name: 'created_at')  DateTime createdAt,  bool retired, @JsonKey(name: 'retired_at')  DateTime? retiredAt, @JsonKey(name: 'retired_by')  String? retiredBy)?  $default,) {final _that = this;
switch (_that) {
case _AdminUserResponse() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.mobile,_that.country,_that.roles,_that.subscription,_that.createdAt,_that.retired,_that.retiredAt,_that.retiredBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminUserResponse implements AdminUserResponse {
  const _AdminUserResponse({required this.id, @JsonKey(name: 'first_name') required this.firstName, @JsonKey(name: 'last_name') required this.lastName, required this.email, this.mobile, this.country, final  List<RoleResponse> roles = const [], this.subscription, @JsonKey(name: 'created_at') required this.createdAt, this.retired = false, @JsonKey(name: 'retired_at') this.retiredAt, @JsonKey(name: 'retired_by') this.retiredBy}): _roles = roles;
  factory _AdminUserResponse.fromJson(Map<String, dynamic> json) => _$AdminUserResponseFromJson(json);

@override final  String id;
@override@JsonKey(name: 'first_name') final  String firstName;
@override@JsonKey(name: 'last_name') final  String lastName;
@override final  String email;
@override final  String? mobile;
@override final  String? country;
 final  List<RoleResponse> _roles;
@override@JsonKey() List<RoleResponse> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override final  SubscriptionResponse? subscription;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey() final  bool retired;
@override@JsonKey(name: 'retired_at') final  DateTime? retiredAt;
@override@JsonKey(name: 'retired_by') final  String? retiredBy;

/// Create a copy of AdminUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserResponseCopyWith<_AdminUserResponse> get copyWith => __$AdminUserResponseCopyWithImpl<_AdminUserResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUserResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.retired, retired) || other.retired == retired)&&(identical(other.retiredAt, retiredAt) || other.retiredAt == retiredAt)&&(identical(other.retiredBy, retiredBy) || other.retiredBy == retiredBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email,mobile,country,const DeepCollectionEquality().hash(_roles),subscription,createdAt,retired,retiredAt,retiredBy);

@override
String toString() {
  return 'AdminUserResponse(id: $id, firstName: $firstName, lastName: $lastName, email: $email, mobile: $mobile, country: $country, roles: $roles, subscription: $subscription, createdAt: $createdAt, retired: $retired, retiredAt: $retiredAt, retiredBy: $retiredBy)';
}


}

/// @nodoc
abstract mixin class _$AdminUserResponseCopyWith<$Res> implements $AdminUserResponseCopyWith<$Res> {
  factory _$AdminUserResponseCopyWith(_AdminUserResponse value, $Res Function(_AdminUserResponse) _then) = __$AdminUserResponseCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName, String email, String? mobile, String? country, List<RoleResponse> roles, SubscriptionResponse? subscription,@JsonKey(name: 'created_at') DateTime createdAt, bool retired,@JsonKey(name: 'retired_at') DateTime? retiredAt,@JsonKey(name: 'retired_by') String? retiredBy
});


@override $SubscriptionResponseCopyWith<$Res>? get subscription;

}
/// @nodoc
class __$AdminUserResponseCopyWithImpl<$Res>
    implements _$AdminUserResponseCopyWith<$Res> {
  __$AdminUserResponseCopyWithImpl(this._self, this._then);

  final _AdminUserResponse _self;
  final $Res Function(_AdminUserResponse) _then;

/// Create a copy of AdminUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? mobile = freezed,Object? country = freezed,Object? roles = null,Object? subscription = freezed,Object? createdAt = null,Object? retired = null,Object? retiredAt = freezed,Object? retiredBy = freezed,}) {
  return _then(_AdminUserResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<RoleResponse>,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SubscriptionResponse?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,retired: null == retired ? _self.retired : retired // ignore: cast_nullable_to_non_nullable
as bool,retiredAt: freezed == retiredAt ? _self.retiredAt : retiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retiredBy: freezed == retiredBy ? _self.retiredBy : retiredBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AdminUserResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionResponseCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $SubscriptionResponseCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}

// dart format on
