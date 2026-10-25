import 'dart:async';

class RazorpayPaymentResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;

  const RazorpayPaymentResult({
    required this.success,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
  });
}

Future<RazorpayPaymentResult> launchRazorpayCheckout({
  required String keyId,
  required String orderId,
  required int amountSubunits,
  required String currency,
  required String name,
  required String description,
  required String userEmail,
  required String userMobile,
  required String userName,
}) async {
  // Stub for non-web environments (Desktop testing & simulation)
  await Future.delayed(const Duration(milliseconds: 600));
  return RazorpayPaymentResult(
    success: true,
    paymentId: 'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
    orderId: orderId,
    signature: 'sig_mock_client',
  );
}
