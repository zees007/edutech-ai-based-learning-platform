import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';

/// Interactive deck/stack view for subscription plan cards on mobile devices.
///
/// Provides a swipeable card deck with 3D depth, previewing adjacent cards,
/// quick-switch plan pills at the top, and animated indicators with arrow controls.
class MobilePlanDeck extends StatefulWidget {
  final List<Widget> cards;
  final int initialIndex;
  final double cardHeight;
  final List<String>? planTitles;
  final bool showPillSelector;
  final bool showIndicators;
  final double viewportFraction;
  final ValueChanged<int>? onPageChanged;

  const MobilePlanDeck({
    super.key,
    required this.cards,
    this.initialIndex = 0,
    this.cardHeight = 600,
    this.planTitles,
    this.showPillSelector = true,
    this.showIndicators = true,
    this.viewportFraction = 0.86,
    this.onPageChanged,
  });

  @override
  State<MobilePlanDeck> createState() => _MobilePlanDeckState();
}

class _MobilePlanDeckState extends State<MobilePlanDeck> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex.clamp(
      0,
      widget.cards.isEmpty ? 0 : widget.cards.length - 1,
    );
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: widget.viewportFraction,
    );
  }

  @override
  void didUpdateWidget(MobilePlanDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex &&
        widget.initialIndex != _currentPage &&
        _pageController.hasClients) {
      _currentPage = widget.initialIndex.clamp(0, widget.cards.length - 1);
      _pageController.jumpToPage(_currentPage);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page >= widget.cards.length) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppColors.isDark;
    final titles = widget.planTitles;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Quick Plan Selector Pills (Top) ──
        if (widget.showPillSelector && titles != null && titles.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16182B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(titles.length, (i) {
                final isSelected = _currentPage == i;
                return GestureDetector(
                  onTap: () => _goToPage(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      titles[i],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Swipeable Deck / Stack View ──
        SizedBox(
          height: widget.cardHeight,
          child: PageView.builder(
            controller: _pageController,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.cards.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              widget.onPageChanged?.call(index);
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double pageOffset = 0;
                  if (_pageController.position.haveDimensions &&
                      _pageController.position.hasPixels) {
                    pageOffset =
                        (_pageController.page ?? _currentPage.toDouble()) - index;
                  } else {
                    pageOffset = _currentPage.toDouble() - index;
                  }

                  final double absOffset = pageOffset.abs();
                  // Scale interpolates smoothly: center is 1.0, sides are ~0.90
                  final double scale = (1.0 - (absOffset * 0.10)).clamp(0.88, 1.0);
                  // Opacity interpolates smoothly: center is 1.0, sides are ~0.65
                  final double opacity = (1.0 - (absOffset * 0.35)).clamp(0.65, 1.0);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_currentPage != index) {
                        _goToPage(index);
                      }
                    },
                    child: Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: widget.cards[index],
              );
            },
          ),
        ),

        // ── Navigation Indicators & Chevrons (Bottom) ──
        if (widget.showIndicators && widget.cards.length > 1) ...[
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left Arrow
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withValues(alpha: _currentPage > 0 ? 0.08 : 0.02)
                        : Colors.black.withValues(alpha: _currentPage > 0 ? 0.06 : 0.02),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 13,
                    color: _currentPage > 0
                        ? AppColors.textPrimary
                        : AppColors.textMuted.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Glowing Dots
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.cards.length, (index) {
                  final isSelected = _currentPage == index;
                  return GestureDetector(
                    onTap: () => _goToPage(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isSelected ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : AppColors.glassBorder,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 14),

              // Right Arrow
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _currentPage < widget.cards.length - 1
                    ? () => _goToPage(_currentPage + 1)
                    : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withValues(alpha: _currentPage < widget.cards.length - 1 ? 0.08 : 0.02)
                        : Colors.black.withValues(alpha: _currentPage < widget.cards.length - 1 ? 0.06 : 0.02),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: _currentPage < widget.cards.length - 1
                        ? AppColors.textPrimary
                        : AppColors.textMuted.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swipe_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Swipe to compare • ${_currentPage + 1} of ${widget.cards.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
