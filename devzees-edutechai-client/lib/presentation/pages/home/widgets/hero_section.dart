import 'dart:async';
import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/presentation/widgets/word_by_word_reveal.dart';
import 'package:go_router/go_router.dart';

/// Ultra-premium SaaS hero section with auto-playing product showcase carousel.
///
/// Features:
/// - Staggered spring reveals across badge, word-by-word headline, subtitle, and CTA.
/// - Frosted glass badge pill with live pulsating radar beacon.
/// - High-contrast action pills & interactive quick-masterclass prompt bar.
/// - Floating frosted social proof trust badges.
/// - Auto-playing hero carousel with crossfade transitions, glowing indicators,
///   and overlay captions — showcasing the actual product.
class HeroSection extends StatefulWidget {
  final VoidCallback? onExploreTap;

  const HeroSection({super.key, this.onExploreTap});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _handleQuickStart() {
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ─── 1. Staggered Badge Pill (Delay 300ms) ───
        SpringEntranceBlock(
          delayMs: 300,
          durationMs: 700,
          fromOffset: const Offset(0, 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live Radar Beacon Pulse Dot
                const _PulsingBeaconDot(),
                const SizedBox(width: 9),
                Text(
                  'AUTONOMOUS MULTI-AGENT BLACKBOARD ARCHITECTURE',
                  style: TextStyle(
                    color: const Color(0xFFD4D8E8),
                    fontSize: isMobile ? 9.5 : 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ─── 2. Headline with Word-by-Word Reveal (Delay 480ms) ───
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isMobile ? 360 : 900),
          child: WordByWordReveal(
            text: 'Master Any Subject with a Team of AI Agents',
            gradientWords: const ['team', 'of', 'ai', 'agents'],
            gradient: const LinearGradient(
              colors: [
                Color(0xFF60A5FA), // Electric cyan/blue
                Color(0xFF9061F9), // Royal violet
                Color(0xFFE879F9), // Vivid magenta
              ],
            ),
            initialDelayMs: 480,
            staggerMs: 80,
            wordDurationMs: 720,
            initialTranslateY: 28.0,
            style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
              fontSize: isMobile ? 32 : 54,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFEEF0F6),
              letterSpacing: -1.0,
              height: 1.12,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ─── 3. Subtitle with Word-by-Word Reveal (Delay 1100ms) ───
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isMobile ? 340 : 800),
          child: WordByWordReveal(
            text: 'Our supervisor agent decomposes complex topics into adaptive milestones, while specialized workers collaborate in real-time to deliver Socratic dialogue, timestamped video clips, academic preprints, and grounded quizzes.',
            initialDelayMs: 1100,
            staggerMs: 22,
            wordDurationMs: 600,
            initialTranslateY: 14.0,
            style: AppTextStyles.body1.copyWith(
              fontSize: isMobile ? 15 : 17.5,
              color: const Color(0xFFB9BECF),
              height: 1.55,
              letterSpacing: -0.1,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // ─── 4. Interactive Quick-Start & Dual CTA Bar (Delay 1450ms) ───
        SpringEntranceBlock(
          delayMs: 1450,
          durationMs: 700,
          fromOffset: const Offset(0, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Interactive Topic Bar (Glass capsule)
              Container(
                width: isMobile ? double.infinity : 620,
                height: isMobile ? 54 : 58,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF00F5D4),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        onSubmitted: (_) => _handleQuickStart(),
                        style: const TextStyle(
                          color: Color(0xFFEEF0F6),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: isMobile
                              ? 'Enter topic (e.g. Quantum Physics)...'
                              : 'What do you want to learn? (e.g., Transformers, Neuroplasticity)...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF8E94A8).withValues(alpha: 0.8),
                            fontSize: isMobile ? 13 : 14.5,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HeroSolidPillButton(
                      text: isMobile ? 'Start Free' : 'Generate Masterclass →',
                      onTap: _handleQuickStart,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Secondary Quick Action Link
              if (widget.onExploreTap != null)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: widget.onExploreTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.remove_red_eye_outlined, color: Color(0xFFB9BECF), size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Explore Dual-Panel Cognitive Workspace Preview',
                            style: TextStyle(
                              color: Color(0xFFB9BECF),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_downward_rounded, color: Color(0xFFB9BECF), size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ─── 5. Trust Indicators (Delay 1650ms) ───
        SpringEntranceBlock(
          delayMs: 1650,
          durationMs: 700,
          fromOffset: const Offset(0, 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _TrustBadge(text: '10 Free AI Sessions / Month'),
              _TrustBadge(text: 'Zero AI Hallucinations Grounded'),
              _TrustBadge(text: 'Export to Obsidian & Notion'),
            ],
          ),
        ),
        const SizedBox(height: 48),

        // ─── 6. Auto-Playing Product Showcase Carousel (Delay 1800ms) ───
        SpringEntranceBlock(
          delayMs: 1800,
          durationMs: 800,
          fromOffset: const Offset(0, 30),
          child: const _HeroCarousel(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HERO CAROUSEL — Auto-playing product showcase
// ═══════════════════════════════════════════════════════════════════════════════

class _HeroCarouselSlide {
  final String imagePath;
  final String badgeText;
  final String captionTitle;
  final String captionSubtitle;

  const _HeroCarouselSlide({
    required this.imagePath,
    required this.badgeText,
    required this.captionTitle,
    required this.captionSubtitle,
  });
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  bool _isHovered = false;

  static const _slides = [
    _HeroCarouselSlide(
      imagePath: 'assets/images/home/hero_blackboard_core.jpg',
      badgeText: 'AUTONOMOUS BLACKBOARD SYNCHRONIZATION',
      captionTitle: 'Multi-Agent AI Blackboard',
      captionSubtitle: '6 specialized agents collaborate in real-time on a shared cognitive workspace',
    ),
    _HeroCarouselSlide(
      imagePath: 'assets/images/home/workspace_preview.jpg',
      badgeText: 'DUAL-PANEL COGNITIVE ARCHITECTURE',
      captionTitle: 'Dual-Panel Workspace',
      captionSubtitle: 'Socratic tutor + multimedia curation side-by-side for active learning',
    ),
    _HeroCarouselSlide(
      imagePath: 'assets/images/home/second_brain_ecosystem.jpg',
      badgeText: 'SECOND BRAIN EXPORT ECOSYSTEM',
      captionTitle: 'Knowledge Export System',
      captionSubtitle: 'Export to Obsidian, Notion, Markdown & PDF — own your learning forever',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isHovered && mounted) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        children: [
          // Carousel Container with frosted glass frame
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 55,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: const Color(0xFF00F5D4).withValues(alpha: 0.10),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.70),
                  blurRadius: 36,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    // Page View
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image
                            Image.asset(
                              slide.imagePath,
                              fit: BoxFit.cover,
                            ),

                            // Bottom gradient scrim for caption legibility
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.transparent,
                                      const Color(0xCC05060D),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            // Top-left live badge
                            Positioned(
                              top: isMobile ? 10 : 16,
                              left: isMobile ? 10 : 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xDD090A14),
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(
                                    color: const Color(0xFF00F5D4).withValues(alpha: 0.5),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF00F5D4),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: Color(0xFF00F5D4), blurRadius: 6),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      slide.badgeText,
                                      style: TextStyle(
                                        color: const Color(0xFFEEF0F6),
                                        fontSize: isMobile ? 9 : 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Bottom caption glass card
                            Positioned(
                              bottom: isMobile ? 10 : 20,
                              left: isMobile ? 10 : 20,
                              right: isMobile ? 10 : 20,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 14 : 20,
                                  vertical: isMobile ? 10 : 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xDD090A14),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            slide.captionTitle,
                                            style: TextStyle(
                                              color: const Color(0xFFEEF0F6),
                                              fontSize: isMobile ? 13 : 16,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            slide.captionSubtitle,
                                            style: TextStyle(
                                              color: const Color(0xFF94A3B8),
                                              fontSize: isMobile ? 10.5 : 12.5,
                                              fontWeight: FontWeight.w500,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Slide number indicator
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.45),
                                        ),
                                      ),
                                      child: Text(
                                        '${index + 1}/${_slides.length}',
                                        style: const TextStyle(
                                          color: Color(0xFFEEF0F6),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Page Indicators — glowing animated dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (index) {
              final isActive = index == _currentPage;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  width: isActive ? 32 : 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9999),
                    color: isActive
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.20),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.60),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED SUB-WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// Pulsing Beacon Dot with breathing radar ring
class _PulsingBeaconDot extends StatefulWidget {
  const _PulsingBeaconDot();

  @override
  State<_PulsingBeaconDot> createState() => _PulsingBeaconDotState();
}

class _PulsingBeaconDotState extends State<_PulsingBeaconDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
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
      builder: (context, _) {
        final t = _controller.value;
        return SizedBox(
          width: 14,
          height: 14,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer radar wave
              Transform.scale(
                scale: 1.0 + t * 1.2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00F5D4).withValues(alpha: (1.0 - t) * 0.7),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              // Inner solid glowing dot
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00F5D4),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00F5D4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Modern Social Proof Frosted Micro-Badge
class _TrustBadge extends StatelessWidget {
  final String text;

  const _TrustBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 13,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFB9BECF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// High-contrast solid white pill CTA button with shimmer hover
class _HeroSolidPillButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _HeroSolidPillButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_HeroSolidPillButton> createState() => _HeroSolidPillButtonState();
}

class _HeroSolidPillButtonState extends State<_HeroSolidPillButton>
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
          scale: _isHovered ? 1.025 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: _isHovered ? const Color(0xFFF1F5F9) : Colors.white,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: _isHovered ? 0.35 : 0.20),
                  blurRadius: _isHovered ? 16 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(
                    color: Color(0xFF04050C),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                // Shimmer sweep overlay on hover
                if (_isHovered)
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, _) {
                      return Positioned.fill(
                        child: FractionallySizedBox(
                          widthFactor: 0.4,
                          alignment: Alignment(
                            -1.0 + _shimmerController.value * 3.0,
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
