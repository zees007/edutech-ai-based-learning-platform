// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_current_profile_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserCurrentProfileResponse {

 String get id;@JsonKey(name: 'first_name') String get firstName;@JsonKey(name: 'last_name') String get lastName; String get email; String? get mobile; String? get country;@JsonKey(name: 'created_at') DateTime get createdAt; List<String> get roles; SubscriptionResponse? get subscription;@JsonKey(name: 'privilege_codes') List<String> get privilegeCodes;
/// Create a copy of UserCurrentProfileResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCurrentProfileResponseCopyWith<UserCurrentProfileResponse> get copyWith => _$UserCurrentProfileResponseCopyWithImpl<UserCurrentProfileResponse>(this as UserCurrentProfileResponse, _$identity);

  /// Serializes this UserCurrentProfileResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserCurrentProfileResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.country, country) || other.country == country)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&const DeepCollectionEquality().equals(other.privilegeCodes, privilegeCodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email,mobile,country,createdAt,const DeepCollectionEquality().hash(roles),subscription,const DeepCollectionEquality().hash(privilegeCodes));

@override
String toString() {
  return 'UserCurrentProfileResponse(id: $id, firstName: $firstName, lastName: $lastName, email: $email, mobile: $mobile, country: $country, createdAt: $createdAt, roles: $roles, subscription: $subscription, privilegeCodes: $privilegeCodes)';
}


}

/// @nodoc
abstract mixin class $UserCurrentProfileResponseCopyWith<$Res>  {
  factory $UserCurrentProfileResponseCopyWith(UserCurrentProfileResponse value, $Res Function(UserCurrentProfileResponse) _then) = _$UserCurrentProfileResponseCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName, String email, String? mobile, String? country,@JsonKey(name: 'created_at') DateTime createdAt, List<String> roles, SubscriptionResponse? subscription,@JsonKey(name: 'privilege_codes') List<String> privilegeCodes
});


