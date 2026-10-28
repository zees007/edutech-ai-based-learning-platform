import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../data/models/subscription/payment_models.dart';
import '../../../../../data/models/auth/user_current_profile_response.dart';
import '../../../../widgets/gradient_button.dart';
import '../../../../widgets/promo_countdown_clock.dart';

/// Dialog shown to users on the Ultra tier when claiming a festive promotional offer.
/// Allows extending / stacking an additional 1-year Ultra subscription at the discounted promotional rate.
class UltraExtensionDialog extends StatelessWidget {
  final PromoBannerModel promoBanner;
  final PricingCatalogModel catalog;
  final UserCurrentProfileResponse? user;
  final VoidCallback onExtend;

  const UltraExtensionDialog({
    super.key,
    required this.promoBanner,
    required this.catalog,
    required this.user,
    required this.onExtend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;
    final ultraPricing = catalog.getTier('ultra');
    final regularAnnual = ultraPricing.annual > 0 ? ultraPricing.annual : 470.0;
    final discount = promoBanner.discountPercent > 0 ? promoBanner.discountPercent : 50.0;
    final discountedAnnual = regularAnnual * (1.0 - (discount / 100.0));

    final currentEnd = user?.subscription?.currentPeriodEnd;
    final String currentEndFormatted = currentEnd != null
        ? '${currentEnd.year}-${currentEnd.month.toString().padLeft(2, '0')}-${currentEnd.day.toString().padLeft(2, '0')}'
        : 'Active';

    final DateTime newEnd = (currentEnd != null && currentEnd.isAfter(DateTime.now()))
        ? currentEnd.add(const Duration(days: 365))
        : DateTime.now().add(const Duration(days: 365));
    final String newEndFormatted =
        '${newEnd.year}-${newEnd.month.toString().padLeft(2, '0')}-${newEnd.day.toString().padLeft(2, '0')}';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131525) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.45 : 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                  blurRadius: 36,
                  spreadRadius: 4,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with VIP crown and Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Text('👑', style: TextStyle(fontSize: 22)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: AppColors.textSecondary,
                      splashRadius: 18,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dynamic Campaign Badge (displays whatever text is active, e.g. Diwali / New Year)
                if (promoBanner.text.isNotEmpty || promoBanner.remainingTimeLabel != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            promoBanner.text.isNotEmpty ? promoBanner.text : 'Special Offer',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                        if (promoBanner.validUntilDate != null) ...[
                          const SizedBox(width: 8),
                          PromoCountdownClock(
                            targetDate: promoBanner.validUntilDate!,
                            isCompact: true,
                          ),
                        ] else if (promoBanner.remainingTimeLabel != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, size: 11, color: Color(0xFFFBBF24)),
                                const SizedBox(width: 3),
                                Text(
                                  'Ends in ${promoBanner.remainingTimeLabel}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFDE68A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Title
                Text(
                  'Extend Your Ultra Plan (${discount.toInt()}% OFF)',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Explanation body
                Text(
                  'You are already enjoying our top-tier Ultra features! During this limited-time promotion, you can stack an additional 1 year onto your current subscription at ${discount.toInt()}% OFF using coupon code ${promoBanner.couponCode}.',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),

                // Date Stacking Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2138) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT EXPIRY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentEndFormatted,
                              style: AppTextStyles.subtitle2.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, size: 20, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NEW EXTENDED EXPIRY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              newEndFormatted,
                              style: AppTextStyles.subtitle2.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Pricing Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Regular Price: \$${regularAnnual.toStringAsFixed(0)}/yr',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '\$${discountedAnnual.toStringAsFixed(2)}',
                              style: AppTextStyles.h2.copyWith(
                                color: const Color(0xFFF59E0B),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(' / year', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Keep Current Plan',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GradientButton(
                        text: 'Extend 1 Year (${discount.toInt()}% OFF)',
                        icon: Icons.bolt_rounded,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onExtend();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
