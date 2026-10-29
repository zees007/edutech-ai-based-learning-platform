import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

/// Ultra-premium Bento-Grid Features Section for EduTech AI.
///
/// Features:
/// - Asymmetric high-impact Bento Grid layout.
/// - Crisp vector iconography with double-layered neon glowing backplates (no emojis).
/// - Frosted glass containers with 1px border highlight and ambient hover states.
/// - Live telemetry pills, code/formula previews, and XP reward micro-badges.
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ─── Section Header Badge ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xCC090B18),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: const Color(0xFF2B68F6).withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B68F6).withValues(alpha: 0.20),
                blurRadius: 18,
                spreadRadius: -2,
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
                  color: Color(0xFF2B68F6),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF2B68F6), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'ENTERPRISE ARCHITECTURAL ADVANTAGES',
                style: TextStyle(
                  color: Color(0xFFD4D8E8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        GradientText(
          'Engineered for Deep Mastery, Not Skimming',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: Text(
            'Generic chatbots dump wall-of-text responses that decay from memory in minutes. EduTech AI replaces passive reading with an active, multi-modal cognitive scaffolding engine.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: isMobile ? 14.5 : 16.5,
              height: 1.60,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 48),

        // ─── Bento Grid Architecture ───
        if (isMobile)
          Column(
            children: const [
              _BentoFeatureCard(
                icon: Icons.account_tree_rounded,
                iconColor: Color(0xFF2B68F6),
                title: 'Adaptive Milestone DAGs',
                tag: 'SUPERVISOR KERNEL',
                description: 'The Orchestrator agent breaks any open-ended topic into 4–7 progressive milestone nodes with auto prerequisite warmups.',
                previewWidget: _MilestoneNodesPreview(),
              ),
              SizedBox(height: 20),
              _BentoFeatureCard(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: Color(0xFF00F5D4),
                title: 'Socratic Guided Inquiry',
                tag: 'PEDAGOGICAL ENGINE',
                description: 'Never dry monologues. Contextual guiding questions, everyday mental models, and progressive anchor analogies tailored to your level.',
              ),
              SizedBox(height: 20),
              _BentoFeatureCard(
                icon: Icons.play_circle_outline_rounded,
                iconColor: Color(0xFFE879F9),
                title: 'Timestamped Vector Video Clips',
                tag: 'CHROMADB EMBEDDINGS',
                description: 'Semantic vector search across YouTube transcripts pinpoints the exact timestamp where complex concepts are illustrated visually.',
              ),
              SizedBox(height: 20),
              _BentoFeatureCard(
                icon: Icons.auto_stories_rounded,
                iconColor: Color(0xFF60A5FA),
                title: 'Live Scholarly Verification',
                tag: '250M+ PAPERS',
                description: 'Live parallel queries to arXiv, OpenAlex, and Semantic Scholar with verified DOI links, citations, and executive AI summaries.',
              ),
              SizedBox(height: 20),
              _BentoFeatureCard(
                icon: Icons.quiz_rounded,
                iconColor: Color(0xFFF59E0B),
                title: 'Grounded Formative Quizzes',
                tag: 'ZERO HALLUCINATIONS',
                description: 'Assessments generated strictly from verified lesson content with instant XP feedback and targeted remediation explanations.',
              ),
              SizedBox(height: 20),
              _BentoFeatureCard(
                icon: Icons.sync_alt_rounded,
                iconColor: Color(0xFF10B981),
                title: 'Second Brain Native Export',
                tag: 'NOTION & OBSIDIAN',
                description: 'One-click full session export to Obsidian-ready Markdown with embedded Mermaid.js diagrams, Anki flashcards, and styled PDF.',
              ),
            ],
          )
        else
          Column(
            children: [
              // Row 1: Large Featured Card (flex 7) + Secondary Card (flex 5)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    flex: 7,
                    child: _BentoFeatureCard(
                      icon: Icons.account_tree_rounded,
                      iconColor: Color(0xFF2B68F6),
                      title: 'Adaptive Milestone DAG Decomposer',
                      tag: 'AUTONOMOUS SUPERVISOR',
                      description: 'The supervisor agent decomposes complex domains into structured, dependency-checked learning milestones. Never get overwhelmed by complex topics again.',
                      previewWidget: _MilestoneNodesPreview(),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 5,
                    child: _BentoFeatureCard(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: Color(0xFF00F5D4),
                      title: 'Socratic Guided Inquiry',
                      tag: 'ACTIVE RECALL',
                      description: 'Instead of passive answers, the tutor presents scaffolding analogies and thought-provoking questions calibrated to your education level.',
                      previewWidget: _SocraticDialoguePreview(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Row 2: 3-column equal grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: _BentoFeatureCard(
                      icon: Icons.play_circle_outline_rounded,
                      iconColor: Color(0xFFE879F9),
                      title: 'Timestamped Video Clips',
                      tag: 'CHROMADB VECTOR SEARCH',
                      description: 'Pinpoints the exact seconds in university lectures and animations where your active concept is visually proven.',
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _BentoFeatureCard(
                      icon: Icons.auto_stories_rounded,
                      iconColor: Color(0xFF60A5FA),
                      title: 'Live Scholarly Grounding',
                      tag: 'ARXIV & OPENALEX',
                      description: 'Real academic preprints with authors, publishing dates, and direct links. Zero made-up citations or fake DOIs.',
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _BentoFeatureCard(
                      icon: Icons.quiz_rounded,
                      iconColor: Color(0xFFF59E0B),
                      title: 'Grounded Quizzes & XP',
                      tag: 'RETENTION GRADING',
                      description: 'Immediate formative quizzes graded by the Quizmaster agent to lock insights into long-term memory before advancing.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Row 3: Full-width Wide Ecosystem Card
              const _BentoFeatureCard(
                icon: Icons.sync_alt_rounded,
                iconColor: Color(0xFF10B981),
                title: 'Second Brain Native Knowledge Portability',
                tag: 'OBSIDIAN • NOTION • MERMAID • PDF',
                description: 'Own your knowledge graph forever. Export with preserved LaTeX equations, Mermaid flowchart diagrams, and citation tables with one single click.',
                previewWidget: _ExportPillsPreview(),
              ),
            ],
          ),
      ],
    );
  }
}

class _BentoFeatureCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String tag;
  final String description;
  final Widget? previewWidget;

  const _BentoFeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.tag,
    required this.description,
    this.previewWidget,
  });

  @override
  State<_BentoFeatureCard> createState() => _BentoFeatureCardState();
}

class _BentoFeatureCardState extends State<_BentoFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xEE090B18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? widget.iconColor.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.10),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            if (_isHovered)
              BoxShadow(
                color: widget.iconColor.withValues(alpha: 0.18),
                blurRadius: 32,
                spreadRadius: -2,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Glowing Icon + Monospace Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.iconColor.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.iconColor.withValues(alpha: 0.25),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: 22,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    widget.tag,
                    style: TextStyle(
                      color: widget.iconColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              widget.title,
              style: const TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              widget.description,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),

            if (widget.previewWidget != null) ...[
              const SizedBox(height: 20),
              widget.previewWidget!,
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MICRO PREVIEWS INSIDE BENTO CARDS
// ═══════════════════════════════════════════════════════════════════════════════

class _MilestoneNodesPreview extends StatelessWidget {
  const _MilestoneNodesPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF04060E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStepPill('1. Prereqs', 'Vectors', const Color(0xFF10B981), isDone: true),
            _buildConnector(),
            _buildStepPill('2. Core', 'Bloch Sphere', const Color(0xFF2B68F6), isActive: true),
            _buildConnector(),
            _buildStepPill('3. Gate', 'Hadamard', const Color(0xFF64748B)),
            _buildConnector(),
            _buildStepPill('4. Quiz', 'Evaluation', const Color(0xFFF59E0B)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPill(String step, String name, Color color, {bool isDone = false, bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.20) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? color : color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDone)
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 12)
          else if (isActive)
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle))
          else
            Container(width: 5, height: 5, decoration: BoxDecoration(color: color.withValues(alpha: 0.5), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(step, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w700)),
              Text(name, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white.withValues(alpha: 0.25)),
    );
  }
}

class _SocraticDialoguePreview extends StatelessWidget {
  const _SocraticDialoguePreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF04060E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF00F5D4), size: 12),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '"Before we measure the qubit, does it exist in state |0⟩, |1⟩, or an amplitude superposition of both?"',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportPillsPreview extends StatelessWidget {
  const _ExportPillsPreview();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _buildPill('Obsidian (.md)', Icons.note_alt_outlined, const Color(0xFF9061F9)),
        _buildPill('Notion Import', Icons.article_outlined, const Color(0xFF60A5FA)),
        _buildPill('Mermaid.js Flowcharts', Icons.account_tree_outlined, const Color(0xFF00F5D4)),
        _buildPill('Executive PDF', Icons.picture_as_pdf_outlined, const Color(0xFFF43F5E)),
      ],
    );
  }

  Widget _buildPill(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
