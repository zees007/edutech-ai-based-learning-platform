import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/subscription/payment_models.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

final pricingCatalogProvider = FutureProvider<PricingCatalogModel>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return await service.getPricingCatalog();
});

class SubscriptionService {
  final Dio _dio;

  SubscriptionService() : _dio = ApiClient.instance.dio;

  /// Creates a Razorpay (or other provider) order session
  Future<CreateOrderResponse> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.subscriptionCreateOrder,
        data: request.toJson(),
      );
      return CreateOrderResponse.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['errors'] ?? e.message ?? 'Failed to create payment order.';
      throw Exception(msg.toString());
    }
  }

  /// Validates a promotional discount coupon
  Future<CouponValidationResult> validateCoupon({
    required String couponCode,
    required String tier,
    String billingCycle = 'monthly',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.subscriptionValidateCoupon,
        data: {
          'coupon_code': couponCode.trim(),
          'tier': tier.toLowerCase().trim(),
          'billing_cycle': billingCycle.toLowerCase().trim(),
        },
      );
      return CouponValidationResult.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['errors'] ?? e.message ?? 'Failed to validate coupon.';
      throw Exception(msg.toString());
    }
  }

  /// Verifies Razorpay payment signature & upgrades subscription
  Future<CheckoutPaymentResponse> checkoutAndVerify(CheckoutPaymentRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.subscriptionCheckout,
        data: request.toJson(),
      );
      return CheckoutPaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['errors'] ?? e.message ?? 'Payment verification failed.';
      throw Exception(msg.toString());
    }
  }

  /// Retrieves payment transaction history ledger for the user
  Future<List<PaymentTransactionModel>> getTransactions(String userId) async {
    try {
      final response = await _dio.get(
        ApiConstants.userSubscriptionTransactions(userId),
      );
      final list = response.data as List? ?? [];
      return list
          .map((item) => PaymentTransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['errors'] ?? e.message ?? 'Failed to load transaction history.';
      throw Exception(msg.toString());
    }
  }

  /// Cancels subscription auto-renewal or requests immediate cancellation
  Future<void> cancelSubscription(
    String userId, {
    String? reason,
    bool immediate = false,
  }) async {
    try {
      await _dio.post(
        ApiConstants.userSubscriptionCancel(userId),
        data: {
          'immediate': immediate,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['errors'] ?? e.message ?? 'Failed to cancel subscription.';
      throw Exception(msg.toString());
    }
  }

  /// Fetches real-time pricing catalog from backend settings
  Future<PricingCatalogModel> getPricingCatalog() async {
    try {
      final response = await _dio.get(ApiConstants.subscriptionPricingCatalog);
      return PricingCatalogModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      return PricingCatalogModel.defaultCatalog;
    } catch (_) {
      return PricingCatalogModel.defaultCatalog;
    }
  }
}
