import 'dart:async';
import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/presentation/widgets/word_by_word_reveal.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:go_router/go_router.dart';

/// Ultra-premium SaaS hero section designed for a high-converting, agency-grade presentation.
///
/// Features:
/// - Full background showcase of [assets/images/home/hero-pic.jpg] with directional scrim.
/// - Left-aligned typography: "Master Any Subject with a" + electric gradient "Team of AI Agents".
/// - Grounded pedagogical sub-heading detailing autonomous supervisor orchestration.
/// - Dual action buttons: "Start Learning for Free" (kinetic gradient) and "Watch a Demo" (frosted glass).
class HeroSection extends StatefulWidget {
  final VoidCallback? onExploreTap;
  final Widget? header;

  const HeroSection({
    super.key,
    this.onExploreTap,
    this.header,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  int _currentBgIndex = 0;
  Timer? _bgTimer;

  static const List<String> _bgImages = [
    'assets/images/home/hero-pic.jpg',
    'assets/images/home/hero-pic2.jpg',
    'assets/images/home/hero-pic3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startBgTimer();
  }

  void _startBgTimer() {
    _bgTimer?.cancel();
    _bgTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          _currentBgIndex = (_currentBgIndex + 1) % _bgImages.length;
        });
      }
    });
  }

  void _setBgIndex(int index) {
    if (_currentBgIndex != index) {
      setState(() {
        _currentBgIndex = index;
      });
      _startBgTimer();
    }
  }

  @override
  void dispose() {
    _bgTimer?.cancel();
    super.dispose();
  }

  BoxFit _getBgFit(int index, bool isDesktop) {
    // hero-pic3.jpg spans from top (Y=55) to bottom (Y=1510).
    // Using BoxFit.fitHeight on desktop preserves 100% of its vertical illustration without cropping top or bottom.
    if (isDesktop && _bgImages[index].contains('hero-pic3')) {
      return BoxFit.fitHeight;
    }
    return BoxFit.cover;
  }

  Alignment _getBgAlignment(int index, bool isMobile, bool isDesktop) {
    if (isMobile) return Alignment.topCenter;
    if (isDesktop && _bgImages[index].contains('hero-pic3')) {
      return Alignment.centerRight;
    }
    return Alignment.topRight;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);
    final bool isDesktop = Responsive.isDesktop(context);

    // Symmetrical vertical spacing above and below the hero text & action button block,
    // balancing the content within the full-height slider (860 desktop / 680 tablet / 540 mobile)
    final double verticalMargin = isMobile ? 24.0 : (isTablet ? 96.0 : 180.0);

    final heroContent = Container(
      width: double.infinity,
      color: const Color(0xFF030712),
      constraints: BoxConstraints(
        minHeight: isMobile ? 540 : (isTablet ? 680 : 860),
      ),
      child: Stack(
        children: [
          // ─── 1. Full-Width Background Image Animated Carousel / Cross-Fade ───
          // Per-slide fit and alignment: hero-pic 1&2 cover with Alignment.topRight; hero-pic3 fits height without top/bottom cropping
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                for (int i = 0; i < _bgImages.length; i++)
                  AnimatedOpacity(
                    key: ValueKey<String>(_bgImages[i]),
                    opacity: _currentBgIndex == i ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1400),
                    curve: Curves.easeInOutCubic,
                    child: Image.asset(
                      _bgImages[i],
                      fit: _getBgFit(i, isDesktop),
                      alignment: _getBgAlignment(i, isMobile, isDesktop),
                    ),
                  ),
              ],
            ),
          ),

          // ─── Directional Scrim Overlay ───
          // On Desktop: Directional horizontal scrim protects left-aligned hero copy while keeping the right illustration completely bright and clear.
          // On Mobile: Enhanced high-contrast scrim (66%-78% opacity) providing solid readability for the hero copy while still letting the background slider artwork show through.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isMobile
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF030712).withValues(alpha: 0.78),
                          const Color(0xFF030712).withValues(alpha: 0.66),
                          const Color(0xFF030712).withValues(alpha: 0.70),
                          const Color(0xFF030712).withValues(alpha: 0.80),
                        ],
                        stops: const [0.0, 0.25, 0.70, 1.0],
                      )
                    : LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF030712).withValues(alpha: 0.96),
                          const Color(
                            0xFF030712,
                          ).withValues(alpha: isTablet ? 0.70 : 0.45),
                          const Color(0xFF030712).withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.32, 0.58, 1.0],
                      ),
              ),
            ),
          ),

          // ─── 2. Foreground Content (Header + Hero Copy & CTAs) ───
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Overlaid Header (Promo Bar & Floating Glass Navbar)
                if (widget.header != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16.0 : (isTablet ? 28.0 : 40.0),
                      vertical: isMobile ? 12.0 : 20.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1320),
                        child: widget.header!,
                      ),
                    ),
                  ),

                // Symmetrical top spacing matching bottom margin
                SizedBox(height: verticalMargin),

                // Hero Content (Centered on mobile for a unified premium look; left-aligned on desktop/tablet)
                Padding(
                  padding: EdgeInsets.only(
                    left: isMobile ? 20.0 : (isTablet ? 36.0 : 56.0),
                    right: isMobile ? 20.0 : 36.0,
                  ),
                  child: Align(
                    alignment: isMobile
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? 540 : (isTablet ? 540 : 620),
                      ),
                      child: Column(
                        crossAxisAlignment: isMobile
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Heading:
                          // Line 1: "Master Any Subject with a"
                          // Line 2: "Team of AI Agents" (with gradient look)
                          SpringEntranceBlock(
                            delayMs: 250,
                            durationMs: 700,
                            fromOffset: const Offset(0, 18),
                            child: Column(
                              crossAxisAlignment: isMobile
                                  ? CrossAxisAlignment.center
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Master Any Subject with a',
                                  textAlign: isMobile
                                      ? TextAlign.center
                                      : TextAlign.start,
                                  style: TextStyle(
                                    fontSize: isMobile
                                        ? 28
                                        : (isTablet ? 38 : 50),
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFF8FAFC),
                                    letterSpacing: -1.2,
                                    height: 1.12,
                                    shadows: isMobile
                                        ? [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.90,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.75,
                                              ),
                                              blurRadius: 14,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GradientText(
                                  'Team of AI Agents',
                                  textAlign: isMobile
                                      ? TextAlign.center
                                      : TextAlign.start,
                                  gradient: AppColors.primaryGradient,
                                  style: TextStyle(
                                    fontSize: isMobile
                                        ? 30
                                        : (isTablet ? 40 : 52),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.2,
                                    height: 1.20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Sub-heading Text
                          SpringEntranceBlock(
                            delayMs: 500,
                            durationMs: 700,
                            fromOffset: const Offset(0, 16),
                            child: Text(
                              'Stop skimming passive chatbot text. Our supervisor agent decomposes any topic into adaptive milestones, orchestrating verified Socratic dialogue, timestamped YouTube video clips, live arXiv citations, research papers, and interactive assessments in real time.',
                              textAlign: isMobile
                                  ? TextAlign.center
                                  : TextAlign.start,
                              style: TextStyle(
                                fontSize: isMobile
                                    ? 14.5
                                    : (isTablet ? 15.5 : 16.5),
                                color: isMobile
                                    ? const Color(0xFFE2E8F0)
                                    : const Color(0xFFCBD5E1),
                                fontWeight: isMobile
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                height: 1.62,
                                letterSpacing: -0.2,
                                shadows: isMobile
                                    ? [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.85,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.65,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Action Buttons: Start Learning for Free & Watch a Demo
                          SpringEntranceBlock(
                            delayMs: 650,
                            durationMs: 700,
                            fromOffset: const Offset(0, 16),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 12,
                              alignment: isMobile
                                  ? WrapAlignment.center
                                  : WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _HeroPrimaryButton(
                                  text: 'Start Learning for Free',
                                  onTap: () => context.go('/auth'),
                                  isMobile: isMobile,
                                ),
                                _HeroSecondaryDemoButton(
                                  text: 'Watch a Demo',
                                  onTap: () => widget.onExploreTap?.call(),
                                  isMobile: isMobile,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Symmetrical bottom spacing matching top margin; preserves ample clearance from slider
                SizedBox(height: verticalMargin),
              ],
            ),
          ),

          // ─── 3. Subtle Floating Slider Indicator Pills (Bottom-Right, hidden on mobile) ───
          if (!isMobile)
            Positioned(
              bottom: 28,
              right: 36,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_bgImages.length, (index) {
                  final bool isActive = _currentBgIndex == index;
                  return GestureDetector(
                    onTap: () => _setBgIndex(index),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: isActive ? AppColors.primaryGradient : null,
                          color: isActive
                              ? null
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );

    return heroContent;
  }
}

// -----------------------------------------------------------------------------
// SHARED MICRO-COMPONENTS
// -----------------------------------------------------------------------------

/// Premium gradient action button with subtle hover lift and specular sweep
class _HeroPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isMobile;

  const _HeroPrimaryButton({
    required this.text,
    required this.onTap,
    required this.isMobile,
  });

  @override
  State<_HeroPrimaryButton> createState() => _HeroPrimaryButtonState();
}

class _HeroPrimaryButtonState extends State<_HeroPrimaryButton>
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
            height: widget.isMobile ? 48 : 52,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isMobile ? 22 : 28,
            ),
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
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.isMobile ? 14 : 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
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

/// Frosted glass secondary action button for demo trigger
class _HeroSecondaryDemoButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isMobile;

  const _HeroSecondaryDemoButton({
    required this.text,
    required this.onTap,
    required this.isMobile,
  });

  @override
  State<_HeroSecondaryDemoButton> createState() =>
      _HeroSecondaryDemoButtonState();
}

class _HeroSecondaryDemoButtonState extends State<_HeroSecondaryDemoButton> {
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
          child: Container(
            height: widget.isMobile ? 48 : 52,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isMobile ? 20 : 24,
            ),
            decoration: BoxDecoration(
              color: _isHovered
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: _isHovered
                    ? Colors.white.withValues(alpha: 0.40)
                    : Colors.white.withValues(alpha: 0.20),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
                if (_isHovered)
                  BoxShadow(
                    color: const Color(0xFF00F5D4).withValues(alpha: 0.20),
                    blurRadius: 18,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Color(0xFF00F5D4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.text,
                  style: TextStyle(
                    color: const Color(0xFFF1F5F9),
                    fontSize: widget.isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
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
