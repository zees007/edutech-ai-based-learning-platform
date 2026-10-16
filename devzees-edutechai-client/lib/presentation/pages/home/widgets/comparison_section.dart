import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class ComparisonSection extends StatelessWidget {
  const ComparisonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    final comparisonItems = [
      _ComparisonItem(
        dimension: 'Teaching Methodology',
        generic: 'Dumps long walls of direct text; fosters passive reading and prompt-copying.',
        edutech: 'Socratic guided questioning, progressive anchor analogies, and embedded concept flowcharts.',
      ),
      _ComparisonItem(
        dimension: 'Curricular Structure',
        generic: 'Fragmented single-turn answers with no milestone roadmap or progress tracking.',
        edutech: 'Supervisor Orchestrator plans 4–7 progressive milestone steps + auto prerequisite warmups.',
      ),
      _ComparisonItem(
        dimension: 'Video Deep-Linking',
        generic: 'Cannot play videos; frequently fabricates broken or irrelevant URLs.',
        edutech: 'Semantic vector search across YouTube transcripts; pinpoints the exact timestamp clip.',
      ),
      _ComparisonItem(
        dimension: 'Scholarly Verification',
        generic: 'Relies on static training data; often fabricates papers and citations.',
        edutech: 'Live parallel search across 250M+ peer-reviewed works (arXiv, OpenAlex, Semantic Scholar).',
      ),
      _ComparisonItem(
        dimension: 'Comprehension Testing',
        generic: 'Zero verification of whether you truly understood the material.',
        edutech: 'Contextual formative quizzes derived strictly from the lesson with instant XP grading.',
      ),
      _ComparisonItem(
        dimension: 'Second Brain Export',
        generic: 'Manual copy-pasting into notes without diagram preservation.',
        edutech: 'One-click export to Markdown (Obsidian/Notion ready with Mermaid), HTML & styled PDF.',
      ),
    ];

    return Column(
      children: [
        // Section Header Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE879F9).withValues(alpha: 0.14),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE879F9),
                  boxShadow: [
                    BoxShadow(color: Color(0xFFE879F9), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'THE ARCHITECTURAL ADVANTAGE',
                style: TextStyle(
                  color: Color(0xFFD4D8E8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GradientText(
          'Beyond Generic AI Chatbots',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Text(
            'Generic conversational bots are designed to give answers and end conversations. EduTech AI is engineered as an autonomous teaching squad designed to build long-term cognitive retention.',
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
            children: comparisonItems.map((item) => _buildMobileComparisonCard(item)).toList(),
          )
        else
          GlassCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Table Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'LEARNING DIMENSION',
                          style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('💬 Standard Chatbots (ChatGPT)', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('⚡ EduTech AI Multi-Agent Squad', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColors.border.withValues(alpha: 0.6)),

                // Table Rows
                ...comparisonItems.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.3))),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.dimension,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('❌ ', style: TextStyle(fontSize: 12)),
                                Expanded(
                                  child: Text(
                                    item.generic,
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('✅ ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  item.edutech,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMobileComparisonCard(_ComparisonItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.dimension,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Standard Chatbots (ChatGPT):', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    item.generic,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚡ EduTech AI Multi-Agent Squad:', style: TextStyle(color: AppColors.adaptiveLavender, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    item.edutech,
                    style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonItem {
  final String dimension;
  final String generic;
  final String edutech;

  const _ComparisonItem({
    required this.dimension,
    required this.generic,
    required this.edutech,
  });
}
