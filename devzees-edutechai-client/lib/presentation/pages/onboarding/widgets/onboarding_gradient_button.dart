import 'package:flutter/material.dart';
import '../theme/onboarding_colors.dart';

/// Circular "next" arrow button with gradient glow, used on slides 1 & 2.
class OnboardingNextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingNextButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: OnboardingColors.actionButtonGradient,
          boxShadow: const [
            BoxShadow(
              color: OnboardingColors.buttonShadowPurple,
              blurRadius: 25,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: OnboardingColors.buttonShadowCyan,
              blurRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

/// Full-width gradient "Get Started" pill button, used on slide 3.
class OnboardingGetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingGetStartedButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: OnboardingColors.getStartedButtonGradient,
          boxShadow: const [
            BoxShadow(
              color: Color(0x739D4EDD), // rgba(157, 78, 221, 0.45)
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get Started',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
