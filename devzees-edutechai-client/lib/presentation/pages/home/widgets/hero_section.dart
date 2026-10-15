import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:go_router/go_router.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback? onExploreTap;

  const HeroSection({super.key, this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Top Architecture Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                'AUTONOMOUS MULTI-AGENT BLACKBOARD ARCHITECTURE',
                style: TextStyle(
                  color: AppColors.adaptiveLavender,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Headline
        Text(
          'Master Any Subject with a',
          textAlign: TextAlign.center,
          style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
            height: 1.1,
          ),
        ),
        GradientText(
          'Team of AI Agents',
          style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Text(
            'Our supervisor agent decomposes complex topics into adaptive milestones, while specialized workers collaborate in real-time to deliver Socratic dialogue, timestamped video clips, academic preprints, and grounded quizzes.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              fontSize: isMobile ? 15 : 18,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Action Buttons (Dual CTA)
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            GradientButton(
              text: 'Start Learning for Free →',
              width: isMobile ? 260 : 260,
              onPressed: () {
                context.go('/auth');
              },
            ),
            if (onExploreTap != null)
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onExploreTap,
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                  label: const Text('Explore Workspace Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.6)),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),

        // Trust Indicators
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: const [
            Text('✓ 10 Free Sessions / Month', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
            Text('•', style: TextStyle(color: Colors.white24)),
            Text('✓ No Credit Card Required', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
            Text('•', style: TextStyle(color: Colors.white24)),
            Text('✓ Export to Obsidian & Notion', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
