import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// A sleek, high-fidelity spinner with the EduTech AI app theme gradient
/// and centered glowing sparkle icon.
class AppGradientSpinner extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final List<Color>? colors;
  final bool showSparkle;
  final IconData icon;
  final String? label;

  const AppGradientSpinner({
    super.key,
    this.size = 56.0,
    this.strokeWidth = 3.5,
    this.colors,
    this.showSparkle = true,
    this.icon = Icons.auto_awesome,
    this.label,
  });

  @override
  State<AppGradientSpinner> createState() => _AppGradientSpinnerState();
}

class _AppGradientSpinnerState extends State<AppGradientSpinner>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.colors ??
        const [
          AppColors.accentPink,
          AppColors.primary,
          AppColors.accentBlue,
          Colors.transparent,
        ];

    final spinner = Stack(
      alignment: Alignment.center,
      children: [
        // Ambient neon halo glow behind the spinner
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: widget.size * 0.85,
              height: widget.size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: 0.25 + 0.15 * _pulseController.value,
                    ),
                    blurRadius: widget.size * (0.45 + 0.15 * _pulseController.value),
                    spreadRadius: widget.size * 0.08,
                  ),
                  BoxShadow(
                    color: AppColors.accentPink.withValues(
                      alpha: 0.15 * _pulseController.value,
                    ),
                    blurRadius: widget.size * 0.35,
                    spreadRadius: widget.size * 0.04,
                  ),
                ],
              ),
            );
          },
        ),

        // Rotating gradient ring
        RotationTransition(
          turns: _spinController,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _GradientSpinnerArcPainter(
                strokeWidth: widget.strokeWidth,
                colors: gradientColors,
              ),
            ),
          ),
        ),

        // Centered glowing sparkle icon
        if (widget.showSparkle)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 0.92 + 0.12 * _pulseController.value;
              final double iconContainerSize = widget.size * 0.58;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceDeep.withValues(alpha: 0.9),
                    border: Border.all(
                      color: AppColors.purple.withValues(
                        alpha: 0.35 + 0.2 * _pulseController.value,
                      ),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(
                          alpha: 0.25 * _pulseController.value,
                        ),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.accentPink, AppColors.purple, AppColors.blueLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Icon(
                        widget.icon,
                        size: widget.size * 0.30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );

    if (widget.label != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            spinner,
            const SizedBox(height: 16),
            Text(
              widget.label!,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Center(child: spinner);
  }
}

class _GradientSpinnerArcPainter extends CustomPainter {
  final double strokeWidth;
  final List<Color> colors;

  _GradientSpinnerArcPainter({
    required this.strokeWidth,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..shader = SweepGradient(
        colors: colors,
        stops: const [0.0, 0.45, 0.8, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw a ~306-degree arc so there is an open head and fading tail
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 1.7, // ~306 degrees
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientSpinnerArcPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth || oldDelegate.colors != colors;
  }
}
