import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/onboarding_slide_data.dart';

/// Renders a single onboarding slide with:
/// - Eyebrow text (brand accent uppercase)
/// - Two-line headline (solid white + signature primary gradient)
/// - Subtitle paragraph
/// - Clean hero illustration with parallax translation against solid background
class OnboardingSlide extends StatelessWidget {
  final OnboardingSlideData data;
  /// Normalized page offset for parallax effect (0.0 = perfectly centered)
  final double pageOffset;

  const OnboardingSlide({
    super.key,
    required this.data,
    this.pageOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero Copy Section ──
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow
              Text(
                data.eyebrow,
                style: const TextStyle(
                  color: AppColors.purpleLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 6),
              // Title Line 1 (solid white)
              Text(
                data.titleLine1,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.18,
                  letterSpacing: -0.5,
                ),
              ),
              // Title Line 2 (signature primary gradient)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  if (bounds.width <= 0 || bounds.height <= 0) {
                    return const LinearGradient(
                      colors: [Colors.transparent, Colors.transparent],
                    ).createShader(const Rect.fromLTWH(0, 0, 1, 1));
                  }
                  return AppColors.primaryGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  );
                },
                child: Text(
                  data.titleLine2Gradient,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                data.subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),

        // ── Hero Image Area (Edge-to-edge with top/bottom fade) ──
        Expanded(
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full-width illustration filling edge-to-edge
                Image.asset(
                  data.imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.textMuted,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),

                // Top fade overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.background,
                            AppColors.background.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom fade overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.background,
                            AppColors.background.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
