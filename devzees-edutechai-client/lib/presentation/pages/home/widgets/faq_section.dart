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
      'category': 'ARCHITECTURE',
      'question': 'How does EduTech AI differ from conversational LLMs like ChatGPT or Claude?',
      'answer':
          'Standard chatbots generate long, unstructured text dumps that encourage passive skimming and low retention. EduTech AI orchestrates six autonomous agents around a central blackboard state: breaking topics into 4–7 milestones, teaching through Socratic guided inquiry, verifying timestamped video clips via vector embeddings, curating live academic papers from arXiv/OpenAlex, and evaluating your comprehension with grounded quizzes.',
    },
    {
      'category': 'ACCURACY & GROUNDING',
      'question': 'How do you prevent AI hallucinations in lessons and quizzes?',
      'answer':
          'We implement strict grounding constraints. The Quiz Agent is explicitly restricted to context derived from the active Socratic lesson. The YouTube Curator verifies video content using transcript chunk semantic search in ChromaDB. Academic papers are resolved against verified live APIs (OpenAlex, Semantic Scholar, arXiv) with real DOIs and direct full-text PDF links.',
    },
    {
      'category': 'MODELS & LATENCY',
      'question': 'What neural models power the autonomous agents?',
      'answer':
          'EduTech AI utilizes a multi-model routing pipeline powered by state-of-the-art LLMs (including Meta Llama 3.1 and Google Gemini). Each agent is calibrated with task-specific temperatures: low temperature (0.3) for deterministic milestone planning in the Orchestrator, and balanced temperature (0.7) for engaging analogies in the Socratic Tutor.',
    },
    {
      'category': 'BILLING & ACCESS',
      'question': 'Can I cancel, upgrade, or downgrade my plan anytime?',
      'answer':
          'Yes, absolutely. You can upgrade, downgrade, or cancel your subscription at any time with a single click in your profile settings. When you cancel, you keep full access to your plan until the end of your billing cycle and retain permanent ownership of all exported study notes.',
    },
    {
      'category': 'SECOND BRAIN',
      'question': 'How do session exports work with Obsidian and Notion?',
      'answer':
          'Pro and Ultra subscribers can export their entire learning session with one click. Markdown (.md) exports include session metadata tables, Socratic dialogues, video links, quiz results, and raw Mermaid.js diagrams that render natively inside Obsidian, Notion, Logseq, and GitHub.',
    },
    {
      'category': 'PERSISTENCE',
      'question': 'Is my learning history, XP, and progress saved?',
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
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.16),
                blurRadius: 18,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF8B5CF6),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF8B5CF6), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: TextStyle(
                  color: Color(0xFFDDD6FE),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
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
            'Everything you need to know about our multi-agent architecture, grounding safety, subscription tiers, and study exports.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: isMobile ? 15 : 17,
              height: 1.6,
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
              final String indexNumber = (index + 1).toString().padLeft(2, '0');

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: isExpanded ? const Color(0xFF0F132C) : const Color(0xDD0A0D1D),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isExpanded
                          ? const Color(0xFF3B82F6).withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.08),
                      width: 1.2,
                    ),
                    boxShadow: isExpanded
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.16),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 14,
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
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
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 18 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Number & Category Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isExpanded
                                        ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    indexNumber,
                                    style: TextStyle(
                                      color: isExpanded ? const Color(0xFF60A5FA) : const Color(0xFF94A3B8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Question Title
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        faq['category']!,
                                        style: TextStyle(
                                          color: isExpanded
                                              ? const Color(0xFF60A5FA)
                                              : const Color(0xFF64748B),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        faq['question']!,
                                        style: TextStyle(
                                          color: const Color(0xFFF1F5F9),
                                          fontSize: isMobile ? 14.5 : 16,
                                          fontWeight: FontWeight.w700,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Animated Chevron
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isExpanded
                                        ? const Color(0xFF3B82F6).withValues(alpha: 0.20)
                                        : Colors.white.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: AnimatedRotation(
                                    duration: const Duration(milliseconds: 220),
                                    turns: isExpanded ? 0.5 : 0.0,
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: isExpanded
                                          ? const Color(0xFF60A5FA)
                                          : const Color(0xFF94A3B8),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isExpanded) ...[
                              const SizedBox(height: 16),
                              Divider(color: Colors.white.withValues(alpha: 0.08)),
                              const SizedBox(height: 14),
                              Padding(
                                padding: const EdgeInsets.only(left: 42),
                                child: Text(
                                  faq['answer']!,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 14,
                                    height: 1.65,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
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
