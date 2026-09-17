// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionResponse {

 int get id;@JsonKey(name: 'user_id') String get userId; String get tier; String get status;@JsonKey(name: 'billing_cycle') String? get billingCycle;@JsonKey(name: 'price_amount') double? get priceAmount;@JsonKey(name: 'current_period_start') DateTime? get currentPeriodStart;@JsonKey(name: 'current_period_end') DateTime? get currentPeriodEnd;@JsonKey(name: 'gateway_provider') String? get gatewayProvider;@JsonKey(name: 'gateway_subscription_id') String? get gatewaySubscriptionId;@JsonKey(name: 'gateway_customer_id') String? get gatewayCustomerId;@JsonKey(name: 'payment_gateway_ref') String? get paymentGatewayRef;@JsonKey(name: 'cancel_at_period_end') bool get cancelAtPeriodEnd;@JsonKey(name: 'auto_renew') bool get autoRenew;
/// Create a copy of SubscriptionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionResponseCopyWith<SubscriptionResponse> get copyWith => _$SubscriptionResponseCopyWithImpl<SubscriptionResponse>(this as SubscriptionResponse, _$identity);

  /// Serializes this SubscriptionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.priceAmount, priceAmount) || other.priceAmount == priceAmount)&&(identical(other.currentPeriodStart, currentPeriodStart) || other.currentPeriodStart == currentPeriodStart)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.gatewayProvider, gatewayProvider) || other.gatewayProvider == gatewayProvider)&&(identical(other.gatewaySubscriptionId, gatewaySubscriptionId) || other.gatewaySubscriptionId == gatewaySubscriptionId)&&(identical(other.gatewayCustomerId, gatewayCustomerId) || other.gatewayCustomerId == gatewayCustomerId)&&(identical(other.paymentGatewayRef, paymentGatewayRef) || other.paymentGatewayRef == paymentGatewayRef)&&(identical(other.cancelAtPeriodEnd, cancelAtPeriodEnd) || other.cancelAtPeriodEnd == cancelAtPeriodEnd)&&(identical(other.autoRenew, autoRenew) || other.autoRenew == autoRenew));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,tier,status,billingCycle,priceAmount,currentPeriodStart,currentPeriodEnd,gatewayProvider,gatewaySubscriptionId,gatewayCustomerId,paymentGatewayRef,cancelAtPeriodEnd,autoRenew);

@override
String toString() {
  return 'SubscriptionResponse(id: $id, userId: $userId, tier: $tier, status: $status, billingCycle: $billingCycle, priceAmount: $priceAmount, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd, gatewayProvider: $gatewayProvider, gatewaySubscriptionId: $gatewaySubscriptionId, gatewayCustomerId: $gatewayCustomerId, paymentGatewayRef: $paymentGatewayRef, cancelAtPeriodEnd: $cancelAtPeriodEnd, autoRenew: $autoRenew)';
}


}

