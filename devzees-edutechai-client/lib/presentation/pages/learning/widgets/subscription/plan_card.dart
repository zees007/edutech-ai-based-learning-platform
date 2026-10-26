import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../widgets/glass_card.dart';
import '../../../../widgets/gradient_button.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String billingCycle;
  final String description;
  final List<String> features;
  final String buttonText;
  final bool isCurrentPlan;
  final VoidCallback? onButtonTap;
  final bool useSpacer;
  final double? width;
  final String? badgeText;
  final bool isFeatured;
  final EdgeInsetsGeometry? padding;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.billingCycle,
    required this.description,
    required this.features,
    required this.buttonText,
    this.isCurrentPlan = false,
    this.onButtonTap,
    this.useSpacer = false,
    this.width = 340,
    this.badgeText,
    this.isFeatured = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppColors.isDark;

    final Widget badgeWidget;
    if (isCurrentPlan) {
      badgeWidget = Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPink.withValues(alpha: 0.35),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Text(
          'CURRENT PLAN ⭐',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      );
    } else if (badgeText != null) {
      badgeWidget = Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isFeatured
              ? AppColors.primary.withValues(alpha: 0.18)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFeatured
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.glassBorder,
          ),
        ),
        child: Text(
          badgeText!,
          style: TextStyle(
            color: isFeatured ? (isDark ? AppColors.blueSoft : AppColors.primary) : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      );
    } else {
      badgeWidget = const SizedBox.shrink();
    }

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCurrentPlan || badgeText != null)
          Center(child: badgeWidget),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: isFeatured
                    ? AppColors.accentPink
                    : (isDark ? AppColors.textPrimary : const Color(0xFF0F172A)),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isFeatured && !isCurrentPlan)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: AppColors.accentPink,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              price,
              style: AppTextStyles.h1.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '/$billingCycle',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        Divider(color: AppColors.glassBorder),
        const SizedBox(height: 20),
        ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      f,
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        if (useSpacer) const Spacer() else const SizedBox(height: 24),
        if (!isCurrentPlan) ...[
          GradientButton(
            text: buttonText,
            width: double.infinity,
            onPressed: onButtonTap ?? () {},
          ),
        ] else ...[
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.emerald.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Your Active Plan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.emerald,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: width,
      child: GlassCard(
        isGlowing: isFeatured || isCurrentPlan,
        padding: padding ?? const EdgeInsets.all(28),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: content,
        ),
      ),
    );
  }
}
