import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_response.freezed.dart';
part 'subscription_response.g.dart';

@freezed
abstract class SubscriptionResponse with _$SubscriptionResponse {
  const factory SubscriptionResponse({
    required int id,
    @JsonKey(name: 'user_id') required String userId,
    required String tier,
    required String status,
    @JsonKey(name: 'billing_cycle') String? billingCycle,
    @JsonKey(name: 'price_amount') double? priceAmount,
    @JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,
    @JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,
    @JsonKey(name: 'gateway_provider') String? gatewayProvider,
    @JsonKey(name: 'gateway_subscription_id') String? gatewaySubscriptionId,
    @JsonKey(name: 'gateway_customer_id') String? gatewayCustomerId,
    @JsonKey(name: 'payment_gateway_ref') String? paymentGatewayRef,
    @JsonKey(name: 'cancel_at_period_end') @Default(false) bool cancelAtPeriodEnd,
    @JsonKey(name: 'auto_renew') @Default(true) bool autoRenew,
  }) = _SubscriptionResponse;

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionResponseFromJson(json);
}
