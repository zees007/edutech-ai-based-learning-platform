import 'dart:async';
import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/presentation/widgets/word_by_word_reveal.dart';
import 'package:go_router/go_router.dart';

/// Ultra-premium SaaS hero section designed for a high-converting, agency-grade presentation.
///
/// Features:
/// - Futuristic glass badge pill with live radar beacon and gradient border.
/// - Punchy high-contrast typography with multi-stop electric gradient.
/// - Interactive search input with quick-topic starter chips.
/// - Full-width cinematic product carousel showcasing the 3 high-resolution assets.
class HeroSection extends StatefulWidget {
  final VoidCallback? onExploreTap;
  final bool includeCarousel;

  const HeroSection({
    super.key,
    this.onExploreTap,
    this.includeCarousel = true,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final TextEditingController _promptController = TextEditingController();

  static const List<String> _suggestedTopics = [
    'Quantum Superposition',
    'Transformer Attention',
    'CRISPR Gene Editing',
    'Neural Tangent Kernel',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _handleQuickStart([String? topic]) {
    if (topic != null) {
      _promptController.text = topic;
    }
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ─── 1. Floating Live Architecture Badge ───
        SpringEntranceBlock(
          delayMs: 250,
          durationMs: 700,
          fromOffset: const Offset(0, 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xCC0B0D1B),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: const Color(0xFF60A5FA).withValues(alpha: 0.30),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B68F6).withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _PulsingBeaconDot(),
                const SizedBox(width: 10),
                Text(
                  'NEXT-GEN COGNITIVE MULTI-AGENT ARCHITECTURE',
                  style: TextStyle(
                    color: const Color(0xFFE2E8F0),
                    fontSize: isMobile ? 9.5 : 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'v2.4',
                    style: TextStyle(
                      color: Color(0xFF00F5D4),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ─── 2. Headline with Word-by-Word Reveal ───
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isMobile ? 360 : 920),
          child: WordByWordReveal(
            text: 'Master Complex Topics with an Autonomous AI Squad',
            gradientWords: const ['autonomous', 'ai', 'squad'],
            gradient: const LinearGradient(
              colors: [
                Color(0xFF60A5FA), // Azure Blue
                Color(0xFF9061F9), // Royal Violet
                Color(0xFF00F5D4), // Cyan Spark
              ],
            ),
            initialDelayMs: 450,
            staggerMs: 70,
            wordDurationMs: 680,
            initialTranslateY: 26.0,
            style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
              fontSize: isMobile ? 34 : 58,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFF8FAFC),
              letterSpacing: -1.4,
              height: 1.10,
            ),
          ),
        ),
        const SizedBox(height: 22),

        // ─── 3. Subtitle with High-Contrast Typography ───
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isMobile ? 340 : 760),
          child: WordByWordReveal(
            text: 'Stop skimming passive chatbot text. Our supervisor agent decomposes any domain into adaptive milestones, orchestrating verified Socratic dialogue, timestamped video clips, and live arXiv citations in real-time.',
            initialDelayMs: 950,
            staggerMs: 18,
            wordDurationMs: 550,
            initialTranslateY: 12.0,
            style: AppTextStyles.body1.copyWith(
              fontSize: isMobile ? 15 : 17.5,
              color: const Color(0xFF94A3B8),
              height: 1.60,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 36),

        // ─── 4. Quick-Start Input Capsule with Topic Chips ───
        SpringEntranceBlock(
          delayMs: 1300,
          durationMs: 700,
          fromOffset: const Offset(0, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main Input Capsule
              Container(
                width: isMobile ? double.infinity : 640,
                height: isMobile ? 54 : 60,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xEE090B18),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.60),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.20),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF00F5D4),
                      size: 21,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        onSubmitted: (val) => _handleQuickStart(val),
                        style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: isMobile
                              ? 'Enter topic (e.g. Quantum Physics)...'
                              : 'What do you want to master today? (e.g. Transformers, CRISPR)...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
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
                      onTap: () => _handleQuickStart(_promptController.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Interactive Suggested Chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'Try:',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ..._suggestedTopics.map(
                    (topic) => GestureDetector(
                      onTap: () => _handleQuickStart(topic),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.09),
                          ),
                        ),
                        child: Text(
                          topic,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // ─── 5. Trust Indicators ───
        SpringEntranceBlock(
          delayMs: 1500,
          durationMs: 700,
          fromOffset: const Offset(0, 14),
          child: Wrap(
            spacing: 14,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _TrustBadge(icon: Icons.check_circle_rounded, text: '10 Free AI Sessions / Month'),
              _TrustBadge(icon: Icons.verified_user_rounded, text: 'Zero Hallucinations Grounded'),
              _TrustBadge(icon: Icons.download_rounded, text: 'Export to Obsidian & Notion'),
            ],
          ),
        ),

        // Optional Inline Carousel (When not extracted to separate wide sliver)
        if (widget.includeCarousel) ...[
          const SizedBox(height: 48),
          SpringEntranceBlock(
            delayMs: 1750,
            durationMs: 800,
            fromOffset: const Offset(0, 30),
            child: const FullWidthHeroCarousel(),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FULL-WIDTH HERO CAROUSEL — Cinematic Product Showcase
// ═══════════════════════════════════════════════════════════════════════════════

class _HeroCarouselSlide {
  final String imagePath;
  final String badgeText;
  final String captionTitle;
  final String captionSubtitle;
  final String tabLabel;
  final IconData tabIcon;

  const _HeroCarouselSlide({
    required this.imagePath,
    required this.badgeText,
    required this.captionTitle,
    required this.captionSubtitle,
    required this.tabLabel,
    required this.tabIcon,
  });
}

/// Full-width auto-playing cinematic product carousel displaying new hero images.
class FullWidthHeroCarousel extends StatefulWidget {
  const FullWidthHeroCarousel({super.key});

  @override
  State<FullWidthHeroCarousel> createState() => _FullWidthHeroCarouselState();
}

class _FullWidthHeroCarouselState extends State<FullWidthHeroCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _pulseController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  bool _isHovered = false;

  static const List<_HeroCarouselSlide> _slides = [
    _HeroCarouselSlide(
      imagePath: 'assets/images/home/hero-pic.jpg',
      badgeText: 'AUTONOMOUS MULTI-AGENT BLACKBOARD ARCHITECTURE',
      captionTitle: 'Autonomous Multi-Agent AI Core',
      captionSubtitle: 'Six specialized agents collaborate simultaneously on a shared cognitive blackboard, orchestrating curriculum milestones, Socratic scaffolding, and citations.',
      tabLabel: 'Multi-Agent Core',
      tabIcon: Icons.hub_rounded,
    ),
    _HeroCarouselSlide(
      imagePath: 'assets/images/home/hero-pic2.jpg',
      badgeText: 'SOCRATIC & ADAPTIVE PEDAGOGICAL ENGINE',
      captionTitle: 'Interactive Cognitive Synthesis',
      captionSubtitle: 'Engage with step-by-step concept flowcharts, grounded LaTeX equations, and Socratic guiding prompts tailored to your comprehension velocity.',
      tabLabel: 'Cognitive Engine',
      tabIcon: Icons.psychology_rounded,
    ),
    _HeroCarouselSlide(
      imagePath: 'assets/images/home/new-workspace-preview.png',
      badgeText: 'DUAL-PANEL MULTI-MODAL WORKSPACE',
      captionTitle: 'Active Dual-Panel Workspace',
      captionSubtitle: 'Socratic dialogue on the left panel, verified YouTube transcript clips, arXiv research preprints, and formative quizzes on the right panel.',
      tabLabel: 'Dual Workspace',
      tabIcon: Icons.space_dashboard_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _pulseController.dispose();
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

  void _goToPrevious() {
    final prevPage = (_currentPage - 1 + _slides.length) % _slides.length;
    _pageController.animateToPage(
      prevPage,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goToNext() {
    final nextPage = (_currentPage + 1) % _slides.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        children: [
          // ─── 1. Desktop Tab Direct Switcher ───
          if (!isMobile) ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xDD080A16),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.50),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_slides.length, (index) {
                  final slide = _slides[index];
                  final isSelected = _currentPage == index;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.50),
                                  blurRadius: 18,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            slide.tabIcon,
                            size: 15,
                            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            slide.tabLabel,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 22),
          ],

          // ─── 2. Cinema Full-Width Frame ───
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.40),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.32),
                  blurRadius: 75,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: const Color(0xFF00F5D4).withValues(alpha: 0.12),
                  blurRadius: 50,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.80),
                  blurRadius: 40,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: isMobile ? (16 / 10) : (16 / 9),
                child: Stack(
                  children: [
                    // Image PageView
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
                            Image.asset(
                              slide.imagePath,
                              fit: BoxFit.cover,
                            ),

                            // Bottom readability scrim
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.transparent,
                                      const Color(0xDD030712),
                                    ],
                                    stops: const [0.0, 0.45, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            // Top-left live status pill
                            Positioned(
                              top: isMobile ? 12 : 20,
                              left: isMobile ? 12 : 24,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 10 : 14,
                                  vertical: isMobile ? 5 : 7,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xEE080A16),
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(
                                    color: const Color(0xFF00F5D4).withValues(alpha: 0.55),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.50),
                                      blurRadius: 10,
                                    ),
                                  ],
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
                                          BoxShadow(
                                            color: Color(0xFF00F5D4),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      slide.badgeText,
                                      style: TextStyle(
                                        color: const Color(0xFFF8FAFC),
                                        fontSize: isMobile ? 9 : 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Bottom Caption Glass Card
                            Positioned(
                              bottom: isMobile ? 12 : 24,
                              left: isMobile ? 12 : 24,
                              right: isMobile ? 12 : 24,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 14 : 24,
                                  vertical: isMobile ? 12 : 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xEE090B18),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      blurRadius: 28,
                                      offset: const Offset(0, 8),
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
                                              color: const Color(0xFFF8FAFC),
                                              fontSize: isMobile ? 14 : 18,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            slide.captionSubtitle,
                                            style: TextStyle(
                                              color: const Color(0xFFB9BECF),
                                              fontSize: isMobile ? 11 : 13,
                                              fontWeight: FontWeight.w500,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    // Slide counter pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.28),
                                        borderRadius: BorderRadius.circular(9999),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.50),
                                        ),
                                      ),
                                      child: Text(
                                        '${index + 1} / ${_slides.length}',
                                        style: const TextStyle(
                                          color: Color(0xFFF8FAFC),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
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

                    // Left Chevron Button
                    Positioned(
                      left: isMobile ? 8 : 18,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _CarouselArrowButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: _goToPrevious,
                          tooltip: 'Previous Slide',
                          isMobile: isMobile,
                        ),
                      ),
                    ),

                    // Right Chevron Button
                    Positioned(
                      right: isMobile ? 8 : 18,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _CarouselArrowButton(
                          icon: Icons.chevron_right_rounded,
                          onTap: _goToNext,
                          tooltip: 'Next Slide',
                          isMobile: isMobile,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // ─── 3. Breathing Glow Indicator Dots ───
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final pulse = _pulseController.value;
              return Row(
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
                      width: isActive ? (isMobile ? 28 : 38) : 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        color: isActive
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.20),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.50 + 0.35 * pulse),
                                  blurRadius: 10 + 6 * pulse,
                                  spreadRadius: 1 + 1 * pulse,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF00F5D4).withValues(alpha: 0.30 * pulse),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Floating glass arrow button for carousel navigation
class _CarouselArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isMobile;

  const _CarouselArrowButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    required this.isMobile,
  });

  @override
  State<_CarouselArrowButton> createState() => _CarouselArrowButtonState();
}

class _CarouselArrowButtonState extends State<_CarouselArrowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isHovered ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: widget.isMobile ? 36 : 46,
              height: widget.isMobile ? 36 : 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.85)
                    : const Color(0xDD090B18),
                border: Border.all(
                  color: _isHovered
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.20),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  if (_isHovered)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.50),
                      blurRadius: 20,
                    ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: widget.isMobile ? 22 : 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED MICRO-COMPONENTS
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
  final IconData icon;
  final String text;

  const _TrustBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          Icon(
            icon,
            color: const Color(0xFF10B981),
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12.5,
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
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: _isHovered ? const Color(0xFFF1F5F9) : Colors.white,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: _isHovered ? 0.40 : 0.22),
                  blurRadius: 18,
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
