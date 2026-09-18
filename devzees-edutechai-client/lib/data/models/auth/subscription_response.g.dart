// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionResponse _$SubscriptionResponseFromJson(
  Map<String, dynamic> json,
) => _SubscriptionResponse(
  id: (json['id'] as num).toInt(),
  userId: json['user_id'] as String,
  tier: json['tier'] as String,
  status: json['status'] as String,
  billingCycle: json['billing_cycle'] as String?,
  priceAmount: (json['price_amount'] as num?)?.toDouble(),
  currentPeriodStart: json['current_period_start'] == null
      ? null
      : DateTime.parse(json['current_period_start'] as String),
  currentPeriodEnd: json['current_period_end'] == null
      ? null
      : DateTime.parse(json['current_period_end'] as String),
  gatewayProvider: json['gateway_provider'] as String?,
  gatewaySubscriptionId: json['gateway_subscription_id'] as String?,
  gatewayCustomerId: json['gateway_customer_id'] as String?,
  paymentGatewayRef: json['payment_gateway_ref'] as String?,
  cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
  autoRenew: json['auto_renew'] as bool? ?? true,
);

Map<String, dynamic> _$SubscriptionResponseToJson(
  _SubscriptionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'tier': instance.tier,
  'status': instance.status,
  'billing_cycle': instance.billingCycle,
  'price_amount': instance.priceAmount,
  'current_period_start': instance.currentPeriodStart?.toIso8601String(),
  'current_period_end': instance.currentPeriodEnd?.toIso8601String(),
  'gateway_provider': instance.gatewayProvider,
  'gateway_subscription_id': instance.gatewaySubscriptionId,
  'gateway_customer_id': instance.gatewayCustomerId,
  'payment_gateway_ref': instance.paymentGatewayRef,
  'cancel_at_period_end': instance.cancelAtPeriodEnd,
  'auto_renew': instance.autoRenew,
};
