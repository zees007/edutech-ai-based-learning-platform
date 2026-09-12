import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// An animated tutor icon rendering an organic, floating 3-node neural network.
/// Features a vibrant glowing effect at the circular outer border, and 3 solid-color
/// dots matching the signature app gradient theme (Pink, Purple, Blue).
class AnimatedTutorIcon extends StatefulWidget {
  final double size;
  final bool showHalo;

  const AnimatedTutorIcon({
    super.key,
    this.size = 32.0,
    this.showHalo = true,
  });

  @override
  State<AnimatedTutorIcon> createState() => _AnimatedTutorIconState();
}

class _AnimatedTutorIconState extends State<AnimatedTutorIcon>
    with TickerProviderStateMixin {
  late final AnimationController _neuralMotionController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _neuralMotionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _neuralMotionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;

    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Ambient theme neon breathing glow behind icon (Pink, Purple, Blue)
          if (widget.showHalo)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final double pulse = _pulseController.value;
                return Container(
                  width: s * 0.85,
                  height: s * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(
                          alpha: 0.16 + 0.08 * pulse,
                        ),
                        blurRadius: s * (0.30 + 0.10 * pulse),
                        spreadRadius: s * 0.02,
                      ),
                      BoxShadow(
                        color: AppColors.accentPink.withValues(
                          alpha: 0.10 + 0.06 * pulse,
                        ),
                        blurRadius: s * 0.35,
                        spreadRadius: s * 0.01,
                      ),
                      BoxShadow(
                        color: AppColors.accentBlue.withValues(
                          alpha: 0.10 + 0.06 * pulse,
                        ),
                        blurRadius: s * 0.30,
                        spreadRadius: s * 0.01,
                      ),
                    ],
                  ),
                );
              },
            ),

          // 2. Dark glass circular badge container with glowing circular outer border
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final double pulse = _pulseController.value;
              return Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceDark.withValues(alpha: 0.95),
                  border: Border.all(
                    color: AppColors.purple.withValues(alpha: 0.40 + 0.20 * pulse),
                    width: math.max(1.0, s * 0.04),
                  ),
                  boxShadow: [
                    // Refined, subtle glowing effect at circular outer border
                    BoxShadow(
                      color: AppColors.purple.withValues(
                        alpha: 0.25 + 0.15 * pulse,
                      ),
                      blurRadius: 5 + 3 * pulse,
                      spreadRadius: 0.3,
                    ),
                    BoxShadow(
                      color: AppColors.accentPink.withValues(
                        alpha: 0.12 * pulse,
                      ),
                      blurRadius: 8,
                      spreadRadius: 0.2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: AnimatedBuilder(
                    animation: _neuralMotionController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(s, s),
                        painter: _NeuralNetworkFloatingPainter(
                          progress: _neuralMotionController.value,
                          pulse: pulse,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Custom painter that draws an organic floating 3-node neural network
/// where each dot is a SOLID color from the signature app gradient theme:
/// Pink (0xFFEC4899), Purple (0xFFA855F7), and Blue (0xFF3B82F6).
class _NeuralNetworkFloatingPainter extends CustomPainter {
  final double progress;
  final double pulse;

  _NeuralNetworkFloatingPainter({
    required this.progress,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double s = size.width;
    final double t = progress * 2 * math.pi;

    // Base constellation anchor positions (asymmetric neural layout)
    final a1 = Offset(center.dx + s * 0.17, center.dy - s * 0.20); // Top-Right (Pink)
    final a2 = Offset(center.dx - s * 0.22, center.dy + s * 0.06); // Left (Purple)
    final a3 = Offset(center.dx + s * 0.13, center.dy + s * 0.22); // Bottom-Right (Blue)

    // Non-circular organic harmonic drift for each node
    final p1 = Offset(
      a1.dx + s * 0.055 * math.sin(t) + s * 0.02 * math.cos(2 * t),
      a1.dy + s * 0.045 * math.cos(1.2 * t) - s * 0.015 * math.sin(2 * t),
    );

    final p2 = Offset(
      a2.dx + s * 0.050 * math.cos(1.4 * t) + s * 0.02 * math.sin(t),
      a2.dy + s * 0.055 * math.sin(0.9 * t) + s * 0.02 * math.cos(1.7 * t),
    );

    final p3 = Offset(
      a3.dx + s * 0.045 * math.sin(0.8 * t + math.pi / 3) - s * 0.02 * math.cos(1.6 * t),
      a3.dy + s * 0.055 * math.cos(1.1 * t + math.pi / 4) + s * 0.018 * math.sin(2 * t),
    );

    final nodes = [p1, p2, p3];

    // Solid Theme Gradient Colors
    const nodeColors = [
      AppColors.accentPink, // Pink 500
      AppColors.purple,     // Purple 500
      AppColors.accentBlue, // Blue 500
    ];

    // ─── 1. Central Synaptic Nucleus & Radial Filaments ───
    final centerGlowPaint = Paint()
      ..color = AppColors.purple.withValues(alpha: 0.18 + 0.12 * pulse)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, s * 0.065, centerGlowPaint);

    final centerDotPaint = Paint()
      ..color = AppColors.purple
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, s * 0.032, centerDotPaint);

    for (int i = 0; i < 3; i++) {
      final radialPaint = Paint()
        ..color = nodeColors[i].withValues(alpha: 0.15 + 0.08 * pulse)
        ..strokeWidth = math.max(0.6, s * 0.02)
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, nodes[i], radialPaint);
    }

    // ─── 2. Interconnected Synaptic Lines between Floating Nodes ───
    // Line 1: Pink -> Purple (Node 0 to Node 1)
    _drawGradientSynapse(canvas, p1, p2, AppColors.accentPink, AppColors.purple, s);

    // Line 2: Purple -> Blue (Node 1 to Node 2)
    _drawGradientSynapse(canvas, p2, p3, AppColors.purple, AppColors.accentBlue, s);

    // Line 3: Blue -> Pink (Node 2 to Node 0)
    _drawGradientSynapse(canvas, p3, p1, AppColors.accentBlue, AppColors.accentPink, s);

    // ─── 3. Action Potential / Neural Signals Traversing Fibers ───
    _drawNeuralSignal(canvas, p1, p2, (progress * 2.0) % 1.0, AppColors.accentPink, s);
    _drawNeuralSignal(canvas, p2, p3, (progress * 2.0 + 0.33) % 1.0, AppColors.purple, s);
    _drawNeuralSignal(canvas, p3, p1, (progress * 2.0 + 0.66) % 1.0, AppColors.accentBlue, s);

    // ─── 4. The 3 Glowing Solid-Color Theme Neural Dots (Pink, Purple, Blue) ───
    final double baseNodeRadius = math.max(2.4, s * 0.082);

    for (int i = 0; i < 3; i++) {
      final pos = nodes[i];
      final color = nodeColors[i];

      // Independent neural firing pulse for each node
      final double nodeFiring = 0.70 + 0.30 * math.sin(t * 2.0 + i * (2 * math.pi / 3));

      // Broad outer glow
      final outerGlow = Paint()
        ..color = color.withValues(alpha: 0.35 * nodeFiring + 0.15 * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, baseNodeRadius * 2.1, outerGlow);

      // Mid aura
      final midAura = Paint()
        ..color = color.withValues(alpha: 0.65 * nodeFiring)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, baseNodeRadius * 1.35, midAura);

      // Solid color dot of app theme gradient (No white fill)
      final solidCore = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, baseNodeRadius * 0.95, solidCore);
    }
  }

  void _drawGradientSynapse(
    Canvas canvas,
    Offset from,
    Offset to,
    Color colorA,
    Color colorB,
    double s,
  ) {
    final lineShader = LinearGradient(
      colors: [colorA.withValues(alpha: 0.70), colorB.withValues(alpha: 0.70)],
    ).createShader(Rect.fromPoints(from, to));

    final glowShader = LinearGradient(
      colors: [
        colorA.withValues(alpha: 0.22 + 0.10 * pulse),
        colorB.withValues(alpha: 0.22 + 0.10 * pulse),
      ],
    ).createShader(Rect.fromPoints(from, to));

    // Outer soft aura
    final glowPaint = Paint()
      ..shader = glowShader
      ..strokeWidth = math.max(1.8, s * 0.055)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, glowPaint);

    // Crisp inner synaptic fiber
    final linePaint = Paint()
      ..shader = lineShader
      ..strokeWidth = math.max(0.9, s * 0.028)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, linePaint);
  }

  void _drawNeuralSignal(
    Canvas canvas,
    Offset from,
    Offset to,
    double phase,
    Color color,
    double s,
  ) {
    final signalPos = Offset.lerp(from, to, phase)!;

    // Signal glow
    final signalGlow = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(signalPos, math.max(1.6, s * 0.048), signalGlow);

    // Solid theme-colored signal spark
    final signalCore = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(signalPos, math.max(0.9, s * 0.026), signalCore);
  }

  @override
  bool shouldRepaint(covariant _NeuralNetworkFloatingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}
