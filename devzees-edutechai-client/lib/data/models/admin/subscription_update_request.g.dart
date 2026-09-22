// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionUpdateRequest _$SubscriptionUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _SubscriptionUpdateRequest(
  tier: json['tier'] as String,
  status: json['status'] as String? ?? 'active',
  billingCycle: json['billing_cycle'] as String? ?? 'monthly',
  gatewayProvider: json['gateway_provider'] as String?,
  currentPeriodEnd: json['current_period_end'] == null
      ? null
      : DateTime.parse(json['current_period_end'] as String),
  paymentGatewayRef: json['payment_gateway_ref'] as String?,
);

Map<String, dynamic> _$SubscriptionUpdateRequestToJson(
  _SubscriptionUpdateRequest instance,
) => <String, dynamic>{
  'tier': instance.tier,
  'status': instance.status,
  'billing_cycle': instance.billingCycle,
  'gateway_provider': instance.gatewayProvider,
  'current_period_end': instance.currentPeriodEnd?.toIso8601String(),
  'payment_gateway_ref': instance.paymentGatewayRef,
};
