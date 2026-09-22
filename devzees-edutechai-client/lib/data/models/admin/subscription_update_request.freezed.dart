// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionUpdateRequest {

 String get tier; String get status;@JsonKey(name: 'billing_cycle') String get billingCycle;@JsonKey(name: 'gateway_provider') String? get gatewayProvider;@JsonKey(name: 'current_period_end') DateTime? get currentPeriodEnd;@JsonKey(name: 'payment_gateway_ref') String? get paymentGatewayRef;
/// Create a copy of SubscriptionUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionUpdateRequestCopyWith<SubscriptionUpdateRequest> get copyWith => _$SubscriptionUpdateRequestCopyWithImpl<SubscriptionUpdateRequest>(this as SubscriptionUpdateRequest, _$identity);

  /// Serializes this SubscriptionUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionUpdateRequest&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.gatewayProvider, gatewayProvider) || other.gatewayProvider == gatewayProvider)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.paymentGatewayRef, paymentGatewayRef) || other.paymentGatewayRef == paymentGatewayRef));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,status,billingCycle,gatewayProvider,currentPeriodEnd,paymentGatewayRef);

@override
String toString() {
  return 'SubscriptionUpdateRequest(tier: $tier, status: $status, billingCycle: $billingCycle, gatewayProvider: $gatewayProvider, currentPeriodEnd: $currentPeriodEnd, paymentGatewayRef: $paymentGatewayRef)';
}


}

/// @nodoc
abstract mixin class $SubscriptionUpdateRequestCopyWith<$Res>  {
  factory $SubscriptionUpdateRequestCopyWith(SubscriptionUpdateRequest value, $Res Function(SubscriptionUpdateRequest) _then) = _$SubscriptionUpdateRequestCopyWithImpl;
@useResult
$Res call({
 String tier, String status,@JsonKey(name: 'billing_cycle') String billingCycle,@JsonKey(name: 'gateway_provider') String? gatewayProvider,@JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,@JsonKey(name: 'payment_gateway_ref') String? paymentGatewayRef
});




}
/// @nodoc
class _$SubscriptionUpdateRequestCopyWithImpl<$Res>
    implements $SubscriptionUpdateRequestCopyWith<$Res> {
  _$SubscriptionUpdateRequestCopyWithImpl(this._self, this._then);

  final SubscriptionUpdateRequest _self;
  final $Res Function(SubscriptionUpdateRequest) _then;

/// Create a copy of SubscriptionUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tier = null,Object? status = null,Object? billingCycle = null,Object? gatewayProvider = freezed,Object? currentPeriodEnd = freezed,Object? paymentGatewayRef = freezed,}) {
  return _then(_self.copyWith(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,billingCycle: null == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String,gatewayProvider: freezed == gatewayProvider ? _self.gatewayProvider : gatewayProvider // ignore: cast_nullable_to_non_nullable
as String?,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentGatewayRef: freezed == paymentGatewayRef ? _self.paymentGatewayRef : paymentGatewayRef // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionUpdateRequest].
extension SubscriptionUpdateRequestPatterns on SubscriptionUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tier,  String status, @JsonKey(name: 'billing_cycle')  String billingCycle, @JsonKey(name: 'gateway_provider')  String? gatewayProvider, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'payment_gateway_ref')  String? paymentGatewayRef)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionUpdateRequest() when $default != null:
return $default(_that.tier,_that.status,_that.billingCycle,_that.gatewayProvider,_that.currentPeriodEnd,_that.paymentGatewayRef);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tier,  String status, @JsonKey(name: 'billing_cycle')  String billingCycle, @JsonKey(name: 'gateway_provider')  String? gatewayProvider, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'payment_gateway_ref')  String? paymentGatewayRef)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionUpdateRequest():
return $default(_that.tier,_that.status,_that.billingCycle,_that.gatewayProvider,_that.currentPeriodEnd,_that.paymentGatewayRef);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tier,  String status, @JsonKey(name: 'billing_cycle')  String billingCycle, @JsonKey(name: 'gateway_provider')  String? gatewayProvider, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'payment_gateway_ref')  String? paymentGatewayRef)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionUpdateRequest() when $default != null:
return $default(_that.tier,_that.status,_that.billingCycle,_that.gatewayProvider,_that.currentPeriodEnd,_that.paymentGatewayRef);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionUpdateRequest implements SubscriptionUpdateRequest {
  const _SubscriptionUpdateRequest({required this.tier, this.status = 'active', @JsonKey(name: 'billing_cycle') this.billingCycle = 'monthly', @JsonKey(name: 'gateway_provider') this.gatewayProvider, @JsonKey(name: 'current_period_end') this.currentPeriodEnd, @JsonKey(name: 'payment_gateway_ref') this.paymentGatewayRef});
  factory _SubscriptionUpdateRequest.fromJson(Map<String, dynamic> json) => _$SubscriptionUpdateRequestFromJson(json);

@override final  String tier;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'billing_cycle') final  String billingCycle;
@override@JsonKey(name: 'gateway_provider') final  String? gatewayProvider;
@override@JsonKey(name: 'current_period_end') final  DateTime? currentPeriodEnd;
@override@JsonKey(name: 'payment_gateway_ref') final  String? paymentGatewayRef;

/// Create a copy of SubscriptionUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionUpdateRequestCopyWith<_SubscriptionUpdateRequest> get copyWith => __$SubscriptionUpdateRequestCopyWithImpl<_SubscriptionUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionUpdateRequest&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.gatewayProvider, gatewayProvider) || other.gatewayProvider == gatewayProvider)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.paymentGatewayRef, paymentGatewayRef) || other.paymentGatewayRef == paymentGatewayRef));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,status,billingCycle,gatewayProvider,currentPeriodEnd,paymentGatewayRef);

@override
String toString() {
  return 'SubscriptionUpdateRequest(tier: $tier, status: $status, billingCycle: $billingCycle, gatewayProvider: $gatewayProvider, currentPeriodEnd: $currentPeriodEnd, paymentGatewayRef: $paymentGatewayRef)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionUpdateRequestCopyWith<$Res> implements $SubscriptionUpdateRequestCopyWith<$Res> {
  factory _$SubscriptionUpdateRequestCopyWith(_SubscriptionUpdateRequest value, $Res Function(_SubscriptionUpdateRequest) _then) = __$SubscriptionUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
 String tier, String status,@JsonKey(name: 'billing_cycle') String billingCycle,@JsonKey(name: 'gateway_provider') String? gatewayProvider,@JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,@JsonKey(name: 'payment_gateway_ref') String? paymentGatewayRef
});




}
/// @nodoc
class __$SubscriptionUpdateRequestCopyWithImpl<$Res>
    implements _$SubscriptionUpdateRequestCopyWith<$Res> {
  __$SubscriptionUpdateRequestCopyWithImpl(this._self, this._then);

  final _SubscriptionUpdateRequest _self;
  final $Res Function(_SubscriptionUpdateRequest) _then;

/// Create a copy of SubscriptionUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tier = null,Object? status = null,Object? billingCycle = null,Object? gatewayProvider = freezed,Object? currentPeriodEnd = freezed,Object? paymentGatewayRef = freezed,}) {
  return _then(_SubscriptionUpdateRequest(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,billingCycle: null == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String,gatewayProvider: freezed == gatewayProvider ? _self.gatewayProvider : gatewayProvider // ignore: cast_nullable_to_non_nullable
as String?,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentGatewayRef: freezed == paymentGatewayRef ? _self.paymentGatewayRef : paymentGatewayRef // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
