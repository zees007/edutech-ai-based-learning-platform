import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

/// Subscription tier badge pill with color-coded background.
class TierBadge extends StatelessWidget {
  final String tier;

  const TierBadge({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    final t = tier.toLowerCase();
    Color bgColor;
    String label;

    switch (t) {
      case 'pro':
        bgColor = AppColors.accentBlue;
        label = 'PRO';
        break;
      case 'ultra':
        bgColor = AppColors.purpleDeep;
        label = 'ULTRA';
        break;
      default:
        bgColor = AppColors.slate700;
        label = 'FREE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(
          color: Colors.white,
          fontSize: 11,
        ),
      ),
    );
  }
}
