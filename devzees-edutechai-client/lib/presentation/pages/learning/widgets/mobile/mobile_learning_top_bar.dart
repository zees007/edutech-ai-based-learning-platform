import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_response.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/presentation/widgets/theme_toggle_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/step_pill.dart';

/// A high-density, ultra-sleek Mobile Top Bar.
/// Features the official EduTechAI logo immediately following the hamburger icon
/// on the left side, with the active learning HUD and gamification badges on the right.
class MobileLearningTopBar extends StatelessWidget implements PreferredSizeWidget {
  final SessionResponse? session;
  final int activeStepIndex;
  final VoidCallback? onOpenCommandHub;

  const MobileLearningTopBar({
    super.key,
    required this.session,
    this.activeStepIndex = 0,
    this.onOpenCommandHub,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final hasSession = session != null;

    return AppBar(
      backgroundColor: AppColors.topBarBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: SizedBox(
        height: kToolbarHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Left: Hamburger Menu Icon + App Logo
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(
                      builder: (ctx) => IconButton(
                        icon: Icon(
                          Icons.menu_rounded,
                          color: AppColors.textSecondary,
                          size: 21,
                        ),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                        tooltip: 'Open menu',
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                    const SizedBox(width: 2),
                    _buildAppLogo(isCompact: hasSession),
                  ],
                ),
              ),
            ),

            // 2. Center: Unified Command Hub Capsule (Only when session is active)
            if (hasSession)
              Positioned.fill(
                child: Center(
                  child: _buildUnifiedCommandHubCapsule(context),
                ),
              ),

            // 3. Right: Theme Toggle Button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: const ThemeToggleButton(size: 30),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppColors.glassBorder,
          height: 1.0,
        ),
      ),
    );
  }

  // ─── OFFICIAL APP LOGO (⚡ EduTech [AI]) ────────────────────────────────────
  Widget _buildAppLogo({bool isCompact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '⚡ ',
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: isCompact ? 14 : 16,
          ),
        ),
        GradientText(
          'EduTech',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            fontSize: isCompact ? 14 : 16,
          ),
        ),
        const SizedBox(width: 3),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 3.5 : 5,
            vertical: isCompact ? 1.0 : 1.5,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(isCompact ? 4.5 : 6),
          ),
          child: Text(
            'AI',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: isCompact ? 8.5 : 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ─── UNIFIED COMMAND HUB CAPSULE (Interactive Pill in Center) ──────────────
  Widget _buildUnifiedCommandHubCapsule(BuildContext context) {
    final s = session!;
    final totalSteps = s.steps.isNotEmpty ? s.steps.length : 1;
    final currentStepNum = (activeStepIndex + 1).clamp(1, totalSteps);

    return Tooltip(
      message: 'Milestone Roadmap & Progress',
      child: GestureDetector(
        onTap: onOpenCommandHub,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          decoration: BoxDecoration(
            color: AppColors.sidebarBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Goal / Track icon
              Icon(
                Icons.track_changes_rounded,
                size: 13,
                color: AppColors.adaptiveBlueLight,
              ),
              const SizedBox(width: 4.5),

              // 2. Standardized Glowing Green Step Pill (e.g. 2/5)
              StepPill(
                currentStep: currentStepNum,
                totalSteps: totalSteps,
                isCompact: true,
              ),
              const SizedBox(width: 6),

              // 3. Elegant vertical hairline separator
              Container(
                width: 1.0,
                height: 10,
                color: AppColors.isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.12),
              ),
              const SizedBox(width: 6),

              // 4. XP Counter
              const Icon(
                Icons.star_rounded,
                size: 13,
                color: AppColors.accentAmber,
              ),
              const SizedBox(width: 2.5),
              Text(
                '${s.xpEarned}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentAmber,
                ),
              ),
              const SizedBox(width: 3),

              // 5. Down Chevron Indicator
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 13,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
