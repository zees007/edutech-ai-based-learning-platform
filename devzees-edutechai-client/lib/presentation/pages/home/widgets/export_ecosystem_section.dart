import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class ExportEcosystemSection extends StatelessWidget {
  const ExportEcosystemSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                'ZERO VENDOR LOCK-IN',
                style: TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GradientText(
          'Engineered for Your Second Brain',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Text(
            'Your insights belong to you. Seamlessly export complete learning journeys—including Socratic notes, timestamped links, and Mermaid.js diagrams—into your digital garden.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              fontSize: isMobile ? 15 : 17,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 48),

        if (isMobile)
          Column(
            children: const [
              _ExportFormatCard(
                icon: '📝',
                title: 'Markdown (.md)',
                badge: 'Obsidian & Notion Ready',
                color: AppColors.accentPurple,
                description: 'Preserves raw Mermaid.js diagrams that render natively in Obsidian and GitHub, alongside structured session tables and quiz rationales.',
                tools: ['Obsidian', 'Notion', 'Logseq', 'Bear'],
              ),
              SizedBox(height: 16),
              _ExportFormatCard(
                icon: '🌐',
                title: 'Interactive HTML (.html)',
                badge: 'Zero-Dependency Web',
                color: AppColors.accentCyan,
                description: 'Standalone, offline-viewable web documents formatted with our custom dark glassmorphism styling. Perfect for sharing with study groups.',
                tools: ['Chrome', 'Safari', 'Firefox', 'AirDrop'],
              ),
              SizedBox(height: 16),
              _ExportFormatCard(
                icon: '📄',
                title: 'Executive PDF (.pdf)',
                badge: 'Ultra Exclusive',
                color: AppColors.accentAmber,
                description: 'Printable, professionally formatted study guides with executive typography, blue hierarchy headers, callouts, and comprehensive quiz answer keys.',
                tools: ['Print', 'iPad GoodNotes', 'Remarkable', 'Archive'],
              ),
            ],
          )
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Expanded(
                  child: _ExportFormatCard(
                    icon: '📝',
                    title: 'Markdown (.md)',
                    badge: 'Obsidian & Notion',
                    color: AppColors.accentPurple,
                    description: 'Preserves raw Mermaid.js diagrams that render natively in Obsidian and GitHub, alongside structured session tables and quiz rationales.',
                    tools: ['Obsidian', 'Notion', 'Logseq', 'Bear'],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _ExportFormatCard(
                    icon: '🌐',
                    title: 'Interactive HTML (.html)',
                    badge: 'Zero-Dependency Web',
                    color: AppColors.accentCyan,
                    description: 'Standalone, offline-viewable web documents formatted with our custom dark glassmorphism styling. Perfect for sharing with study groups.',
                    tools: ['Chrome', 'Safari', 'Firefox', 'AirDrop'],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _ExportFormatCard(
                    icon: '📄',
                    title: 'Executive PDF (.pdf)',
                    badge: 'Ultra Exclusive',
                    color: AppColors.accentAmber,
                    description: 'Printable, professionally formatted study guides with executive typography, blue hierarchy headers, callouts, and comprehensive quiz answer keys.',
                    tools: ['Print', 'iPad GoodNotes', 'Remarkable', 'Archive'],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ExportFormatCard extends StatelessWidget {
  final String icon;
  final String title;
  final String badge;
  final Color color;
  final String description;
  final List<String> tools;

  const _ExportFormatCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.color,
    required this.description,
    required this.tools,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 10),
          Text(
            description,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSlate, height: 1.5),
          ),
          const Spacer(),
          const SizedBox(height: 20),
          Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: tools.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  t,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
