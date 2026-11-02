import 'dart:async';
import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';

/// Metadata definition for each gamification feature tile & slider item.
class _GamificationTileItem {
  final String imagePath;
  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;

  const _GamificationTileItem({
    required this.imagePath,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
  });
}

/// Gamified Mastery Ladder section showcasing EduTech AI's motivation loop.
///
/// Features:
/// - Centered Header matching [AgentsSection]:
///   - 'DAILY HABITS & REWARDS' stadium capsule badge
///   - 'Gamified Mastery Ladders That Make Hard Subjects Addictive' gradient headline
///   - Clean motivational subtitle
/// - Two-panel responsive layout:
///   - Left: Dynamic pure image slider showcasing `tile1.jpg`, `tile2.jpg`, `tile3.jpg`, `tile4.jpg`
///     with uncluttered visuals, smooth crossfades, and subtle slide pagination dots.
///   - Right: 4 interactive feature cards. When an image slide changes, its corresponding
///     text card is highlighted with a glowing border and accent background. Clicking any
///     card immediately navigates the slider to that item.
class GamifiedMasterySection extends StatefulWidget {
  const GamifiedMasterySection({super.key});

  @override
  State<GamifiedMasterySection> createState() => _GamifiedMasterySectionState();
}

class _GamifiedMasterySectionState extends State<GamifiedMasterySection> {
  static const List<_GamificationTileItem> _tiles = [
    _GamificationTileItem(
      imagePath: 'assets/images/gamification/tile1.png',
      icon: Icons.trending_up_rounded,
      accentColor: Color(0xFFF59E0B),
      title: 'Streak Multipliers (+10% Daily XP Boost)',
      description:
          'Build an unstoppable daily habit. Each consecutive day adds +10% bonus XP so you level up twice as fast.',
    ),
    _GamificationTileItem(
      imagePath: 'assets/images/gamification/tile2.png',
      icon: Icons.bolt_rounded,
      accentColor: Color(0xFF3B82F6),
      title: 'Instant Quiz Feedback (+30 XP Bonus)',
      description:
          'Test your comprehension at each milestone with dynamic quizzes, immediate rationales, and bonus XP for 100% accuracy.',
    ),
    _GamificationTileItem(
      imagePath: 'assets/images/gamification/tile3.png',
      icon: Icons.military_tech_rounded,
      accentColor: Color(0xFFA855F7),
      title: '10-Level Mastery Ladder',
      description:
          'Advance from Curious Explorer (Level 1) to Grand Sage (Level 10) by conquering milestones across every subject.',
    ),
    _GamificationTileItem(
      imagePath: 'assets/images/gamification/tile4.png',
      icon: Icons.download_for_offline_rounded,
      accentColor: Color(0xFF10B981),
      title: 'Obsidian, Notion & PDF Export',
      description:
          'Own your knowledge forever. Export full sessions as clean Markdown, HTML, or styled PDFs with formulas and video links.',
    ),
  ];

