import 'package:flutter/material.dart';
import '../../core/constants/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_palette.dart';
import '../pages/admin/widgets/admin_loading_skeleton.dart';
import '../pages/dashboard/widgets/dashboard_loading_skeleton.dart';
import 'shimmer_loading.dart';

/// Identifies which route shell [ShimmerAppShell] mirrors during auth rehydration (`F5`).
enum ShimmerShellVariant {
  learning,
  dashboard,
  admin,
  subscription,
}

/// Route-aware, theme-adaptive skeleton shell shown during initial session
/// rehydration (`authState.isInitial`) on cold start or browser refresh (`F5`).
///
/// [ShimmerLoading] is scoped strictly to placeholder bone groups inside each
/// surface so card/sidebar/top-bar backgrounds, borders, and shadows stay crisp
/// in both Light and Dark themes.
class ShimmerAppShell extends StatelessWidget {
  final ShimmerShellVariant variant;

  const ShimmerAppShell({
    super.key,
    this.variant = ShimmerShellVariant.learning,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: SafeArea(
        child: switch (variant) {
          ShimmerShellVariant.subscription =>
            _buildSubscriptionSkeleton(context, isMobile),
          ShimmerShellVariant.admin => isMobile
              ? _buildMobileShell(context, isAdmin: true)
              : _buildAdminDesktopSkeleton(context),
          ShimmerShellVariant.dashboard => isMobile
              ? _buildMobileShell(context, isDashboard: true)
              : _buildLearningDesktopSkeleton(context, isDashboard: true),
          ShimmerShellVariant.learning => isMobile
              ? _buildMobileShell(context)
              : _buildLearningDesktopSkeleton(context),
        },
      ),
    );
  }

  // ─── Learning & Dashboard Desktop Skeleton ────────────────────────────

