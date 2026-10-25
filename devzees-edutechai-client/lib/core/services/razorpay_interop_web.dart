import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

@JS('openRazorpayCheckout')
external void _openRazorpayCheckout(
  JSString optionsJson,
  JSFunction successCallback,
  JSFunction dismissCallback,
);

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
  final completer = Completer<RazorpayPaymentResult>();

  final options = {
    'key': keyId,
    'amount': amountSubunits,
    'currency': currency,
    'name': name,
    'description': description,
    'order_id': orderId,
    'prefill': {
      'name': userName,
      'email': userEmail,
      'contact': userMobile,
    },
    'theme': {
      'color': '#3B82F6',
    },
  };

  final successCallback = (JSString pId, JSString oId, JSString sig) {
    if (!completer.isCompleted) {
      completer.complete(
        RazorpayPaymentResult(
          success: true,
          paymentId: pId.toDart,
          orderId: oId.toDart,
          signature: sig.toDart,
        ),
      );
    }
  }.toJS;

  final dismissCallback = (JSAny? err) {
    if (!completer.isCompleted) {
      completer.complete(
        RazorpayPaymentResult(
          success: false,
          errorMessage: err != null ? err.toString() : 'Payment dismissed by user.',
        ),
      );
    }
  }.toJS;

  try {
    _openRazorpayCheckout(
      jsonEncode(options).toJS,
      successCallback,
      dismissCallback,
    );
  } catch (e) {
    if (!completer.isCompleted) {
      completer.complete(
        RazorpayPaymentResult(
          success: false,
          errorMessage: 'Failed to launch Razorpay overlay: $e',
        ),
      );
    }
  }

  return completer.future;
}
