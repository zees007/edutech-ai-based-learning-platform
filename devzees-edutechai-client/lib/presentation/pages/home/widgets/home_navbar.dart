import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/presentation/widgets/word_by_word_reveal.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:go_router/go_router.dart';

/// Ultra-premium floating glass navigation bar for EduTech AI.
///
/// Features:
/// - Floating pill capsule with 20px Gaussian backdrop blur and 1px crisp glass border.
/// - Exact branded logo matching the Learning Page sidebar ('⚡ EduTech AI').
/// - Borderless menu options displaying a smooth glassy highlight on hover.
/// - Kinetic gradient action pill button ('Get Started') with electric fuchsia/royal blue sweep.
class HomeNavbar extends ConsumerWidget {
  final Function(String)? onNavTap;
  const HomeNavbar({super.key, this.onNavTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(
      authProvider.select((s) => s.isAuthenticated),
    );
    final bool isDesktop = Responsive.isDesktop(context);
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
                horizontal: isMobile ? 12 : 24,
                vertical: 8,
              ),
              child: Builder(
                builder: (context) {
                  final brandWidget = MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => onNavTap?.call('top'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '⚡ ',
                            style: AppTextStyles.h4.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: isMobile ? 18 : 22,
                            ),
                          ),
                          GradientText(
                            'EduTech',
                            style: AppTextStyles.h3.copyWith(
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(
                                alpha: 0.2,
                              ),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'AI',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  final actionsWidget = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAuthenticated) ...[
                        _NavbarGradientActionPill(
                          text: 'Open Workspace →',
                          onTap: () => context.go('/learning'),
                          isMobile: isMobile,
                        ),
                      ] else ...[
                        if (isDesktop) ...[
                          _NavbarSignInButton(
                            onTap: () => context.go('/auth'),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _NavbarGradientActionPill(
                          text: 'Get Started',
                          onTap: () => context.go('/auth'),
                          isMobile: isMobile,
                        ),
                      ],
                      if (!isDesktop) ...[
                        const SizedBox(width: 6),
                        _MobileMenuButton(
                          onNavTap: onNavTap,
                          isAuthenticated: isAuthenticated,
                        ),
                      ],
                    ],
                  );

                  if (isDesktop) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ─── 1. Brand Identity ───
                        brandWidget,

                        // ─── 2. Center Menu Links (Spans naturally between Brand and Actions) ───
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _NavPill(
                                      title: 'Workspace',
                                      onTap: () => onNavTap?.call('preview'),
                                    ),
                                    _NavPill(
                                      title: 'Features',
                                      onTap: () => onNavTap?.call('features'),
                                    ),
                                    _NavPill(
                                      title: 'Modes',
                                      onTap: () => onNavTap?.call('modes'),
                                    ),
                                    _NavPill(
                                      title: 'Compare',
                                      onTap: () => onNavTap?.call('comparison'),
                                    ),
                                    _NavPill(
                                      title: 'Agents',
                                      onTap: () => onNavTap?.call('agents'),
                                    ),
                                    _NavPill(
                                      title: 'Pricing',
                                      onTap: () => onNavTap?.call('pricing'),
                                    ),
                                    _NavPill(
                                      title: 'FAQ',
                                      onTap: () => onNavTap?.call('faq'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ─── 3. Action Buttons ───
                        actionsWidget,
                      ],
                    );
                  }

                  // Mobile & Tablet: Brand on left, Action/Menu on right, both scaling down gracefully if space is narrow
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: brandWidget,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: actionsWidget,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Borderless menu link displaying an elegant frosted glass highlight on hover.
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
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.transparent,
            border: Border.all(
              color: _isHovered
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.transparent,
              width: 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.03),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: _isHovered
                  ? const Color(0xFFF8FAFC)
                  : const Color(0xFF94A3B8),
              fontSize: 15.0,
              fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Borderless glass hover action pill for 'Sign In'.
class _NavbarSignInButton extends StatefulWidget {
  final VoidCallback onTap;

  const _NavbarSignInButton({required this.onTap});

  @override
  State<_NavbarSignInButton> createState() => _NavbarSignInButtonState();
}

class _NavbarSignInButtonState extends State<_NavbarSignInButton> {
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
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              color: _isHovered
                  ? Colors.white.withValues(alpha: 0.09)
                  : Colors.transparent,
              border: Border.all(
                color: _isHovered
                    ? Colors.white.withValues(alpha: 0.16)
                    : Colors.transparent,
                width: 1.0,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.04),
                        blurRadius: 10,
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 14,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              'Sign In',
              style: TextStyle(
                color: _isHovered ? Colors.white : const Color(0xFFCBD5E1),
                fontSize: 14.5,
                fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The signature modern SaaS gradient action pill button matching app theme.
class _NavbarGradientActionPill extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isMobile;

  const _NavbarGradientActionPill({
    required this.text,
    required this.onTap,
    this.isMobile = false,
  });

  @override
  State<_NavbarGradientActionPill> createState() =>
      _NavbarGradientActionPillState();
}

class _NavbarGradientActionPillState extends State<_NavbarGradientActionPill>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
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
        _shimmerController.repeat();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _shimmerController.stop();
        _shimmerController.reset();
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
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: _isHovered ? 0.55 : 0.35,
                  ),
                  blurRadius: _isHovered ? 24 : 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isMobile ? 14 : 20,
                    vertical: widget.isMobile ? 8 : 9.5,
                  ),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.isMobile ? 12.5 : 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (_isHovered)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, _) {
                          return FractionallySizedBox(
                            widthFactor: 0.45,
                            alignment: Alignment(
                              -1.5 + _shimmerController.value * 3.0,
                              0,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.35),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
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
                        Divider(
                          color: Colors.white.withValues(alpha: 0.10),
                          height: 1,
                        ),
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
            color: _isActive
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: _isActive
                  ? const Color(0xFFEEF0F6)
                  : const Color(0xFFB9BECF),
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