$SubscriptionResponseCopyWith<$Res>? get subscription;

}
/// @nodoc
class _$UserCurrentProfileResponseCopyWithImpl<$Res>
    implements $UserCurrentProfileResponseCopyWith<$Res> {
  _$UserCurrentProfileResponseCopyWithImpl(this._self, this._then);

  final UserCurrentProfileResponse _self;
  final $Res Function(UserCurrentProfileResponse) _then;

/// Create a copy of UserCurrentProfileResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? mobile = freezed,Object? country = freezed,Object? createdAt = null,Object? roles = null,Object? subscription = freezed,Object? privilegeCodes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SubscriptionResponse?,privilegeCodes: null == privilegeCodes ? _self.privilegeCodes : privilegeCodes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of UserCurrentProfileResponse
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


/// Adds pattern-matching-related methods to [UserCurrentProfileResponse].
extension UserCurrentProfileResponsePatterns on UserCurrentProfileResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserCurrentProfileResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserCurrentProfileResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserCurrentProfileResponse value)  $default,){
final _that = this;
switch (_that) {
case _UserCurrentProfileResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserCurrentProfileResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UserCurrentProfileResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName,  String email,  String? mobile,  String? country, @JsonKey(name: 'created_at')  DateTime createdAt,  List<String> roles,  SubscriptionResponse? subscription, @JsonKey(name: 'privilege_codes')  List<String> privilegeCodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserCurrentProfileResponse() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.mobile,_that.country,_that.createdAt,_that.roles,_that.subscription,_that.privilegeCodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName,  String email,  String? mobile,  String? country, @JsonKey(name: 'created_at')  DateTime createdAt,  List<String> roles,  SubscriptionResponse? subscription, @JsonKey(name: 'privilege_codes')  List<String> privilegeCodes)  $default,) {final _that = this;
switch (_that) {
case _UserCurrentProfileResponse():
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.mobile,_that.country,_that.createdAt,_that.roles,_that.subscription,_that.privilegeCodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName,  String email,  String? mobile,  String? country, @JsonKey(name: 'created_at')  DateTime createdAt,  List<String> roles,  SubscriptionResponse? subscription, @JsonKey(name: 'privilege_codes')  List<String> privilegeCodes)?  $default,) {final _that = this;
switch (_that) {
case _UserCurrentProfileResponse() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.mobile,_that.country,_that.createdAt,_that.roles,_that.subscription,_that.privilegeCodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserCurrentProfileResponse implements UserCurrentProfileResponse {
  const _UserCurrentProfileResponse({required this.id, @JsonKey(name: 'first_name') required this.firstName, @JsonKey(name: 'last_name') required this.lastName, required this.email, this.mobile, this.country, @JsonKey(name: 'created_at') required this.createdAt, final  List<String> roles = const [], this.subscription, @JsonKey(name: 'privilege_codes') final  List<String> privilegeCodes = const []}): _roles = roles,_privilegeCodes = privilegeCodes;
  factory _UserCurrentProfileResponse.fromJson(Map<String, dynamic> json) => _$UserCurrentProfileResponseFromJson(json);

@override final  String id;
@override@JsonKey(name: 'first_name') final  String firstName;
@override@JsonKey(name: 'last_name') final  String lastName;
@override final  String email;
@override final  String? mobile;
@override final  String? country;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
 final  List<String> _roles;
@override@JsonKey() List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override final  SubscriptionResponse? subscription;
 final  List<String> _privilegeCodes;
@override@JsonKey(name: 'privilege_codes') List<String> get privilegeCodes {
  if (_privilegeCodes is EqualUnmodifiableListView) return _privilegeCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_privilegeCodes);
}


/// Create a copy of UserCurrentProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCurrentProfileResponseCopyWith<_UserCurrentProfileResponse> get copyWith => __$UserCurrentProfileResponseCopyWithImpl<_UserCurrentProfileResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserCurrentProfileResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserCurrentProfileResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.country, country) || other.country == country)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&const DeepCollectionEquality().equals(other._privilegeCodes, _privilegeCodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email,mobile,country,createdAt,const DeepCollectionEquality().hash(_roles),subscription,const DeepCollectionEquality().hash(_privilegeCodes));

@override
String toString() {
  return 'UserCurrentProfileResponse(id: $id, firstName: $firstName, lastName: $lastName, email: $email, mobile: $mobile, country: $country, createdAt: $createdAt, roles: $roles, subscription: $subscription, privilegeCodes: $privilegeCodes)';
}


}

/// @nodoc
abstract mixin class _$UserCurrentProfileResponseCopyWith<$Res> implements $UserCurrentProfileResponseCopyWith<$Res> {
  factory _$UserCurrentProfileResponseCopyWith(_UserCurrentProfileResponse value, $Res Function(_UserCurrentProfileResponse) _then) = __$UserCurrentProfileResponseCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName, String email, String? mobile, String? country,@JsonKey(name: 'created_at') DateTime createdAt, List<String> roles, SubscriptionResponse? subscription,@JsonKey(name: 'privilege_codes') List<String> privilegeCodes
});


@override $SubscriptionResponseCopyWith<$Res>? get subscription;

}
/// @nodoc
class __$UserCurrentProfileResponseCopyWithImpl<$Res>
    implements _$UserCurrentProfileResponseCopyWith<$Res> {
  __$UserCurrentProfileResponseCopyWithImpl(this._self, this._then);

  final _UserCurrentProfileResponse _self;
  final $Res Function(_UserCurrentProfileResponse) _then;

/// Create a copy of UserCurrentProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? mobile = freezed,Object? country = freezed,Object? createdAt = null,Object? roles = null,Object? subscription = freezed,Object? privilegeCodes = null,}) {
  return _then(_UserCurrentProfileResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SubscriptionResponse?,privilegeCodes: null == privilegeCodes ? _self._privilegeCodes : privilegeCodes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of UserCurrentProfileResponse
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
