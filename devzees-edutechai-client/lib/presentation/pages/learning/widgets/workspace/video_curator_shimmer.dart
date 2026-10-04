import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/text_styles.dart';

/// Ultra-sleek neon shimmer skeleton rendered while the YouTubeCuratorAgent
/// fetches and indexes video transcripts in the background.
class VideoCuratorShimmer extends StatefulWidget {
  const VideoCuratorShimmer({super.key});

  @override
  State<VideoCuratorShimmer> createState() => _VideoCuratorShimmerState();
}

class _VideoCuratorShimmerState extends State<VideoCuratorShimmer>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.985, end: 1.018).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _scaleController]),
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Agent Status Header Banner (Modern Breathing Scale Effect) ──
              _buildCuratorStatusBanner(),
              const SizedBox(height: 20),

              // ── Shimmering Video Cards ──
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int count = 1;
                  if (width > 1200) {
                    count = 3;
                  } else if (width > 750) {
                    count = 2;
                  }

                  if (count == 1) {
                    return Column(
                      children: List.generate(
                        2,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildSkeletonCard(width),
                        ),
                      ),
                    );
                  }

                  const spacing = 16.0;
                  final cardWidth = ((width - (spacing * (count - 1))) / count).floorToDouble();

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: List.generate(
                      count,
                      (index) => SizedBox(
                        width: cardWidth,
                        child: _buildSkeletonCard(cardWidth),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCuratorStatusBanner() {
    final pulseProgress = _scaleController.value;
    final scale = _scaleAnimation.value;

    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2A1528).withValues(alpha: 0.88),
              const Color(0xFF1B1124).withValues(alpha: 0.92),
              const Color(0xFF2E172B).withValues(alpha: 0.88),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color.lerp(
              AppColors.accentRose.withValues(alpha: 0.35),
              AppColors.accentRose.withValues(alpha: 0.85),
              pulseProgress,
            )!,
            width: 1.4,
          ),
          boxShadow: [
            // Breathing Neon Halo (scales out and in dynamically)
            BoxShadow(
              color: AppColors.accentRose.withValues(alpha: 0.10 + 0.18 * pulseProgress),
              blurRadius: 18 + 14 * pulseProgress,
              spreadRadius: 1 + 3 * pulseProgress,
            ),
            // Ambient Violet Backdrop
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.08 + 0.08 * pulseProgress),
              blurRadius: 28 + 10 * pulseProgress,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pulsing Glow Dot with Animated Ripple Ring
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer expanding ripple ring
                Container(
                  width: 22 + (8 * pulseProgress),
                  height: 22 + (8 * pulseProgress),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accentRose.withValues(alpha: 0.4 * (1 - pulseProgress)),
                      width: 1.5,
                    ),
                  ),
                ),
                // Inner solid glow dot
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentRose,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentRose.withValues(alpha: 0.6 + 0.4 * pulseProgress),
                        blurRadius: 10 + 6 * pulseProgress,
                        spreadRadius: 2 + 2 * pulseProgress,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('🎬', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 7),
                      Text(
                        'YouTube Curator Agent',
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.roseLight,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.accentRose.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.accentRose.withValues(alpha: 0.45 + 0.35 * pulseProgress),
                            width: 0.9,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentRose.withValues(alpha: 0.15 * pulseProgress),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.radar_rounded,
                              size: 11,
                              color: AppColors.roseLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'INDEXING TRANSCRIPTS',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.roseLight,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Extracting educational video chapters & pinpointing exact milestone timestamps...',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSlate.withValues(alpha: 0.85),
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(double width) {
    final shimmerProgress = _shimmerController.value;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMid.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorderSubtle,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 16:9 Thumbnail skeleton with animated shimmer sweep
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E1A2E),
                          const Color(0xFF261F38),
                          const Color(0xFF1E1A2E),
                        ],
                      ),
                    ),
                  ),
                  // Animated Shimmer Beam
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment(-2.0 + (shimmerProgress * 4.0), 0),
                      widthFactor: 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.accentRose.withValues(alpha: 0.15),
                              AppColors.purpleLight.withValues(alpha: 0.20),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Center play watermark
                  Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.45),
                        border: Border.all(
                          color: AppColors.glassBorder,
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.textMuted.withValues(alpha: 0.4),
                        size: 26,
                      ),
                    ),
                  ),
                  // Bottom timestamp pill skeleton
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 11, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Container(
                            width: 32,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.textMuted.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content skeleton lines
          Padding(
            padding: const EdgeInsets.all(14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title line 1
                    _buildShimmerLine(width: contentWidth * 0.85, height: 14),
                    const SizedBox(height: 8),
                    // Title line 2
                    _buildShimmerLine(width: contentWidth * 0.55, height: 12),
                    const SizedBox(height: 12),
                    // Channel & Timestamp chips
                    Row(
                      children: [
                        _buildShimmerLine(width: contentWidth * 0.30, height: 10),
                        const Spacer(),
                        _buildShimmerLine(width: contentWidth * 0.25, height: 10),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.slate400.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
