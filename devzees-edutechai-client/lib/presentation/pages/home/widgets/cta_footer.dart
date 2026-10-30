import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:go_router/go_router.dart';

/// Ultra-premium Terminal CTA & Minimalist SaaS Footer.
class CtaFooter extends StatelessWidget {
  const CtaFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        // ─── 1. Terminal CTA Banner ───
        GlassCard(
          padding: EdgeInsets.all(isMobile ? 32 : 56),
          isGlowing: true,
          borderRadius: 28,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient radial glow behind CTA
              Positioned(
                top: -80,
                child: Container(
                  width: 360,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF2B68F6).withValues(alpha: 0.25),
                        const Color(0xFF9061F9).withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  // Pre-header badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: const Text(
                      'START YOUR COGNITIVE JOURNEY TODAY',
                      style: TextStyle(
                        color: Color(0xFFD4D8E8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  GradientText(
                    'Ready to Master Any Subject with AI?',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: isMobile ? 26 : 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      'Join ambitious students, researchers, and engineers learning faster with an autonomous multi-agent squad.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body1.copyWith(
                        color: const Color(0xFFB9BECF),
                        fontSize: isMobile ? 14.5 : 16.5,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Dual CTA Action Pills with floating sparkle field
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _CtaSparkleField(
                        child: _FooterWhiteActionPill(
                          text: 'Get Started Free →',
                          onTap: () => context.go('/auth'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 80),

        // ─── 2. Footer Bar ───
        Container(
          padding: const EdgeInsets.only(top: 36, bottom: 28),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = constraints.maxWidth < 720;
              return Flex(
                direction: isNarrow ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: isNarrow ? 0 : 1,
                    child: Column(
                      crossAxisAlignment: isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
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
                              'EduTech AI',
                              style: TextStyle(
                                color: Color(0xFFEEF0F6),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '© ${DateTime.now().year} EduTech AI — engineered for autonomous deep work & mastery.',
                          style: TextStyle(
                            color: const Color(0xFF8E94A8),
                            fontSize: isNarrow ? 11.5 : 12.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isNarrow) const SizedBox(height: 24),
                  Flexible(
                    flex: isNarrow ? 0 : 1,
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 14,
                      alignment: isNarrow ? WrapAlignment.center : WrapAlignment.end,
                      children: const [
                        _FooterLink('Terms of Service'),
                        _FooterLink('Privacy Policy'),
                        _FooterLink('Contact Support'),
                        _FooterLink('Documentation'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FooterWhiteActionPill extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterWhiteActionPill({
    required this.text,
    required this.onTap,
  });

  @override
  State<_FooterWhiteActionPill> createState() => _FooterWhiteActionPillState();
}

class _FooterWhiteActionPillState extends State<_FooterWhiteActionPill>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _shimmerController.forward(from: 0);
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _shimmerController.stop();
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Container(
            clipBehavior: Clip.antiAlias,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              color: _isHovered ? const Color(0xFFF1F5F9) : Colors.white,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: _isHovered ? 0.40 : 0.20),
                  blurRadius: _isHovered ? 20 : 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(
                    color: Color(0xFF04050C),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                if (_isHovered)
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, _) {
                      return Positioned.fill(
                        child: FractionallySizedBox(
                          widthFactor: 0.45,
                          alignment: Alignment(
                            -1.0 + _shimmerController.value * 3.0,
                            0,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.40),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating sparkle particles around the CTA action button
class _CtaSparkleField extends StatefulWidget {
  final Widget child;
  const _CtaSparkleField({required this.child});

  @override
  State<_CtaSparkleField> createState() => _CtaSparkleFieldState();
}

class _CtaSparkleFieldState extends State<_CtaSparkleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Orbiting sparkles
            Positioned(
              left: -22 + 6 * math.sin(t * 2 * math.pi),
              top: -10 + 6 * math.cos(t * 2 * math.pi),
              child: Opacity(
                opacity: 0.4 + 0.6 * math.sin(t * 2 * math.pi).abs(),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF00F5D4),
                  size: 18,
                ),
              ),
            ),
            Positioned(
              right: -22 + 6 * math.cos(t * 2 * math.pi),
              bottom: -8 + 6 * math.sin(t * 2 * math.pi),
              child: Opacity(
                opacity: 0.4 + 0.6 * math.cos(t * 2 * math.pi).abs(),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFE879F9),
                  size: 16,
                ),
              ),
            ),
            Positioned(
              left: 36 + 6 * math.sin((t + 0.3) * 2 * math.pi),
              bottom: -14,
              child: Opacity(
                opacity: 0.3 + 0.5 * math.sin((t + 0.3) * 2 * math.pi).abs(),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFF60A5FA),
                  size: 14,
                ),
              ),
            ),
            Positioned(
              right: 44 + 6 * math.cos((t + 0.5) * 2 * math.pi),
              top: -12,
              child: Opacity(
                opacity: 0.3 + 0.5 * math.cos((t + 0.5) * 2 * math.pi).abs(),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFF9061F9),
                  size: 13,
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String text;

  const _FooterLink(this.text);

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          widget.text,
          style: TextStyle(
            color: _isHovered ? const Color(0xFFEEF0F6) : const Color(0xFF8E94A8),
            fontSize: 13,
            fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}
