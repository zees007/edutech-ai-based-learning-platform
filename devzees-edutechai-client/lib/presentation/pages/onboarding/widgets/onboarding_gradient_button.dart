import 'package:flutter/material.dart';
import '../../../widgets/gradient_button.dart';

/// Circular "next" arrow button with brand gradient, used on slides 1 & 2.
class OnboardingNextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingNextButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GradientButton.icon(
      icon: Icons.arrow_forward_rounded,
      iconSize: 22,
      width: 52,
      height: 52,
      shape: BoxShape.circle,
      onPressed: onPressed,
    );
  }
}

/// Full-width gradient "Get Started" pill button, used on slide 3.
class OnboardingGetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingGetStartedButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      text: 'Get Started',
      icon: Icons.arrow_forward_rounded,
      iconSize: 18,
      width: double.infinity,
      height: null,
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: BorderRadius.circular(100),
      showShadow: false,
      enableHoverEffects: false,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      onPressed: onPressed,
    );
  }
}
