import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_update_request.freezed.dart';
part 'subscription_update_request.g.dart';

@freezed
abstract class SubscriptionUpdateRequest with _$SubscriptionUpdateRequest {
  const factory SubscriptionUpdateRequest({
    required String tier,
    @Default('active') String status,
    @JsonKey(name: 'billing_cycle') @Default('monthly') String billingCycle,
    @JsonKey(name: 'gateway_provider') String? gatewayProvider,
    @JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,
    @JsonKey(name: 'payment_gateway_ref') String? paymentGatewayRef,
  }) = _SubscriptionUpdateRequest;

  factory SubscriptionUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionUpdateRequestFromJson(json);
}
