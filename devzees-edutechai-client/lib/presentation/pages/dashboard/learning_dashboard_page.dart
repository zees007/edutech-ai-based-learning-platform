import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_palette.dart';
import '../../widgets/glow_background.dart';
import '../../widgets/theme_toggle_button.dart';
import 'widgets/learning_dashboard_view.dart';

/// Standalone dashboard page kept for backward compatibility.
///
/// In the current architecture, users reach the dashboard via
/// `/learning/dashboard` inside the [StatefulShellRoute] shell. This page
/// is only hit if someone navigates to the legacy `/dashboard` path before
/// the redirect fires, or if the widget is referenced directly in tests.
class LearningDashboardPage extends ConsumerWidget {
  const LearningDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasBackground : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.canvasBackground.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/learning');
            }
          },
          tooltip: 'Back to Learning Workspace',
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 28,
              height: 28,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.school_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'EduTechAI',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 12),
        ],
      ),
      body: const GlowBackground(
        child: LearningDashboardView(),
      ),
    );
  }
}
