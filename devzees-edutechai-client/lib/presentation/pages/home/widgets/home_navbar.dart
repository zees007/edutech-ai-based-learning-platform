import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/presentation/widgets/word_by_word_reveal.dart';
import 'package:go_router/go_router.dart';

/// Ultra-premium floating glass navigation bar inspired by modern 3D motion SaaS platforms.
///
/// Features:
/// - Floating pill capsule with 20px Gaussian backdrop blur and 1px crisp glass border.
/// - Vector fluid wave brand mark + modern typography.
/// - Center glass link pill with smooth color transition and micro-glow hover states.
/// - High-contrast action pill button (solid white on dark hero canvas).
/// - Staggered spring slide-down entrance on page load.
class HomeNavbar extends ConsumerWidget {
  final Function(String)? onNavTap;
  const HomeNavbar({super.key, this.onNavTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authProvider.select((s) => s.isAuthenticated));
    final bool isMobile = Responsive.isMobile(context);

    return SpringEntranceBlock(
      delayMs: 120,
      durationMs: 700,
      fromOffset: const Offset(0, -22),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: const Color(0xCC080914), // Frosted near-black
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ─── 1. Brand Identity ───
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => onNavTap?.call('top'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Vector Fluid Line Glyph
                          _BrandFluidGlyph(size: isMobile ? 24 : 28),
                          const SizedBox(width: 10),
                          Text(
                            'EduTech',
                            style: AppTextStyles.h3.copyWith(
                              fontSize: isMobile ? 18 : 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: const Color(0xFFEEF0F6),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2B68F6), Color(0xFF9061F9)],
                              ),
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2B68F6).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── 2. Center Glass Links Pill (Desktop only) ───
                  if (!isMobile)
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _NavPill(title: 'Workspace', onTap: () => onNavTap?.call('preview')),
                          _NavPill(title: 'Features', onTap: () => onNavTap?.call('features')),
                          _NavPill(title: 'Modes', onTap: () => onNavTap?.call('modes')),
                          _NavPill(title: 'Compare', onTap: () => onNavTap?.call('comparison')),
                          _NavPill(title: 'Agents', onTap: () => onNavTap?.call('agents')),
                          _NavPill(title: 'Pricing', onTap: () => onNavTap?.call('pricing')),
                          _NavPill(title: 'FAQ', onTap: () => onNavTap?.call('faq')),
                        ],
                      ),
                    ),

                  // ─── 3. Auth & Action Pill Buttons ───
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAuthenticated) ...[
                        _HighContrastActionPill(
                          text: 'Open Workspace →',
                          onTap: () => context.go('/learning'),
                        ),
                      ] else ...[
                        if (!isMobile) ...[
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => context.go('/auth'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Color(0xFFB9BECF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _HighContrastActionPill(
                          text: 'Get Started',
                          onTap: () => context.go('/auth'),
                        ),
                      ],
                      if (isMobile) ...[
                        const SizedBox(width: 6),
                        _MobileMenuButton(
                          onNavTap: onNavTap,
                          isAuthenticated: isAuthenticated,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dynamic dual interleaving fluid line glyph echoing the WebGL fluid background
class _BrandFluidGlyph extends StatelessWidget {
  final double size;
  const _BrandFluidGlyph({this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FluidGlyphPainter(),
    );
  }
}

class _FluidGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glowing cyan top wave
    final Paint p1 = Paint()
      ..color = const Color(0xFF00F5D4)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path1 = Path()
      ..moveTo(w * 0.1, h * 0.38)
      ..cubicTo(w * 0.3, h * 0.15, w * 0.45, h * 0.6, w * 0.65, h * 0.35)
      ..cubicTo(w * 0.8, h * 0.15, w * 0.9, h * 0.45, w * 0.9, h * 0.38);
    canvas.drawPath(path1, p1);

    // Glowing magenta / violet bottom wave
    final Paint p2 = Paint()
      ..color = const Color(0xFFB838EE).withValues(alpha: 0.75)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path2 = Path()
      ..moveTo(w * 0.1, h * 0.65)
      ..cubicTo(w * 0.3, h * 0.85, w * 0.45, h * 0.4, w * 0.65, h * 0.7)
      ..cubicTo(w * 0.8, h * 0.9, w * 0.9, h * 0.58, w * 0.9, h * 0.65);
    canvas.drawPath(path2, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavPill extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _NavPill({required this.title, required this.onTap});

  @override
  State<_NavPill> createState() => _NavPillState();
}

class _NavPillState extends State<_NavPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            color: _isHovered ? Colors.white.withValues(alpha: 0.10) : Colors.transparent,
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: _isHovered ? const Color(0xFFEEF0F6) : const Color(0xFFB9BECF),
              fontSize: 13.5,
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}

/// The signature modern SaaS high-contrast solid white pill button.
class _HighContrastActionPill extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _HighContrastActionPill({
    required this.text,
    required this.onTap,
  });

  @override
  State<_HighContrastActionPill> createState() => _HighContrastActionPillState();
}

class _HighContrastActionPillState extends State<_HighContrastActionPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered ? const Color(0xFFE2E8F0) : Colors.white,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: _isHovered ? 0.35 : 0.18),
                  blurRadius: _isHovered ? 18 : 10,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(
                    color: Color(0xFF04050C), // High-contrast dark on white
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileMenuButton extends StatefulWidget {
  final Function(String)? onNavTap;
  final bool isAuthenticated;
  const _MobileMenuButton({this.onNavTap, this.isAuthenticated = false});

  @override
  State<_MobileMenuButton> createState() => _MobileMenuButtonState();
}

class _MobileMenuButtonState extends State<_MobileMenuButton> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: PopupMenuButton<String>(
          onOpened: () => setState(() => _isOpen = true),
          onCanceled: () => setState(() => _isOpen = false),
          onSelected: (value) {
            setState(() => _isOpen = false);
            if (value == 'workspace') {
              context.go('/learning');
            } else if (value == 'signin') {
              context.go('/auth');
            } else {
              widget.onNavTap?.call(value);
            }
          },
          icon: Icon(
            _isOpen ? Icons.close : Icons.menu,
            color: const Color(0xFFEEF0F6),
            size: 20,
          ),
          color: Colors.transparent,
          elevation: 0,
          offset: const Offset(0, 54),
          padding: EdgeInsets.zero,
          itemBuilder: (context) => [
            PopupMenuItem(
              padding: EdgeInsets.zero,
              enabled: false,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xEE090A14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuItem('Workspace Preview', 'preview'),
                        _buildMenuItem('Features', 'features'),
                        _buildMenuItem('Learning Modes', 'modes'),
                        _buildMenuItem('Why Us vs Chatbots', 'comparison'),
                        _buildMenuItem('AI Agents', 'agents'),
                        _buildMenuItem('Pricing', 'pricing'),
                        _buildMenuItem('FAQ', 'faq'),
                        Divider(color: Colors.white.withValues(alpha: 0.10), height: 1),
                        widget.isAuthenticated
                            ? _buildMenuItem('Open Workspace', 'workspace')
                            : _buildMenuItem('Sign In', 'signin'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, String value) {
    return _MobileMenuItem(
      title: title,
      onTap: () {
        Navigator.pop(context, value);
      },
    );
  }
}

class _MobileMenuItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _MobileMenuItem({required this.title, required this.onTap});

  @override
  State<_MobileMenuItem> createState() => _MobileMenuItemState();
}

class _MobileMenuItemState extends State<_MobileMenuItem> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isActive = true),
      onExit: (_) => setState(() => _isActive = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isActive = true),
        onTapUp: (_) => setState(() => _isActive = false),
        onTapCancel: () => setState(() => _isActive = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: _isActive ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: _isActive ? const Color(0xFFEEF0F6) : const Color(0xFFB9BECF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
