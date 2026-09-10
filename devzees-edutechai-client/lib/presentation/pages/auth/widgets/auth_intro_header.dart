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
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              "Access the ",
              style: AppTextStyles.h1.copyWith(
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.pinkPurpleGradient.createShader(bounds),
              child: Text(
                "AI Learning Workspace",
                style: AppTextStyles.h1.copyWith(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Text(
            "EduTech AI is an autonomous, multi-agent academic ecosystem. Log in or create a new student account to instantiate your personal supervisor-worker agent swarm.",
            style: AppTextStyles.bodyPrimary.copyWith(
              fontSize: isMobile ? 16 : 18,
              color: AppColors.lavender.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (showInstructions) ...[
          const SizedBox(height: 32),
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("💡", style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              GradientText(
                "Access Instructions",
                style: AppTextStyles.subtitle1.copyWith(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Trace the Providing Access Flowchart below. If you already have an account, complete the Sign In form on the right. Otherwise, proceed to the Create Account tab. Upon verification, the system dispatches the AI Agent Squad to instantly grant workspace access.",
            style: AppTextStyles.caption.copyWith(
              fontSize: isMobile ? 12 : 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
