import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';

class AuthIntroHeader extends StatelessWidget {
  final bool isMobile;
  final bool showInstructions;

  const AuthIntroHeader({
    super.key,
    required this.isMobile,
    this.showInstructions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            "EduTech AI is an autonomous, multi-agent academic ecosystem. Log in or create a new student account to instantiate your personal supervisor-worker agent swarm.",
            style: AppTextStyles.bodyPrimary.copyWith(
              fontSize: isMobile ? 14 : 15,
              color: AppColors.isDark ? Colors.white : const Color(0xFF475569),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (showInstructions) ...[
          const SizedBox(height: 20),
          AuthInstructionsCard(isMobile: isMobile),
        ],
      ],
    );
  }
}

class AuthInstructionsCard extends StatelessWidget {
  final bool isMobile;

  const AuthInstructionsCard({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 860),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 14 : 16,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.accentBlue.withValues(alpha: 0.1)
            : const Color(0xFFEEF2FF).withValues(alpha: 0.75),
        border: Border.all(
          color: isDark
              ? AppColors.accentBlue.withValues(alpha: 0.3)
              : const Color(0xFFE0E7FF),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("💡", style: TextStyle(fontSize: 20, height: 1.2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(
                  "Access Instructions",
                  gradient: AppColors.primaryGradient,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Trace the Providing Access Flowchart below. If you already have an account, complete the Sign In form on the right. Otherwise, proceed to the Create Account tab. Upon verification, the system dispatches the AI Agent Squad to instantly grant workspace access.",
                  style: AppTextStyles.caption.copyWith(
                    fontSize: isMobile ? 12 : 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : const Color(0xFF1E1B4B),
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
