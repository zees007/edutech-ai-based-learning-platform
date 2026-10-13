import 'package:flutter/material.dart';
import '../theme/onboarding_colors.dart';

/// Glass-morphic feature highlight card displayed at the bottom of each onboarding slide.
/// Matches the "glass-card" / "feature-glass-card" pattern from the reference designs.
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OnboardingColors.glassCardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: OnboardingColors.glassCardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000), // rgba(0, 0, 0, 0.6)
            blurRadius: 36,
            offset: Offset(0, 16),
            spreadRadius: -10,
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
              color: OnboardingColors.iconContainerBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: OnboardingColors.iconContainerBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x599D4EDD), // purple glow
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 24,
              color: OnboardingColors.purpleLight,
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
                  style: const TextStyle(
                    color: OnboardingColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: OnboardingColors.textSubtle,
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