  Widget _buildLearningDesktopSkeleton(
    BuildContext context, {
    bool isDashboard = false,
  }) {
    final colors = context.appColors;
    return Row(
      children: [
        _buildSidebarSkeleton(
          context,
          width: 280,
          itemCount: 4,
          showPrimaryAction: true,
        ),
        Expanded(
          child: Column(
            children: [
              // Top Bar Skeleton
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: colors.topBarBackground,
                  border: Border(
                    bottom: BorderSide(color: colors.border, width: 1),
                  ),
                ),
                child: ShimmerLoading(
                  child: Row(
                    children: [
                      const ShimmerBox(
                        width: 110,
                        height: 28,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      const SizedBox(width: 8),
                      const ShimmerBox(
                        width: 130,
                        height: 28,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      const Spacer(),
                      const ShimmerBox(
                        width: 86,
                        height: 28,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      const SizedBox(width: 8),
                      const ShimmerBox(
                        width: 96,
                        height: 28,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      const SizedBox(width: 12),
                      const ShimmerBox(
                        width: 30,
                        height: 30,
                        shape: BoxShape.circle,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: isDashboard
                    ? const SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(24),
                        child: DashboardLoadingSkeleton(),
                      )
                    : _buildLearningWorkspaceSkeleton(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLearningWorkspaceSkeleton(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepperSkeleton(context),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return _buildActiveLessonCardSkeleton(context);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 55,
                    child: _buildActiveLessonCardSkeleton(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 45,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.border),
                        boxShadow: isDark ? null : colors.cardShadow,
                      ),
                      child: ShimmerLoading(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                ShimmerBox(width: 84, height: 28),
                                SizedBox(width: 8),
                                ShimmerBox(width: 84, height: 28),
                                SizedBox(width: 8),
                                ShimmerBox(width: 72, height: 28),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const ShimmerBox(
                              width: double.infinity,
                              height: 150,
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                            ),
                            const SizedBox(height: 16),
                            const ShimmerBox(width: 200, height: 14),
                            const SizedBox(height: 8),
                            const ShimmerBox(width: 140, height: 12),
                            const SizedBox(height: 20),
                            const ShimmerBox(
                              width: double.infinity,
                              height: 110,
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Admin Console Desktop Skeleton ───────────────────────────────────

  Widget _buildAdminDesktopSkeleton(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        _buildSidebarSkeleton(
          context,
          width: 260,
          itemCount: 6,
          showPrimaryAction: false,
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: colors.topBarBackground,
                  border: Border(
                    bottom: BorderSide(color: colors.border, width: 1),
                  ),
                ),
                child: ShimmerLoading(
                  child: Row(
                    children: const [
                      ShimmerBox(width: 28, height: 28),
                      SizedBox(width: 12),
                      ShimmerBox(width: 210, height: 18),
                      Spacer(),
                      ShimmerBox(width: 110, height: 14),
                      SizedBox(width: 16),
                      ShimmerBox(width: 30, height: 30, shape: BoxShape.circle),
                    ],
                  ),
                ),
              ),
              const Expanded(
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(24),
                  child: AdminTableSkeleton(
                    showMetricsRow: true,
                    showSearchBar: true,
                    rowCount: 6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Subscription Page Refresh Skeleton ───────────────────────────────

  Widget _buildSubscriptionSkeleton(BuildContext context, bool isMobile) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;

    return Column(
      children: [
        Container(
          height: 64,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
          decoration: BoxDecoration(
            color: colors.topBarBackground,
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: ShimmerLoading(
            child: Row(
              children: const [
                ShimmerBox(width: 32, height: 32, shape: BoxShape.circle),
                SizedBox(width: 12),
                ShimmerBox(width: 150, height: 18),
                Spacer(),
                ShimmerBox(
                  width: 92,
                  height: 28,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: 28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Column(
                  children: [
                    ShimmerLoading(
                      child: Column(
                        children: [
                          ShimmerBox(
                            width: isMobile ? 220 : 320,
                            height: 28,
                          ),
                          const SizedBox(height: 12),
                          ShimmerBox(
                            width: isMobile ? 260 : 420,
                            height: 14,
                          ),
                          const SizedBox(height: 24),
                          const ShimmerBox(
                            width: 220,
                            height: 40,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (isMobile)
                      _buildPlanCardSkeleton(context, isDark)
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildPlanCardSkeleton(context, isDark)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildPlanCardSkeleton(context, isDark)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildPlanCardSkeleton(context, isDark)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCardSkeleton(BuildContext context, bool isDark) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: isDark ? null : colors.cardShadow,
      ),
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ShimmerBox(width: 90, height: 18),
            SizedBox(height: 14),
            ShimmerBox(width: 130, height: 32),
            SizedBox(height: 20),
            ShimmerBox(width: double.infinity, height: 12),
            SizedBox(height: 10),
            ShimmerBox(width: 180, height: 12),
            SizedBox(height: 10),
            ShimmerBox(width: 160, height: 12),
            SizedBox(height: 10),
            ShimmerBox(width: 190, height: 12),
            SizedBox(height: 24),
            ShimmerBox(
              width: double.infinity,
              height: 44,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Mobile Shell Skeleton ────────────────────────────────────────────

  Widget _buildMobileShell(
    BuildContext context, {
    bool isDashboard = false,
    bool isAdmin = false,
  }) {
    final colors = context.appColors;
    return Column(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.topBarBackground,
            border: Border(bottom: BorderSide(color: colors.border, width: 1)),
          ),
          child: ShimmerLoading(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(
                  width: 28,
                  height: 28,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                ShimmerBox(width: 120, height: 18),
                ShimmerBox(width: 32, height: 32, shape: BoxShape.circle),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: isDashboard
                ? const DashboardLoadingSkeleton()
                : isAdmin
                    ? const AdminTableSkeleton(showMetricsRow: true, rowCount: 4)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLoading(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                4,
                                (_) => const ShimmerBox(
                                  width: 24,
                                  height: 24,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildActiveLessonCardSkeleton(context),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  // ─── Shared Shell Components ──────────────────────────────────────────

  Widget _buildSidebarSkeleton(
    BuildContext context, {
    required double width,
    required int itemCount,
    required bool showPrimaryAction,
  }) {
    final colors = context.appColors;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colors.sidebarBackground,
        border: Border(right: BorderSide(color: colors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(
            child: Row(
              children: const [
                ShimmerBox(
                  width: 36,
                  height: 36,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 110, height: 15),
                    SizedBox(height: 6),
                    ShimmerBox(width: 72, height: 10),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (showPrimaryAction) ...[
            const ShimmerLoading(
              child: ShimmerBox(
                width: double.infinity,
                height: 44,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
          ],
          const ShimmerLoading(child: ShimmerBox(width: 100, height: 12)),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: ShimmerLoading(
                  child: Row(
                    children: [
                      const ShimmerBox(
                        width: 28,
                        height: 28,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(
                              width: index.isEven ? 124 : 96,
                              height: 12,
                            ),
                            if (showPrimaryAction) ...[
                              const SizedBox(height: 6),
                              const ShimmerBox(width: 68, height: 10),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: ShimmerLoading(
              child: Row(
                children: const [
                  ShimmerBox(width: 34, height: 34, shape: BoxShape.circle),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 88, height: 12),
                        SizedBox(height: 6),
                        ShimmerBox(width: 58, height: 10),
                      ],
                    ),
                  ),
                  ShimmerBox(width: 18, height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperSkeleton(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: isDark ? null : colors.cardShadow,
      ),
      child: ShimmerLoading(
        child: Row(
          children: [
            for (int i = 0; i < 4; i++) ...[
              Row(
                children: [
                  const ShimmerBox(width: 30, height: 30, shape: BoxShape.circle),
                  const SizedBox(width: 10),
                  ShimmerBox(width: i == 0 ? 86 : 68, height: 12),
                ],
              ),
              if (i < 3)
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: ShimmerBox(width: double.infinity, height: 2),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveLessonCardSkeleton(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : colors.cardShadow,
      ),
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 18),
            const ShimmerBox(width: 280, height: 24),
            const SizedBox(height: 20),
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
            const SizedBox(height: 24),
            Container(
              height: 132,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 120, height: 12),
                  SizedBox(height: 12),
                  ShimmerBox(width: 220, height: 12),
                  SizedBox(height: 8),
                  ShimmerBox(width: 170, height: 12),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(
                  width: 130,
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                ShimmerBox(
                  width: 150,
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
