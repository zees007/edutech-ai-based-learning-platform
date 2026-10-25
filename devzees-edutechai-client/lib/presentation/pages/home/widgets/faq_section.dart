import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  final Set<int> _expandedIndices = {0}; // First question open by default

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How is EduTech AI different from ChatGPT or Claude?',
      'answer':
          'Standard chatbots generate long, unstructured text dumps that encourage passive skimming and low retention. EduTech AI orchestrates six autonomous agents around a central blackboard state: breaking topics into 4–7 milestones, teaching through Socratic guided inquiry, verifying timestamped video clips via vector embeddings, curating live academic papers from arXiv/OpenAlex, and evaluating your comprehension with grounded quizzes.',
    },
    {
      'question': 'How do you prevent AI hallucinations in lessons and quizzes?',
      'answer':
          'We implement strict grounding constraints. The Quiz Agent is explicitly restricted to context derived from the active Socratic lesson. The YouTube Curator verifies video content using transcript chunk semantic search in ChromaDB. Academic papers are resolved against verified live APIs (OpenAlex, Semantic Scholar, arXiv) with real DOIs and direct full-text PDF links.',
    },
    {
      'question': 'What AI models power the agents?',
      'answer':
          'EduTech AI utilizes a multi-model routing pipeline powered by state-of-the-art LLMs (including Meta Llama 3.1 and Google Gemini). Each agent is calibrated with task-specific temperatures: low temperature (0.3) for deterministic milestone planning in the Orchestrator, and balanced temperature (0.7) for engaging analogies in the Socratic Tutor.',
    },
    {
      'question': 'Can I cancel or change my plan anytime?',
      'answer':
          'Yes, absolutely. You can upgrade, downgrade, or cancel your subscription at any time with a single click in your profile settings. When you cancel, you keep full access to your plan until the end of your billing cycle and retain permanent ownership of all exported study notes.',
    },
    {
      'question': 'How do session exports work with Obsidian and Notion?',
      'answer':
          'Pro and Ultra subscribers can export their entire learning session with one click. Markdown (.md) exports include session metadata tables, Socratic dialogues, video links, quiz results, and raw Mermaid.js diagrams that render natively inside Obsidian, Notion, Logseq, and GitHub.',
    },
    {
      'question': 'Is my learning history and progress saved?',
      'answer':
          'Yes. Every session, milestone step, quiz score, streak, and XP reward is automatically persisted to PostgreSQL. If you leave or switch devices, you can resume your exact learning journey right where you left off from your session history.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

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
                color: const Color(0xFF9061F9).withValues(alpha: 0.14),
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
                  color: Color(0xFF9061F9),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF9061F9), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'FREQUENTLY ASKED QUESTIONS',
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
          'Got Questions? We Have Answers',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'Everything you need to know about our multi-agent architecture, subscription tiers, and study exports.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              fontSize: isMobile ? 15 : 17,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 48),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            children: List.generate(_faqs.length, (index) {
              final faq = _faqs[index];
              final isExpanded = _expandedIndices.contains(index);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedIndices.remove(index);
                        } else {
                          _expandedIndices.add(index);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 18 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  faq['question']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 15 : 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              AnimatedRotation(
                                duration: const Duration(milliseconds: 250),
                                turns: isExpanded ? 0.5 : 0.0,
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: isExpanded ? AppColors.primary : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 14),
                            Divider(color: AppColors.border.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text(
                              faq['answer']!,
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.textSlate,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