  int _currentIndex = 0;
  Timer? _sliderTimer;
  bool _isSliderHovered = false;
  int? _hoveredZone; // -1 for left, 1 for right, null for none
  DateTime _lastNavTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _startSliderTimer();
  }

  void _startSliderTimer() {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_isSliderHovered) return; // Pause auto-rotation while user is hovering
      setState(() {
        _currentIndex = (_currentIndex + 1) % _tiles.length;
      });
    });
  }

  void _onTileSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    _startSliderTimer(); // Reset auto-slide timer on user tap
  }

  void _navigateSlide(int direction) {
    final now = DateTime.now();
    if (now.difference(_lastNavTime).inMilliseconds < 250) return;
    _lastNavTime = now;

    setState(() {
      _currentIndex =
          (_currentIndex + direction + _tiles.length) % _tiles.length;
    });
    _startSliderTimer();
  }

  void _onZoneEntered(int zone) {
    setState(() {
      _hoveredZone = zone;
    });
    _navigateSlide(zone);
  }

  void _onZoneExited(int zone) {
    if (_hoveredZone == zone) {
      setState(() {
        _hoveredZone = null;
      });
    }
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = Responsive.isMobile(context);
    final bool isDesktop = screenWidth >= 960;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ─── Section Header (Centered on Page) ───
        Center(child: _buildSectionHeader(context, isMobile: isMobile)),
        SizedBox(height: isMobile ? 32 : 48),

        // ─── Two-Panel Showcase (Desktop side-by-side: Features LEFT, Slider RIGHT) ───
        if (isDesktop)
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Base Layer: Feature Cards on the LEFT define the natural section height
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildFeatureCardsList(context, isMobile: false),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(flex: 7, child: SizedBox.shrink()),
                ],
              ),

              // Overlay Layer: Image Slider on the RIGHT stretches to match EXACT top & bottom of the cards
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(
                      flex: 4,
                      child: IgnorePointer(child: SizedBox.shrink()),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 7,
                      child: _buildShowcaseSlider(context, isMobile: false),
                    ),
                  ],
                ),
              ),
            ],
          )
        else ...[
          _buildShowcaseSlider(context, isMobile: true),
          const SizedBox(height: 28),
          _buildFeatureCardsList(context, isMobile: true),
        ],
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // SECTION HEADER
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(BuildContext context, {required bool isMobile}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Section Header Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                blurRadius: 18,
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.military_tech_rounded,
                  color: Color(0xFFF59E0B),
                  size: 15,
                ),
                SizedBox(width: 8),
                Text(
                  'GAMIFICATION & REWARDS',
                  style: TextStyle(
                    color: Color(0xFFFCD34D),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Headline with Gradient (Centered)
        GradientText(
          'Gamified Mastery Ladders That Make Hard Subjects Addictive',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Subtitle (Centered)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Text(
            'Traditional learning apps rely on hollow notifications. EduTechAI keeps you genuinely motivated with interactive quizzes, streak multipliers, 10 progressive mastery levels, and zero lock-in exports.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: isMobile ? 15 : 17,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // LEFT PANEL: SYNCHRONIZED PURE IMAGE SLIDER
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildShowcaseSlider(BuildContext context, {required bool isMobile}) {
    final _GamificationTileItem activeTile = _tiles[_currentIndex];

    final Widget sliderContent = MouseRegion(
      onEnter: (_) {
        setState(() => _isSliderHovered = true);
      },
      onExit: (_) {
        setState(() {
          _isSliderHovered = false;
          _hoveredZone = null;
        });
      },
      child: SizedBox(
        key: const Key('slider_showcase_container'),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Soft ambient volumetric glow smoothly morphing with active tile accent color
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: isMobile ? 300 : (_isSliderHovered ? 620 : 500),
                height: isMobile ? 220 : (_isSliderHovered ? 450 : 370),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      activeTile.accentColor.withValues(
                        alpha: _isSliderHovered ? 0.30 : 0.20,
                      ),
                      activeTile.accentColor.withValues(
                        alpha: _isSliderHovered ? 0.08 : 0.04,
                      ),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Borderless Floating 3D Artwork with hover zoom-in & buttery-smooth crossfade
            AnimatedScale(
              scale: _isSliderHovered ? 1.20 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [...previousChildren, ?currentChild],
                ),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                    child: child,
                  );
                },
                child: Image.asset(
                  activeTile.imagePath,
                  key: ValueKey<String>(activeTile.imagePath),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.transparent,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: Colors.white24,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Left & Right Interactive Navigation Zones (Mouse-over to switch slides)
            Positioned.fill(
              child: Row(
                children: [
                  // Left Zone: Navigates to Previous Slide
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => _onZoneEntered(-1),
                      onExit: (_) => _onZoneExited(-1),
                      child: GestureDetector(
                        onTap: () => _navigateSlide(-1),
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 14),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _hoveredZone == -1 ? 0.9 : 0.0,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xCC090B18),
                                border: Border.all(
                                  color: activeTile.accentColor
                                      .withValues(alpha: 0.65),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: activeTile.accentColor
                                        .withValues(alpha: 0.35),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: activeTile.accentColor,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Right Zone: Navigates to Next Slide
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => _onZoneEntered(1),
                      onExit: (_) => _onZoneExited(1),
                      child: GestureDetector(
                        onTap: () => _navigateSlide(1),
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 14),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _hoveredZone == 1 ? 0.9 : 0.0,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xCC090B18),
                                border: Border.all(
                                  color: activeTile.accentColor
                                      .withValues(alpha: 0.65),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: activeTile.accentColor
                                        .withValues(alpha: 0.35),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: activeTile.accentColor,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (isMobile) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: AspectRatio(aspectRatio: 2400 / 1792, child: sliderContent),
        ),
      );
    }

    return Center(child: sliderContent);
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 4 HIGHLIGHTABLE FEATURE CARDS
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildFeatureCardsList(
    BuildContext context, {
    required bool isMobile,
  }) {
    final double bottomSpacing = isMobile ? 10 : 12;

    return Column(
      key: isMobile
          ? const Key('feature_cards_column_mobile')
          : const Key('feature_cards_column_desktop'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(_tiles.length, (index) {
        final _GamificationTileItem item = _tiles[index];
        final bool isSelected = index == _currentIndex;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == _tiles.length - 1 ? 0 : bottomSpacing,
          ),
          child: _HighlightableFeatureCard(
            icon: item.icon,
            iconColor: item.accentColor,
            title: item.title,
            description: item.description,
            isSelected: isSelected,
            onTap: () => _onTileSelected(index),
          ),
        );
      }),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// REUSABLE HIGHLIGHTABLE FEATURE TILE (SLEEK & COMPACT)
// ═════════════════════════════════════════════════════════════════════════════

class _HighlightableFeatureCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _HighlightableFeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_HighlightableFeatureCard> createState() =>
      _HighlightableFeatureCardState();
}

class _HighlightableFeatureCardState extends State<_HighlightableFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool highlighted = widget.isSelected || _isHovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
            widget.isSelected ? 3.0 : (_isHovered ? 1.5 : 0.0),
            0.0,
            0.0,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 18,
            vertical: isMobile ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.iconColor.withValues(alpha: 0.13)
                : (_isHovered
                      ? widget.iconColor.withValues(alpha: 0.09)
                      : const Color(0xDD090B18)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? widget.iconColor.withValues(alpha: 0.90)
                  : (_isHovered
                        ? widget.iconColor.withValues(alpha: 0.65)
                        : Colors.white.withValues(alpha: 0.08)),
              width: widget.isSelected ? 1.5 : 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? widget.iconColor.withValues(alpha: 0.28)
                    : (_isHovered
                          ? widget.iconColor.withValues(alpha: 0.20)
                          : Colors.black.withValues(alpha: 0.35)),
                blurRadius: highlighted ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sleek Vector Icon Badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: isMobile ? 34 : 38,
                height: isMobile ? 34 : 38,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.iconColor.withValues(alpha: 0.24)
                      : (_isHovered
                          ? widget.iconColor.withValues(alpha: 0.18)
                          : widget.iconColor.withValues(alpha: 0.10)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.iconColor
                        : (_isHovered
                            ? widget.iconColor.withValues(alpha: 0.60)
                            : widget.iconColor.withValues(alpha: 0.25)),
                    width: 1.1,
                  ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: widget.iconColor.withValues(alpha: 0.35),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isSelected ? Colors.white : widget.iconColor,
                  size: isMobile ? 17 : 19,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 15),

              // Title and Description in a compact, sleek vertical column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 14.0 : 15.0,
                        fontWeight: widget.isSelected
                            ? FontWeight.w900
                            : FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: widget.isSelected
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF94A3B8),
                        fontSize: isMobile ? 12.0 : 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Smooth Active Right Chevron (fixed reserved slot prevents text reflow!)
              SizedBox(
                width: isMobile ? 20 : 24,
                height: isMobile ? 20 : 24,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    opacity: widget.isSelected ? 1.0 : 0.0,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: widget.iconColor,
                      size: isMobile ? 20 : 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