/// @nodoc
abstract mixin class $SubscriptionResponseCopyWith<$Res>  {
  factory $SubscriptionResponseCopyWith(SubscriptionResponse value, $Res Function(SubscriptionResponse) _then) = _$SubscriptionResponseCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'user_id') String userId, String tier, String status,@JsonKey(name: 'billing_cycle') String? billingCycle,@JsonKey(name: 'price_amount') double? priceAmount,@JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,@JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,@JsonKey(name: 'gateway_provider') String? gatewayProvider,@JsonKey(name: 'gateway_subscription_id') String? gatewaySubscriptionId,@JsonKey(name: 'gateway_customer_id') String? gatewayCustomerId,@JsonKey(name: 'payment_gateway_ref') String? paymentGatewayRef,@JsonKey(name: 'cancel_at_period_end') bool cancelAtPeriodEnd,@JsonKey(name: 'auto_renew') bool autoRenew
});




}
/// @nodoc
class _$SubscriptionResponseCopyWithImpl<$Res>
    implements $SubscriptionResponseCopyWith<$Res> {
  _$SubscriptionResponseCopyWithImpl(this._self, this._then);

  final SubscriptionResponse _self;
  final $Res Function(SubscriptionResponse) _then;

/// Create a copy of SubscriptionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? tier = null,Object? status = null,Object? billingCycle = freezed,Object? priceAmount = freezed,Object? currentPeriodStart = freezed,Object? currentPeriodEnd = freezed,Object? gatewayProvider = freezed,Object? gatewaySubscriptionId = freezed,Object? gatewayCustomerId = freezed,Object? paymentGatewayRef = freezed,Object? cancelAtPeriodEnd = null,Object? autoRenew = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,billingCycle: freezed == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String?,priceAmount: freezed == priceAmount ? _self.priceAmount : priceAmount // ignore: cast_nullable_to_non_nullable
as double?,currentPeriodStart: freezed == currentPeriodStart ? _self.currentPeriodStart : currentPeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,gatewayProvider: freezed == gatewayProvider ? _self.gatewayProvider : gatewayProvider // ignore: cast_nullable_to_non_nullable
as String?,gatewaySubscriptionId: freezed == gatewaySubscriptionId ? _self.gatewaySubscriptionId : gatewaySubscriptionId // ignore: cast_nullable_to_non_nullable
as String?,gatewayCustomerId: freezed == gatewayCustomerId ? _self.gatewayCustomerId : gatewayCustomerId // ignore: cast_nullable_to_non_nullable
as String?,paymentGatewayRef: freezed == paymentGatewayRef ? _self.paymentGatewayRef : paymentGatewayRef // ignore: cast_nullable_to_non_nullable
as String?,cancelAtPeriodEnd: null == cancelAtPeriodEnd ? _self.cancelAtPeriodEnd : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
as bool,autoRenew: null == autoRenew ? _self.autoRenew : autoRenew // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionResponse].
extension SubscriptionResponsePatterns on SubscriptionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionResponse value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'user_id')  String userId,  String tier,  String status, @JsonKey(name: 'billing_cycle')  String? billingCycle, @JsonKey(name: 'price_amount')  double? priceAmount, @JsonKey(name: 'current_period_start')  DateTime? currentPeriodStart, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'gateway_provider')  String? gatewayProvider, @JsonKey(name: 'gateway_subscription_id')  String? gatewaySubscriptionId, @JsonKey(name: 'gateway_customer_id')  String? gatewayCustomerId, @JsonKey(name: 'payment_gateway_ref')  String? paymentGatewayRef, @JsonKey(name: 'cancel_at_period_end')  bool cancelAtPeriodEnd, @JsonKey(name: 'auto_renew')  bool autoRenew)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionResponse() when $default != null:
return $default(_that.id,_that.userId,_that.tier,_that.status,_that.billingCycle,_that.priceAmount,_that.currentPeriodStart,_that.currentPeriodEnd,_that.gatewayProvider,_that.gatewaySubscriptionId,_that.gatewayCustomerId,_that.paymentGatewayRef,_that.cancelAtPeriodEnd,_that.autoRenew);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'user_id')  String userId,  String tier,  String status, @JsonKey(name: 'billing_cycle')  String? billingCycle, @JsonKey(name: 'price_amount')  double? priceAmount, @JsonKey(name: 'current_period_start')  DateTime? currentPeriodStart, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'gateway_provider')  String? gatewayProvider, @JsonKey(name: 'gateway_subscription_id')  String? gatewaySubscriptionId, @JsonKey(name: 'gateway_customer_id')  String? gatewayCustomerId, @JsonKey(name: 'payment_gateway_ref')  String? paymentGatewayRef, @JsonKey(name: 'cancel_at_period_end')  bool cancelAtPeriodEnd, @JsonKey(name: 'auto_renew')  bool autoRenew)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionResponse():
return $default(_that.id,_that.userId,_that.tier,_that.status,_that.billingCycle,_that.priceAmount,_that.currentPeriodStart,_that.currentPeriodEnd,_that.gatewayProvider,_that.gatewaySubscriptionId,_that.gatewayCustomerId,_that.paymentGatewayRef,_that.cancelAtPeriodEnd,_that.autoRenew);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'user_id')  String userId,  String tier,  String status, @JsonKey(name: 'billing_cycle')  String? billingCycle, @JsonKey(name: 'price_amount')  double? priceAmount, @JsonKey(name: 'current_period_start')  DateTime? currentPeriodStart, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'gateway_provider')  String? gatewayProvider, @JsonKey(name: 'gateway_subscription_id')  String? gatewaySubscriptionId, @JsonKey(name: 'gateway_customer_id')  String? gatewayCustomerId, @JsonKey(name: 'payment_gateway_ref')  String? paymentGatewayRef, @JsonKey(name: 'cancel_at_period_end')  bool cancelAtPeriodEnd, @JsonKey(name: 'auto_renew')  bool autoRenew)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionResponse() when $default != null:
return $default(_that.id,_that.userId,_that.tier,_that.status,_that.billingCycle,_that.priceAmount,_that.currentPeriodStart,_that.currentPeriodEnd,_that.gatewayProvider,_that.gatewaySubscriptionId,_that.gatewayCustomerId,_that.paymentGatewayRef,_that.cancelAtPeriodEnd,_that.autoRenew);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionResponse implements SubscriptionResponse {
  const _SubscriptionResponse({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.tier, required this.status, @JsonKey(name: 'billing_cycle') this.billingCycle, @JsonKey(name: 'price_amount') this.priceAmount, @JsonKey(name: 'current_period_start') this.currentPeriodStart, @JsonKey(name: 'current_period_end') this.currentPeriodEnd, @JsonKey(name: 'gateway_provider') this.gatewayProvider, @JsonKey(name: 'gateway_subscription_id') this.gatewaySubscriptionId, @JsonKey(name: 'gateway_customer_id') this.gatewayCustomerId, @JsonKey(name: 'payment_gateway_ref') this.paymentGatewayRef, @JsonKey(name: 'cancel_at_period_end') this.cancelAtPeriodEnd = false, @JsonKey(name: 'auto_renew') this.autoRenew = true});
  factory _SubscriptionResponse.fromJson(Map<String, dynamic> json) => _$SubscriptionResponseFromJson(json);

@override final  int id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String tier;
@override final  String status;
@override@JsonKey(name: 'billing_cycle') final  String? billingCycle;
@override@JsonKey(name: 'price_amount') final  double? priceAmount;
@override@JsonKey(name: 'current_period_start') final  DateTime? currentPeriodStart;
@override@JsonKey(name: 'current_period_end') final  DateTime? currentPeriodEnd;
@override@JsonKey(name: 'gateway_provider') final  String? gatewayProvider;
@override@JsonKey(name: 'gateway_subscription_id') final  String? gatewaySubscriptionId;
@override@JsonKey(name: 'gateway_customer_id') final  String? gatewayCustomerId;
@override@JsonKey(name: 'payment_gateway_ref') final  String? paymentGatewayRef;
@override@JsonKey(name: 'cancel_at_period_end') final  bool cancelAtPeriodEnd;
@override@JsonKey(name: 'auto_renew') final  bool autoRenew;

/// Create a copy of SubscriptionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionResponseCopyWith<_SubscriptionResponse> get copyWith => __$SubscriptionResponseCopyWithImpl<_SubscriptionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.priceAmount, priceAmount) || other.priceAmount == priceAmount)&&(identical(other.currentPeriodStart, currentPeriodStart) || other.currentPeriodStart == currentPeriodStart)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.gatewayProvider, gatewayProvider) || other.gatewayProvider == gatewayProvider)&&(identical(other.gatewaySubscriptionId, gatewaySubscriptionId) || other.gatewaySubscriptionId == gatewaySubscriptionId)&&(identical(other.gatewayCustomerId, gatewayCustomerId) || other.gatewayCustomerId == gatewayCustomerId)&&(identical(other.paymentGatewayRef, paymentGatewayRef) || other.paymentGatewayRef == paymentGatewayRef)&&(identical(other.cancelAtPeriodEnd, cancelAtPeriodEnd) || other.cancelAtPeriodEnd == cancelAtPeriodEnd)&&(identical(other.autoRenew, autoRenew) || other.autoRenew == autoRenew));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,tier,status,billingCycle,priceAmount,currentPeriodStart,currentPeriodEnd,gatewayProvider,gatewaySubscriptionId,gatewayCustomerId,paymentGatewayRef,cancelAtPeriodEnd,autoRenew);

@override
String toString() {
  return 'SubscriptionResponse(id: $id, userId: $userId, tier: $tier, status: $status, billingCycle: $billingCycle, priceAmount: $priceAmount, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd, gatewayProvider: $gatewayProvider, gatewaySubscriptionId: $gatewaySubscriptionId, gatewayCustomerId: $gatewayCustomerId, paymentGatewayRef: $paymentGatewayRef, cancelAtPeriodEnd: $cancelAtPeriodEnd, autoRenew: $autoRenew)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionResponseCopyWith<$Res> implements $SubscriptionResponseCopyWith<$Res> {
  factory _$SubscriptionResponseCopyWith(_SubscriptionResponse value, $Res Function(_SubscriptionResponse) _then) = __$SubscriptionResponseCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'user_id') String userId, String tier, String status,@JsonKey(name: 'billing_cycle') String? billingCycle,@JsonKey(name: 'price_amount') double? priceAmount,@JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,@JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,@JsonKey(name: 'gateway_provider') String? gatewayProvider,@JsonKey(name: 'gateway_subscription_id') String? gatewaySubscriptionId,@JsonKey(name: 'gateway_customer_id') String? gatewayCustomerId,@JsonKey(name: 'payment_gateway_ref') String? paymentGatewayRef,@JsonKey(name: 'cancel_at_period_end') bool cancelAtPeriodEnd,@JsonKey(name: 'auto_renew') bool autoRenew
});




}
/// @nodoc
class __$SubscriptionResponseCopyWithImpl<$Res>
    implements _$SubscriptionResponseCopyWith<$Res> {
  __$SubscriptionResponseCopyWithImpl(this._self, this._then);

  final _SubscriptionResponse _self;
  final $Res Function(_SubscriptionResponse) _then;

/// Create a copy of SubscriptionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? tier = null,Object? status = null,Object? billingCycle = freezed,Object? priceAmount = freezed,Object? currentPeriodStart = freezed,Object? currentPeriodEnd = freezed,Object? gatewayProvider = freezed,Object? gatewaySubscriptionId = freezed,Object? gatewayCustomerId = freezed,Object? paymentGatewayRef = freezed,Object? cancelAtPeriodEnd = null,Object? autoRenew = null,}) {
  return _then(_SubscriptionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,billingCycle: freezed == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String?,priceAmount: freezed == priceAmount ? _self.priceAmount : priceAmount // ignore: cast_nullable_to_non_nullable
as double?,currentPeriodStart: freezed == currentPeriodStart ? _self.currentPeriodStart : currentPeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,gatewayProvider: freezed == gatewayProvider ? _self.gatewayProvider : gatewayProvider // ignore: cast_nullable_to_non_nullable
as String?,gatewaySubscriptionId: freezed == gatewaySubscriptionId ? _self.gatewaySubscriptionId : gatewaySubscriptionId // ignore: cast_nullable_to_non_nullable
as String?,gatewayCustomerId: freezed == gatewayCustomerId ? _self.gatewayCustomerId : gatewayCustomerId // ignore: cast_nullable_to_non_nullable
as String?,paymentGatewayRef: freezed == paymentGatewayRef ? _self.paymentGatewayRef : paymentGatewayRef // ignore: cast_nullable_to_non_nullable
as String?,cancelAtPeriodEnd: null == cancelAtPeriodEnd ? _self.cancelAtPeriodEnd : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
as bool,autoRenew: null == autoRenew ? _self.autoRenew : autoRenew // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
