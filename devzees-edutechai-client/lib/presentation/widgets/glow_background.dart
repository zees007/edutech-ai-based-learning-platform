import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_palette.dart';
import '../../core/constants/responsive.dart';

/// A high-performance kinetic WebGL-inspired fluid & stardust canvas background.
///
/// Features:
/// - Deep near-black SaaS base (#04050C) for ultimate contrast.
/// - Harmonic fluid wave ribbons with cyan, cobalt, violet, and magenta ink currents.
/// - Perpetual auto-orbiting virtual energy cursor that breathes and paints fluid trails.
/// - Mouse-driven interactive fluid ripple splats that expand and dissipate dynamically.
/// - Micro-stardust particle field for cosmic depth.
/// - Tuned radial scrim overlay to guarantee 100% typography legibility.
/// - Fully isolated via [RepaintBoundary] for rock-solid 60/120fps performance.
class GlowBackground extends StatefulWidget {
  final Widget child;

  const GlowBackground({super.key, required this.child});

  @override
  State<GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<GlowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _engineController;

  // Interactive pointer splats
  final List<_FluidSplat> _splats = [];
  Offset _lastPointerPos = Offset.zero;
  int _lastSplatTime = 0;

  @override
  void initState() {
    super.initState();
    _engineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _engineController.dispose();
    super.dispose();
  }

  void _onPointerHover(PointerEvent event) {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Throttle interactive splat generation to ~45ms
    if (now - _lastSplatTime > 45) {
      final dx = event.localPosition.dx - _lastPointerPos.dx;
      final dy = event.localPosition.dy - _lastPointerPos.dy;
      final speed = math.sqrt(dx * dx + dy * dy);

      if (speed > 3) {
        _splats.add(
          _FluidSplat(
            position: event.localPosition,
            velocity: Offset(dx, dy),
            color: _generateHarmonicColor(_splats.length),
            birthTime: now,
            maxRadius: math.min(140.0, 45.0 + speed * 1.5),
          ),
        );

        // Cap active splats for performance
        if (_splats.length > 25) {
          _splats.removeAt(0);
        }
      }

      _lastPointerPos = event.localPosition;
      _lastSplatTime = now;
    }
  }

  Color _generateHarmonicColor(int seed) {
    const palette = [
      Color(0xFF00F5D4), // Cyan
      Color(0xFF2B68F6), // Cobalt Blue
      Color(0xFF7C3AED), // Royal Violet
      Color(0xFFB838EE), // Electric Magenta
      Color(0xFF60A5FA), // Soft Azure
    ];
    return palette[seed % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDarkMode;
    final bool isMobile = Responsive.isMobile(context);

    // Deep modern SaaS hero base (#04050C)
    final Color heroBase = isDark ? const Color(0xFF04050C) : AppColors.background;

    return MouseRegion(
      onHover: _onPointerHover,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: heroBase,
        child: Stack(
          children: [
            // 1. Kinetic Fluid Canvas (Isolated repaint boundary)
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _engineController,
                  builder: (context, _) {
                    final double time = _engineController.value * 2 * math.pi;

                    // Clean up aged splats
                    final now = DateTime.now().millisecondsSinceEpoch;
                    _splats.removeWhere((s) => (now - s.birthTime) > 3000);

                    return CustomPaint(
                      painter: _KineticFluidBackgroundPainter(
                        time: time,
                        isDark: isDark,
                        isMobile: isMobile,
                        splats: List.unmodifiable(_splats),
                        now: now,
                      ),
                    );
                  },
                ),
              ),
            ),

            // 2. Center Radial Scrim for Text Legibility
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, -0.15),
                      radius: 1.15,
                      colors: [
                        heroBase.withValues(alpha: isDark ? 0.75 : 0.82),
                        heroBase.withValues(alpha: isDark ? 0.55 : 0.65),
                        heroBase.withValues(alpha: isDark ? 0.22 : 0.30),
                        heroBase.withValues(alpha: isDark ? 0.05 : 0.10),
                      ],
                      stops: const [0.0, 0.40, 0.72, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Main Foreground Page Content
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _FluidSplat {
  final Offset position;
  final Offset velocity;
  final Color color;
  final int birthTime;
  final double maxRadius;

  _FluidSplat({
    required this.position,
    required this.velocity,
    required this.color,
    required this.birthTime,
    required this.maxRadius,
  });
}

class _KineticFluidBackgroundPainter extends CustomPainter {
  final double time;
  final bool isDark;
  final bool isMobile;
  final List<_FluidSplat> splats;
  final int now;

  _KineticFluidBackgroundPainter({
    required this.time,
    required this.isDark,
    required this.isMobile,
    required this.splats,
    required this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final double width = size.width;
    final double height = size.height;
    final Offset center = Offset(width * 0.5, height * 0.4);

    // ─── 1. Perpetual Virtual Auto-Cursor Orbit ───
    // An invisible virtual pointer continually stirs the fluid in a breathing orbit
    final double orbitRadius = math.min(width * 0.32, isMobile ? 180.0 : 360.0);
    final double orbitAngle = time * 0.65;
    final double breathing = 0.78 + 0.22 * math.sin(time * 1.3);
    final double r = orbitRadius * breathing;

    final Offset orbitPos = Offset(
      center.dx + math.cos(orbitAngle) * r,
      center.dy + math.sin(orbitAngle) * (r * 0.65),
    );

    // Virtual ink bloom
    final Paint orbitPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00F5D4).withValues(alpha: isDark ? 0.22 : 0.12),
          const Color(0xFF2B68F6).withValues(alpha: isDark ? 0.14 : 0.08),
          const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.06 : 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: orbitPos, radius: isMobile ? 220 : 380));

    canvas.drawCircle(orbitPos, isMobile ? 220 : 380, orbitPaint);

    // ─── 2. Flowing Kinetic Aurora Ink Vortices ───
    // Top-Left Primary Violet / Cobalt Vortex
    final Offset v1 = Offset(
      width * 0.22 + math.sin(time * 0.8) * (isMobile ? 40 : 100),
      height * 0.18 + math.cos(time * 0.7) * (isMobile ? 35 : 80),
    );
    final Paint p1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2B68F6).withValues(alpha: isDark ? 0.25 : 0.12),
          const Color(0xFF6B47EB).withValues(alpha: isDark ? 0.18 : 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: v1, radius: isMobile ? 340 : 580));
    canvas.drawCircle(v1, isMobile ? 340 : 580, p1);

