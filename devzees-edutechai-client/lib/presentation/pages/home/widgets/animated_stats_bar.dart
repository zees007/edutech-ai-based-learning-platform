import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

/// Animated social-proof statistics bar for the homepage.
///
/// Features:
/// - Animated count-up from 0 when scrolled into the viewport.
/// - Glass-morphism container matching the homepage aesthetic.
/// - Staggered entrance with configurable delays per stat.
/// - Responsive grid: 3 columns on desktop, 2 on mobile (wrapping).
class AnimatedStatsBar extends StatefulWidget {
  const AnimatedStatsBar({super.key});

  @override
  State<AnimatedStatsBar> createState() => _AnimatedStatsBarState();
}

class _AnimatedStatsBarState extends State<AnimatedStatsBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasTriggered = false;
  ScrollPosition? _scrollPosition;
  double _screenHeight = 1000.0;

  static const _stats = [
    _StatData(icon: Icons.bolt_rounded, value: 10000, suffix: '+', label: 'AI Sessions Generated', color: Color(0xFF60A5FA)),
    _StatData(icon: Icons.menu_book_rounded, value: 500, suffix: '+', label: 'Topics Covered', color: Color(0xFF9061F9)),
    _StatData(icon: Icons.verified_rounded, value: 99, suffix: '.2%', label: 'Accuracy Grounded', color: Color(0xFF00F5D4)),
    _StatData(icon: Icons.school_rounded, value: 50, suffix: '+', label: 'Universities', color: Color(0xFFE879F9)),
    _StatData(icon: Icons.public_rounded, value: 120, suffix: '+', label: 'Countries', color: Color(0xFF2B68F6)),
    _StatData(icon: Icons.star_rounded, value: 4, suffix: '.9/5', label: 'User Rating', color: Color(0xFFF59E0B)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache screen height safely in didChangeDependencies
    _screenHeight = MediaQuery.maybeSizeOf(context)?.height ?? 1000.0;

    _scrollPosition?.removeListener(_checkVisibility);
    final scrollable = Scrollable.maybeOf(context);
    _scrollPosition = scrollable?.position;
    _scrollPosition?.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibility();
    });
  }

  @override
  void deactivate() {
    _scrollPosition?.removeListener(_checkVisibility);
    _scrollPosition = null;
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (_hasTriggered || !mounted || !context.mounted) return;

    try {
      final renderObject = context.findRenderObject();
      if (renderObject == null || !renderObject.attached) return;

      final renderBox = renderObject as RenderBox;
      if (!renderBox.hasSize) return;
      final position = renderBox.localToGlobal(Offset.zero);

      // Trigger when top of widget enters the bottom 85% of the screen
      if (position.dy < _screenHeight * 0.85) {
        _hasTriggered = true;
        _controller.forward();
      }
    } catch (_) {
      // Safe fallback during unmounting or continuous resize passes
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
          // Section badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 16,
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00F5D4),
                      boxShadow: [
                        BoxShadow(color: Color(0xFF00F5D4), blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TRUSTED BY LEARNERS WORLDWIDE',
                    style: TextStyle(
                      color: Color(0xFFD4D8E8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Stats Grid
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 40,
              vertical: isMobile ? 24 : 36,
            ),
            decoration: BoxDecoration(
              color: const Color(0xCC080914),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.50),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 32,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Wrap(
              spacing: isMobile ? 16 : 24,
              runSpacing: isMobile ? 20 : 28,
              alignment: WrapAlignment.center,
              children: List.generate(_stats.length, (index) {
                return _AnimatedStatTile(
                  data: _stats[index],
                  animation: _controller,
                  delayFraction: index * 0.12,
                  isMobile: isMobile,
                );
              }),
            ),
          ),
        ],
    );
  }
}

class _StatData {
  final IconData icon;
  final int value;
  final String suffix;
  final String label;
  final Color color;

  const _StatData({
    required this.icon,
    required this.value,
    required this.suffix,
    required this.label,
    required this.color,
  });
}

class _AnimatedStatTile extends StatelessWidget {
  final _StatData data;
  final Animation<double> animation;
  final double delayFraction;
  final bool isMobile;

  const _AnimatedStatTile({
    required this.data,
    required this.animation,
    required this.delayFraction,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    // Each tile has its own delayed interval within the master animation
    final begin = delayFraction.clamp(0.0, 0.6);
    final end = (begin + 0.5).clamp(begin + 0.1, 1.0);

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        final t = curvedAnimation.value;
        final countValue = (data.value * t).round();

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: SizedBox(
              width: isMobile ? 140 : 160,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with colored glow
                  Container(
                    width: isMobile ? 40 : 48,
                    height: isMobile ? 40 : 48,
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: data.color.withValues(alpha: 0.30),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: data.color.withValues(alpha: 0.20),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Icon(
                      data.icon,
                      color: data.color,
                      size: isMobile ? 20 : 24,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Animated counter value
                  Text(
                    '$countValue${data.suffix}',
                    style: TextStyle(
                      color: const Color(0xFFEEF0F6),
                      fontSize: isMobile ? 24 : 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Label
                  Text(
                    data.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: isMobile ? 11 : 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
