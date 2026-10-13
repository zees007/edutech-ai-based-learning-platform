import 'package:flutter/material.dart';
import '../models/onboarding_slide_data.dart';
import '../theme/onboarding_colors.dart';

/// Renders a single onboarding slide with:
/// - Eyebrow text (purple uppercase)
/// - Two-line headline (white + gradient)
/// - Subtitle paragraph
/// - Hero image with radial mask + ambient glow
/// - Top/bottom gradient overlays for seamless edge blending
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
    final screenHeight = MediaQuery.of(context).size.height;

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
                  color: OnboardingColors.vividPurple,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 6),
              // Title Line 1 (white)
              Text(
                data.titleLine1,
                style: const TextStyle(
                  color: OnboardingColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.18,
                  letterSpacing: -0.5,
                ),
              ),
              // Title Line 2 (gradient)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  if (bounds.width <= 0 || bounds.height <= 0) {
                    return const LinearGradient(
                      colors: [Colors.transparent, Colors.transparent],
                    ).createShader(const Rect.fromLTWH(0, 0, 1, 1));
                  }
                  return OnboardingColors.textGradient.createShader(
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
                style: const TextStyle(
                  color: OnboardingColors.textSubtle,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),

        // ── Hero Image Area ──
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient purple glow behind image
              Positioned(
                top: screenHeight * 0.04,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7C3AED).withValues(alpha: 0.20),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Hero image with radial mask and subtle parallax
              Transform.translate(
                offset: Offset(pageOffset * 30, 0), // Parallax effect
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) {
                      return RadialGradient(
                        center: Alignment.center,
                        radius: 0.85,
                        colors: [
                          Colors.black,
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.65, 1.0],
                      ).createShader(bounds);
                    },
                    child: Image.asset(
                      data.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: OnboardingColors.scaffoldBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: OnboardingColors.textMuted,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Top gradient overlay for seamless blend
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 80,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          OnboardingColors.scaffoldBg,
                          Color(0x00060814),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom gradient overlay for seamless blend
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 100,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          OnboardingColors.scaffoldBg,
                          Color(0x00060814),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
