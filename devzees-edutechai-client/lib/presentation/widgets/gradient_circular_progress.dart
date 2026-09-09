import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A circular progress ring that accurately follows the app theme gradient
/// (AppColors.primaryGradient) across the active progress arc,
/// with rounded stroke caps and a clean, neutral background track.
class GradientCircularProgress extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Gradient gradient;

  const GradientCircularProgress({
    super.key,
    required this.progress,
    this.size = 28.0,
    this.strokeWidth = 3.0,
    this.trackColor,
    this.gradient = AppColors.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GradientCircularProgressPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          trackColor: trackColor ?? Colors.white.withValues(alpha: 0.08),
          gradient: gradient,
        ),
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Gradient gradient;

  const _GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Clean, neutral background track (unaffected by gradient)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    final double effectiveProgress = (progress > 0 ? progress : 0.03).clamp(0.02, 1.0);

    // 2. Progress arc painted with the app theme gradient and rounded caps
    const double startAngle = -math.pi / 2; // 12 o'clock position
    final double sweepAngle = 2 * math.pi * effectiveProgress;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.gradient != gradient;
  }
}