    // Center-Right Electric Magenta Vortex
    final Offset v2 = Offset(
      width * 0.78 + math.cos(time * 0.6) * (isMobile ? 35 : 90),
      height * 0.36 + math.sin(time * 0.9) * (isMobile ? 30 : 70),
    );
    final Paint p2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFB838EE).withValues(alpha: isDark ? 0.22 : 0.10),
          const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.12 : 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 1.0],
      ).createShader(Rect.fromCircle(center: v2, radius: isMobile ? 300 : 520));
    canvas.drawCircle(v2, isMobile ? 300 : 520, p2);

    // Bottom Ambient Cyan / Azure Flow
    final Offset v3 = Offset(
      width * 0.5 + math.sin(time * 1.1) * (isMobile ? 30 : 80),
      height * 0.72 + math.cos(time * 0.5) * (isMobile ? 30 : 60),
    );
    final Paint p3 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00F5D4).withValues(alpha: isDark ? 0.14 : 0.06),
          const Color(0xFF2B68F6).withValues(alpha: isDark ? 0.09 : 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Rect.fromCircle(center: v3, radius: isMobile ? 320 : 540));
    canvas.drawCircle(v3, isMobile ? 320 : 540, p3);

    // ─── 3. Interactive Pointer Fluid Splats ───
    for (final splat in splats) {
      final double ageMs = (now - splat.birthTime).toDouble();
      final double progress = (ageMs / 3000.0).clamp(0.0, 1.0);
      final double fade = (1.0 - progress);
      final double radius = splat.maxRadius * (0.3 + 0.7 * math.sin(progress * math.pi * 0.5));

      final Offset splatPos = Offset(
        splat.position.dx + splat.velocity.dx * progress * 0.2,
        splat.position.dy + splat.velocity.dy * progress * 0.2,
      );

      final Paint splatPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            splat.color.withValues(alpha: (isDark ? 0.28 : 0.14) * fade),
            splat.color.withValues(alpha: (isDark ? 0.12 : 0.06) * fade),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: splatPos, radius: radius));

      canvas.drawCircle(splatPos, radius, splatPaint);
    }

    // ─── 4. Micro-Stardust Particles ───
    final Paint starPaint = Paint()..style = PaintingStyle.fill;
    const int numStars = 40;
    for (int i = 0; i < numStars; i++) {
      // Deterministic pseudo-random placement
      final double seed = i * 137.5;
      final double sx = (math.sin(seed) * 0.5 + 0.5) * width;
      final double sy = (math.cos(seed * 1.3) * 0.5 + 0.5) * height;

      // Gentle harmonic twinkle
      final double twinkle = 0.35 + 0.65 * math.sin(time * 2.2 + i * 0.8);
      final double starOpacity = (isDark ? 0.35 : 0.15) * twinkle;
      final double starSize = 0.8 + 0.8 * (i % 3);

      starPaint.color = Colors.white.withValues(alpha: starOpacity);
      canvas.drawCircle(Offset(sx, sy), starSize, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _KineticFluidBackgroundPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.splats.length != splats.length ||
        oldDelegate.isDark != isDark;
  }
}

