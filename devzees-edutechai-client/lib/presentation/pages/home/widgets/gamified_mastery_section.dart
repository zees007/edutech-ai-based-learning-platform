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
      imagePath: 'assets/images/gamification/tile1.jpg',
      icon: Icons.trending_up_rounded,
      accentColor: Color(0xFFF59E0B),
      title: 'Streak Multipliers (+10% Daily XP Boost)',
      description:
          'Build an unstoppable daily habit. Each consecutive day adds +10% bonus XP so you level up twice as fast.',
    ),
    _GamificationTileItem(
      imagePath: 'assets/images/gamification/tile2.jpg',
      icon: Icons.bolt_rounded,
      accentColor: Color(0xFF10B981),
      title: 'Instant Quiz Feedback (+30 XP Bonus)',
      description:
          'Test your comprehension at each milestone with dynamic quizzes, immediate rationales, and bonus XP for 100% accuracy.',
    ),
    _GamificationTileItem(
      imagePath: 'assets/images/gamification/tile3.jpg',
      icon: Icons.military_tech_rounded,
      accentColor: Color(0xFFEC4899),
      title: '10-Level Mastery Ladder',
      description:
          'Advance from Curious Explorer (Level 1) to Grand Sage (Level 10) by conquering milestones across every subject.',
    ),
    _GamificationTileItem(
      imagePath: 'assets/images/gamification/tile4.jpg',
      icon: Icons.download_for_offline_rounded,
      accentColor: Color(0xFF00F5D4),
      title: 'Obsidian, Notion & PDF Export',
      description:
          'Own your knowledge forever. Export full sessions as clean Markdown, HTML, or styled PDFs with formulas and video links.',
    ),
  ];

  int _currentIndex = 0;
  Timer? _sliderTimer;

  @override
  void initState() {
    super.initState();
    _startSliderTimer();
  }

  void _startSliderTimer() {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
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
        // ─── Centered Section Header ───
        _buildSectionHeader(context, isMobile: isMobile),
        SizedBox(height: isMobile ? 32 : 48),

        // ─── Two-Panel Showcase (Desktop side-by-side, Mobile stacked) ───
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Panel: Synchronized Pure Image Slider
              Expanded(
                flex: 5,
                child: _buildShowcaseSlider(context, isMobile: false),
              ),
              const SizedBox(width: 44),

              // Right Panel: 4 Highlightable Feature Cards
              Expanded(
                flex: 6,
                child: _buildFeatureCardsList(context, isMobile: false),
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
  // SECTION HEADER (CENTERED)
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
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFF59E0B),
                  size: 14,
                ),
                SizedBox(width: 8),
                Text(
                  'DAILY HABITS & REWARDS',
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

        // Centered Headline with Gradient
        GradientText(
          'Gamified Mastery Ladders That Make Hard Subjects Addictive',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Centered Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
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
    final double height = isMobile ? 340 : 420;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? 500 : 540),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF070914),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: activeTile.accentColor.withValues(alpha: 0.35),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: activeTile.accentColor.withValues(alpha: 0.18),
                blurRadius: 40,
                spreadRadius: -2,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Crossfade Pure Image Slider (No Overlays)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Image.asset(
                    activeTile.imagePath,
                    key: ValueKey<String>(activeTile.imagePath),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF0B0E22),
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

                // Subtle bottom scrim gradient for clean dot readability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.60),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Floating Slide Dot Indicators
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_tiles.length, (index) {
                      final bool isSelected = index == _currentIndex;
                      return GestureDetector(
                        onTap: () => _onTileSelected(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 24 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? activeTile.accentColor
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: activeTile.accentColor.withValues(alpha: 0.7),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // RIGHT PANEL: 4 HIGHLIGHTABLE FEATURE CARDS
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildFeatureCardsList(BuildContext context, {required bool isMobile}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(_tiles.length, (index) {
        final _GamificationTileItem item = _tiles[index];
        final bool isSelected = index == _currentIndex;

        return Padding(
          padding: EdgeInsets.only(bottom: index == _tiles.length - 1 ? 0 : 12),
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
// REUSABLE HIGHLIGHTABLE FEATURE TILE
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
  State<_HighlightableFeatureCard> createState() => _HighlightableFeatureCardState();
}

class _HighlightableFeatureCardState extends State<_HighlightableFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = widget.isSelected || _isHovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.iconColor.withValues(alpha: 0.12)
                : (_isHovered ? const Color(0xFF10142B) : const Color(0xDD090B18)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? widget.iconColor.withValues(alpha: 0.85)
                  : (_isHovered
                      ? widget.iconColor.withValues(alpha: 0.45)
                      : Colors.white.withValues(alpha: 0.08)),
              width: widget.isSelected ? 1.6 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? widget.iconColor.withValues(alpha: 0.25)
                    : (_isHovered
                        ? widget.iconColor.withValues(alpha: 0.14)
                        : Colors.black.withValues(alpha: 0.35)),
                blurRadius: highlighted ? 22 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Icon Badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.iconColor.withValues(alpha: 0.24)
                      : widget.iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.iconColor
                        : widget.iconColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isSelected ? Colors.white : widget.iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),

              // Text Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: widget.isSelected ? FontWeight.w900 : FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (widget.isSelected)
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.iconColor,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.iconColor,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: widget.isSelected
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF94A3B8),
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
