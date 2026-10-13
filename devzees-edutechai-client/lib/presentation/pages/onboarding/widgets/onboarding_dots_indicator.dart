import 'package:flutter/material.dart';
import '../theme/onboarding_colors.dart';

/// Animated pagination dots indicator for onboarding slides.
/// Active dot renders as an elongated gradient pill with glow shadow;
/// inactive dots are small muted circles.
class OnboardingDotsIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingDotsIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isActive ? OnboardingColors.activeDotGradient : null,
            color: isActive ? null : OnboardingColors.dotInactive,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: OnboardingColors.vividPurple.withValues(alpha: 0.7),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
