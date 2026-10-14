import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Feature highlight card displayed at the bottom of each onboarding slide.
/// Built with the central AppColors design system for dark theme consistency.
class OnboardingFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardGlowBorder.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Icon Container ──
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cardGlowBorder.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.purpleLight,
            ),
          ),
          const SizedBox(width: 14),
          // ── Text Details ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
