import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/services/razorpay_checkout_service.dart';
import '../../../../../core/services/subscription_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../data/models/subscription/payment_models.dart';
import '../../../../widgets/gradient_button.dart';

class CheckoutReviewDialog extends ConsumerStatefulWidget {
  final String targetTier; // 'pro' or 'ultra'
  final String billingCycle; // 'monthly' or 'annual'
  final double basePrice;

  const CheckoutReviewDialog({
    super.key,
    required this.targetTier,
    required this.billingCycle,
    required this.basePrice,
  });

  @override
  ConsumerState<CheckoutReviewDialog> createState() => _CheckoutReviewDialogState();
}

class _CheckoutReviewDialogState extends ConsumerState<CheckoutReviewDialog> {
  final TextEditingController _couponController = TextEditingController();
  bool _isValidatingCoupon = false;
  bool _isProcessingPayment = false;
  String? _couponError;
  String? _paymentError;
  CouponValidationResult? _appliedCoupon;
  bool _paymentSuccess = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  double get _finalAmount {
    if (_appliedCoupon != null && _appliedCoupon!.valid) {
      return _appliedCoupon!.finalPrice;
    }
    return widget.basePrice;
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isValidatingCoupon = true;
      _couponError = null;
    });

    try {
      final res = await ref.read(subscriptionServiceProvider).validateCoupon(
            couponCode: code,
            tier: widget.targetTier,
            billingCycle: widget.billingCycle,
          );

      if (res.valid) {
        setState(() {
          _appliedCoupon = res;
          _couponError = null;
        });
      } else {
        setState(() {
          _couponError = res.message;
          _appliedCoupon = null;
        });
      }
    } catch (e) {
      setState(() {
        _couponError = e.toString().replaceAll('Exception: ', '');
        _appliedCoupon = null;
      });
    } finally {
      setState(() {
        _isValidatingCoupon = false;
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponController.clear();
      _appliedCoupon = null;
      _couponError = null;
    });
  }

  Future<void> _startRazorpayPayment() async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      setState(() {
        _paymentError = 'User session not found. Please log in again.';
      });
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _paymentError = null;
    });

    try {
      final subService = ref.read(subscriptionServiceProvider);

      // 1. Create Razorpay Order on Backend
      final orderReq = CreateOrderRequest(
        tier: widget.targetTier,
        billingCycle: widget.billingCycle,
        gatewayProvider: 'razorpay',
        couponCode: _appliedCoupon?.couponCode,
        currency: 'USD',
      );

      final orderRes = await subService.createOrder(orderReq);

      // 2. Launch Razorpay Popup via Interop
      final payResult = await launchRazorpayCheckout(
        keyId: orderRes.keyId,
        orderId: orderRes.orderId,
        amountSubunits: orderRes.amountSubunits,
        currency: orderRes.currency,
        name: 'EduTech AI',
        description: '${widget.targetTier.toUpperCase()} Plan (${widget.billingCycle})',
        userEmail: orderRes.userEmail ?? user.email,
        userMobile: orderRes.userMobile ?? (user.mobile ?? ''),
        userName: orderRes.userName ?? '${user.firstName} ${user.lastName}',
      );

      if (!payResult.success) {
        setState(() {
          _paymentError = payResult.errorMessage ?? 'Payment cancelled or dismissed.';
        });
        return;
      }

      // 3. Complete Checkout & Cryptographic Signature Verification
      final chkReq = CheckoutPaymentRequest(
        tier: widget.targetTier,
        billingCycle: widget.billingCycle,
        gatewayProvider: 'razorpay',
        currency: orderRes.currency,
        couponCode: _appliedCoupon?.couponCode,
        razorpayOrderId: payResult.orderId ?? orderRes.orderId,
        razorpayPaymentId: payResult.paymentId,
        razorpaySignature: payResult.signature,
      );

      final chkRes = await subService.checkoutAndVerify(chkReq);

      if (chkRes.success) {
        setState(() {
          _paymentSuccess = true;
        });
        // Invalidate user profile to update permissions/roles across the app
        ref.invalidate(userProvider);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _paymentError = chkRes.message;
        });
      }
    } catch (e) {
      setState(() {
        _paymentError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppColors.isDark;
    final isUltra = widget.targetTier.toLowerCase() == 'ultra';

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF131525).withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isUltra ? AppColors.accentPink.withValues(alpha: 0.5) : AppColors.glassBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isUltra ? AppColors.accentPink : AppColors.primary).withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: _paymentSuccess ? _buildSuccessView() : _buildReviewContent(isDark, isUltra),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 24),
        Text('Upgrade Complete! 🎉', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Text(
          'You are now on the ${widget.targetTier.toUpperCase()} tier! All advanced capabilities and higher limits are immediately active.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReviewContent(bool isDark, bool isUltra) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Summary', style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(
                  'Review your subscription upgrade details',
                  style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Plan Item Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2138) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isUltra
                      ? const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFFEC4899)])
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isUltra ? Icons.auto_awesome : Icons.bolt_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.targetTier.toUpperCase()} Plan',
                      style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Billed ${widget.billingCycle}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${widget.basePrice.toStringAsFixed(2)}',
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Coupon Section
        Text('Promo or Coupon Code', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. EDU20',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.local_offer_outlined, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E2138) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _isValidatingCoupon ? null : _applyCoupon,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isValidatingCoupon
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),

        // Applied Coupon Pill or Error
        if (_appliedCoupon != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _appliedCoupon!.message,
                    style: AppTextStyles.caption.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: _removeCoupon,
                  child: const Icon(Icons.close_rounded, size: 16, color: AppColors.emerald),
                ),
              ],
            ),
          ),
        ],

        if (_couponError != null) ...[
          const SizedBox(height: 8),
          Text(
            _couponError!,
            style: AppTextStyles.caption.copyWith(color: AppColors.rose),
          ),
        ],

        const SizedBox(height: 20),
        Divider(color: AppColors.glassBorder),
        const SizedBox(height: 12),

        // Price Breakdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
            Text('\$${widget.basePrice.toStringAsFixed(2)}', style: AppTextStyles.body2),
          ],
        ),
        if (_appliedCoupon != null && _appliedCoupon!.discountAmount > 0) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discount (${_appliedCoupon!.discountPercent.toStringAsFixed(0)}%)',
                style: AppTextStyles.body2.copyWith(color: AppColors.emerald),
              ),
              Text(
                '- \$${_appliedCoupon!.discountAmount.toStringAsFixed(2)}',
                style: AppTextStyles.body2.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total Due Today', style: AppTextStyles.h4),
            Text(
              '\$${_finalAmount.toStringAsFixed(2)}',
              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
            ),
          ],
        ),

        // Payment Error Alert Banner
        if (_paymentError != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.rose.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.rose.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.rose, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _paymentError!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.rose),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Razorpay CTA
        GradientButton(
          text: _isProcessingPayment ? 'Connecting to Razorpay...' : 'Pay with Razorpay ⚡',
          width: double.infinity,
          isLoading: _isProcessingPayment,
          onPressed: () {
            if (!_isProcessingPayment) {
              _startRazorpayPayment();
            }
          },
        ),
        const SizedBox(height: 12),

        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Secured by Razorpay (UPI, Cards, Netbanking)',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
