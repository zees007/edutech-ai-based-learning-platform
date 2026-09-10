import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlowBackground extends StatelessWidget {
  final Widget child;

  const GlowBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Left Glow (Violet)
        Positioned(
          top: -200,
          left: -300,
          child: Container(
            width: 800,
            height: 800,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
        // Center Right Glow (Pink)
        Positioned(
          top: 150,
          right: -250,
          child: Container(
            width: 700,
            height: 700,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentPink.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
        // Bottom Center Glow (Blue)
        Positioned(
          bottom: -200,
          left: MediaQuery.of(context).size.width / 2 - 300,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentBlue.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
        // Main Content
        child,
      ],
    );
  }
}
