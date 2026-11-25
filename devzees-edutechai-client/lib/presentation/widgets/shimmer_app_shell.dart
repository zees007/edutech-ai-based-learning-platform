import 'package:flutter/material.dart';
import '../../core/constants/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_palette.dart';
import 'glow_background.dart';
import 'shimmer_loading.dart';

/// A production-grade shimmer skeleton screen that mirrors the application's
/// authenticated workspace layout (Sidebar + Header + Stepper + Lesson Canvas).
///
/// Displayed during the initial session rehydration phase on cold start or
/// browser refresh (F5) so the user experiences zero UI flash and no layout shifts.
class ShimmerAppShell extends StatelessWidget {
  const ShimmerAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: GlowBackground(
        child: ShimmerLoading(
          child: SafeArea(
            child: isMobile ? _buildMobileSkeleton(context) : _buildDesktopSkeleton(context),
          ),
        ),
      ),
    );
  }

  // ─── Desktop / Tablet Layout ──────────────────────────────────────────

  Widget _buildDesktopSkeleton(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;
    final glassBase = isDark ? const Color(0x0DFFFFFF) : const Color(0x0A000000);
    final glassBorderSubtle = isDark ? const Color(0x0DFFFFFF) : const Color(0x0F000000);
    return Row(
      children: [
        // Left Sidebar Skeleton
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: colors.sidebarBackground.withValues(alpha: 0.95),
            border: Border(
              right: BorderSide(
                color: colors.border,
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand Header
              Row(
                children: [
                  const ShimmerBox(
                    width: 38,
                    height: 38,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 110, height: 16),
                      SizedBox(height: 6),
                      ShimmerBox(width: 70, height: 10),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // "+ New Journey" Action Button Skeleton
              ShimmerBox(
                width: double.infinity,
                height: 44,
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 32),

              // Section Label: Recent Journeys
              const ShimmerBox(width: 100, height: 12),
              const SizedBox(height: 16),

              // Session History List Skeletons
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: glassBase,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: glassBorderSubtle),
                    ),
                    child: Row(
                      children: [
                        const ShimmerBox(
                          width: 32,
                          height: 32,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(
                                width: index.isEven ? 130 : 100,
                                height: 13,
                              ),
                              const SizedBox(height: 6),
                              const ShimmerBox(width: 70, height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // User Profile Footer Skeleton
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: glassBase,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    const ShimmerBox(
                      width: 36,
                      height: 36,
                      shape: BoxShape.circle,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerBox(width: 90, height: 12),
                          SizedBox(height: 6),
                          ShimmerBox(width: 60, height: 10),
                        ],
                      ),
                    ),
                    const ShimmerBox(
                      width: 18,
                      height: 18,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Main Learning Canvas Skeleton
        Expanded(
          child: Column(
            children: [
              // Top Bar Skeleton
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: colors.topBarBackground.withValues(alpha: 0.6),
                  border: Border(
                    bottom: BorderSide(color: colors.border, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const ShimmerBox(width: 220, height: 18),
                    const Spacer(),
                    // Gamification badges skeleton
                    const ShimmerBox(
                      width: 90,
                      height: 30,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    const SizedBox(width: 12),
                    const ShimmerBox(
                      width: 80,
                      height: 30,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    const SizedBox(width: 12),
                    const ShimmerBox(
                      width: 36,
                      height: 36,
                      shape: BoxShape.circle,
                    ),
                  ],
                ),
              ),

              // Stepper & Lesson Workspace Area
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Milestone Stepper Row Skeleton
                          _buildStepperSkeleton(context),
                          const SizedBox(height: 32),

                          // Main Active Step Card Skeleton
                          _buildActiveLessonCardSkeleton(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Mobile Layout ────────────────────────────────────────────────────

  Widget _buildMobileSkeleton(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        // Mobile App Bar Skeleton
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.topBarBackground,
            border: Border(
              bottom: BorderSide(color: colors.border, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(
                width: 28,
                height: 28,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              ShimmerBox(width: 120, height: 18),
              ShimmerBox(
                width: 32,
                height: 32,
                shape: BoxShape.circle,
              ),
            ],
          ),
        ),

        // Mobile Content Body Skeleton
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stepper dots skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (i) => const ShimmerBox(
                      width: 24,
                      height: 24,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Card skeleton
                Expanded(
                  child: _buildActiveLessonCardSkeleton(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Shared Components ────────────────────────────────────────────────

  Widget _buildStepperSkeleton(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;
    final glassBase = isDark ? const Color(0x0DFFFFFF) : const Color(0x0A000000);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: glassBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          for (int i = 0; i < 4; i++) ...[
            Row(
              children: [
                ShimmerBox(
                  width: 32,
                  height: 32,
                  shape: BoxShape.circle,
                  color: i == 0
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : (isDark ? colors.chipBackground : const Color(0xFFEDE9F2)),
                ),
                const SizedBox(width: 10),
                ShimmerBox(width: i == 0 ? 90 : 70, height: 12),
              ],
            ),
            if (i < 3)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 2,
                    color: colors.border,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveLessonCardSkeleton(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? const Color(0x73A855F7) : colors.border).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step pill + Tutor tag
          Row(
            children: const [
              ShimmerBox(
                width: 80,
                height: 24,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              SizedBox(width: 12),
              ShimmerBox(
                width: 140,
                height: 24,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Step Title
          const ShimmerBox(width: 340, height: 26),
          const SizedBox(height: 24),

          // Explanation body lines
          const ShimmerBox(width: double.infinity, height: 14),
          const SizedBox(height: 10),
          const ShimmerBox(width: double.infinity, height: 14),
          const SizedBox(height: 10),
          const FractionallySizedBox(
            widthFactor: 0.85,
            child: ShimmerBox(width: double.infinity, height: 14),
          ),
          const SizedBox(height: 10),
          const FractionallySizedBox(
            widthFactor: 0.6,
            child: ShimmerBox(width: double.infinity, height: 14),
          ),
          const SizedBox(height: 32),

          // Code / Diagram container placeholder
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.scaffoldBackground.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 120, height: 12),
                SizedBox(height: 12),
                ShimmerBox(width: 260, height: 12),
                SizedBox(height: 8),
                ShimmerBox(width: 180, height: 12),
                SizedBox(height: 8),
                ShimmerBox(width: 220, height: 12),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(
                width: 140,
                height: 42,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              ShimmerBox(
                width: 160,
                height: 42,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
