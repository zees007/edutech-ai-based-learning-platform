import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class WorkspacePreviewSection extends StatefulWidget {
  const WorkspacePreviewSection({super.key});

  @override
  State<WorkspacePreviewSection> createState() => _WorkspacePreviewSectionState();
}

class _WorkspacePreviewSectionState extends State<WorkspacePreviewSection> {
  int _activeContextTab = 0; // 0: Video Clip, 1: Academic Paper, 2: Formative Quiz
  int? _selectedQuizAnswer;
  bool _quizSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        // Section Header
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
              const Text('✨', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                'LIVE WORKSPACE PREVIEW',
                style: TextStyle(
                  color: AppColors.adaptiveLavender,
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
          'Dual-Panel Cognitive Workspace',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Text(
            'See how our autonomous agent squad turns passive reading into an active, multi-modal masterclass. Socratic dialogue on the left, verified multimedia and grounded quizzes on the right.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              fontSize: isMobile ? 15 : 17,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 36),

        // Interactive Context Tab Switcher
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _buildTabPill(
              index: 0,
              icon: '🎬',
              label: 'Timestamped Video Clip',
              badge: 'Semantic Vector Search',
            ),
            _buildTabPill(
              index: 1,
              icon: '📚',
              label: 'Academic Preprints',
              badge: 'arXiv & OpenAlex',
            ),
            _buildTabPill(
              index: 2,
              icon: '📝',
              label: 'Dynamic Formative Quiz',
              badge: 'Grounded Assessment',
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Workspace Container Mockup
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceMid.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: -10,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                _buildMockWorkspaceHeader(isMobile),
                Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
                if (isMobile)
                  Column(
                    children: [
                      _buildLeftTutorPanel(isMobile),
                      Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
                      _buildRightContextPanel(isMobile),
                    ],
                  )
                else
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 6, child: _buildLeftTutorPanel(isMobile)),
                        VerticalDivider(width: 1, color: AppColors.border.withValues(alpha: 0.5)),
                        Expanded(flex: 5, child: _buildRightContextPanel(isMobile)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabPill({
    required int index,
    required String icon,
    required String label,
    required String badge,
  }) {
    final bool isSelected = _activeContextTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeContextTab = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.22)
              : AppColors.surfaceMid.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.surfaceDark.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockWorkspaceHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppColors.surfaceDark.withValues(alpha: 0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Topic and Step Indicator
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('⚛️', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Quantum Computing & Superposition',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: isMobile ? 13 : 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Step 2 of 5: The Superposition Principle & Bloch Sphere',
                        style: TextStyle(
                          color: AppColors.adaptiveLavender,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Gamification Badges
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Text('🔥 3 Days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentAmber)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Text(
                  '⭐ 720 XP',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftTutorPanel(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agent Identity Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('💬', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Socratic Tutor Agent',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Pedagogical Scaffolding • Level: Undergraduate',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: AppColors.accentGreen),
                    SizedBox(width: 5),
                    Text('Active Turn', style: TextStyle(color: AppColors.accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Socratic Text
          Text(
            'Imagine flipping a coin. While spinning through the air, before landing flat on the table, is it definitely Heads or definitely Tails?\n\nIn classical computing, a bit is strictly 0 or 1. But a quantum qubit exists in a linear combination of both states simultaneously, governed by probability amplitudes: |ψ⟩ = α|0⟩ + β|1⟩.',
            style: AppTextStyles.body1.copyWith(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Mermaid Flowchart Mockup Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_tree_outlined, size: 14, color: AppColors.adaptiveLavender),
                    const SizedBox(width: 6),
                    Text(
                      'CONCEPT FLOW DIAGRAM (MERMAID.JS)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: AppColors.adaptiveLavender,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDiagramNode('Classical Bit', 'Deterministic [0 OR 1]', AppColors.accentBlue),
                      _buildDiagramArrow('Superposition'),
                      _buildDiagramNode('Quantum Qubit', '|ψ⟩ = α|0⟩ + β|1⟩', AppColors.accentPurple),
                      _buildDiagramArrow('Measurement'),
                      _buildDiagramNode('State Collapse', 'Eigenvalue |0⟩ or |1⟩', AppColors.accentGreen),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Socratic Guiding Questions
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🤔', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 8),
                    Text(
                      'Ponder This Before Advancing:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'What physical mechanism causes the probability wave function to collapse upon observation? Can a qubit perform computations while in superposition?',
                  style: TextStyle(
                    color: AppColors.textSlate,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Follow-up Chat Input Bar Mockup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ask the Socratic Tutor a follow-up question...',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_upward, size: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagramNode(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildDiagramArrow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 8)),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(width: 24, height: 1.5, color: AppColors.border),
              Icon(Icons.chevron_right, size: 12, color: AppColors.border),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightContextPanel(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      color: AppColors.surfaceDark.withValues(alpha: 0.4),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildSelectedTabContent(),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_activeContextTab) {
      case 0:
        return _buildVideoClipCard();
      case 1:
        return _buildAcademicPaperCard();
      case 2:
      default:
        return _buildQuizCard();
    }
  }

  Widget _buildVideoClipCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text('🎬', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'Curated YouTube Deep-Link',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              child: const Text('AUTO-SEEK: 03:42', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Video Player Mockup Card
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Veritasium: How Quantum Computers Break Encryption',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    const Text('03:42', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.32,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('14:20', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceMid.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote, size: 16, color: AppColors.accentCyan),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Transcript Match: "...and when the electron traverses both slits at once, it creates an interference pattern characteristic of quantum superposition..."',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.white70, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicPaperCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text('📚', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'Curated Academic Literature',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
              ),
              child: const Text('arXiv:2308.10928', style: TextStyle(color: AppColors.accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Experimental Demonstration of Multi-Qubit Quantum Superposition in Superconducting Circuits',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Authors: J. Martinez, E. Chen et al. • Physical Review Letters',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 AI KEY TAKEAWAY', style: TextStyle(color: AppColors.accentBlue, fontSize: 9, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      'Achieves 99.8% fidelity in maintaining coherent superposition states across 12 entangled Josephson junction qubits at 15mK.',
                      style: TextStyle(color: AppColors.textSlate, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.picture_as_pdf, size: 14),
                    label: const Text('Download PDF', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: const Text('OpenAlex DOI', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizCard() {
    final List<String> options = [
      'Measurement interaction with the external environment',
      'Increasing the temperature above absolute zero',
      'The spontaneous decay of electrons over time',
      'Gravitational lensing around the quantum sensor',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text('📝', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'Formative Knowledge Check',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.3)),
              ),
              child: const Text('+20 XP REWARD', style: TextStyle(color: AppColors.accentAmber, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'According to the Copenhagen interpretation, what precipitates the collapse of a superposition wave function into a single state?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),

        ...List.generate(options.length, (i) {
          final isSelected = _selectedQuizAnswer == i;
          final isCorrect = i == 0;
          Color cardBorder = AppColors.border;
          Color cardBg = AppColors.surfaceDark;

          if (_quizSubmitted) {
            if (isCorrect) {
              cardBorder = AppColors.accentGreen;
              cardBg = AppColors.accentGreen.withValues(alpha: 0.15);
            } else if (isSelected && !isCorrect) {
              cardBorder = Colors.redAccent;
              cardBg = Colors.redAccent.withValues(alpha: 0.15);
            }
          } else if (isSelected) {
            cardBorder = AppColors.primary;
            cardBg = AppColors.primary.withValues(alpha: 0.2);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                if (!_quizSubmitted) {
                  setState(() {
                    _selectedQuizAnswer = i;
                  });
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  children: [
                    Text(
                      '${String.fromCharCode(65 + i)}.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: isSelected ? AppColors.accentBlue : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        options[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (_quizSubmitted && isCorrect)
                      const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 16),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_quizSubmitted)
              const Text(
                '✅ Correct! +20 XP awarded to profile.',
                style: TextStyle(color: AppColors.accentGreen, fontSize: 11, fontWeight: FontWeight.bold),
              )
            else
              const Text(
                'Select an answer to verify mastery',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ElevatedButton(
              onPressed: _selectedQuizAnswer == null
                  ? null
                  : () {
                      setState(() {
                        _quizSubmitted = !_quizSubmitted;
                        if (!_quizSubmitted) _selectedQuizAnswer = null;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _quizSubmitted ? 'Reset' : 'Submit Answer',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
