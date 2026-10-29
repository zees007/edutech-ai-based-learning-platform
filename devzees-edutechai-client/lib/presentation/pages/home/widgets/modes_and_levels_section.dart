import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class ModesAndLevelsSection extends StatefulWidget {
  const ModesAndLevelsSection({super.key});

  @override
  State<ModesAndLevelsSection> createState() => _ModesAndLevelsSectionState();
}

class _ModesAndLevelsSectionState extends State<ModesAndLevelsSection> {
  int _selectedMode = 0; // 0: Visual, 1: Deep Dive, 2: Bite-Sized
  int _selectedLevel = 2; // 0: Middle School, 1: High School, 2: Undergrad, 3: Grad, 4: General

  final List<Map<String, dynamic>> _modes = [
    {
      'name': 'Visual Mode',
      'icon': Icons.smart_display_rounded,
      'tag': 'Media-First Scaffolding',
      'color': Color(0xFF00F5D4),
      'description': 'Designed for visual learners. Prioritizes timestamped video clips, interactive concept flowcharts, and concrete everyday physical mental models.',
      'specs': [
        'Up to 3 verified timestamped YouTube clips per milestone',
        'Auto-generated Mermaid.js architectural diagrams & charts',
        'Visual analogy scaffolding with progressive concept anchors',
        'Academic preprints capped at 2 for low cognitive overhead',
      ],
    },
    {
      'name': 'Deep Dive Mode',
      'icon': Icons.biotech_rounded,
      'tag': 'Research & Empirical Rigor',
      'color': Color(0xFF8B5CF6),
      'description': 'Engineered for STEM undergraduates, researchers, and engineers demanding complete mathematical proofs, peer-reviewed citations, and theoretical rigor.',
      'specs': [
        'Full arXiv, Semantic Scholar & OpenAlex preprints with DOIs',
        'LaTeX mathematical derivations, proofs, and edge-case mechanics',
        'Comprehensive multi-turn Socratic dialogue with deep probing',
        'High-difficulty contextual comprehension quizzes with XP multipliers',
      ],
    },
    {
      'name': 'Bite-Sized Mode',
      'icon': Icons.bolt_rounded,
      'tag': 'Rapid Micro-Learning',
      'color': Color(0xFFF59E0B),
      'description': 'Optimized for busy professionals and rapid exam revision. Delivers high-density mental models and core insights in under 10 minutes.',
      'specs': [
        'Strictly capped at 4 focused milestone steps (2–3 mins each)',
        'Returns the 1 single highest-signal verified video explanation',
        'Academic papers automatically omitted for zero visual clutter',
        'Bulleted executive takeaways and lightning knowledge checks',
      ],
    },
  ];

  final List<Map<String, dynamic>> _levels = [
    {
      'title': 'Middle School',
      'badge': 'Ages 11–14',
      'icon': Icons.school_rounded,
      'color': Color(0xFF38BDF8),
      'sample': '"Think of an artificial neural network like a team of friends guessing what animal is in a photo. One friend looks at the fur, another checks the ears, and a third spots the tail. Together, they vote on the answer!"',
      'cognitiveFocus': 'Intuitive visual analogies, zero jargon, relatable scenarios.',
    },
    {
      'title': 'High School',
      'badge': 'Ages 15–18',
      'icon': Icons.backpack_rounded,
      'color': Color(0xFF34D399),
      'sample': '"A neural network is an algorithm inspired by biological neurons. It passes inputs through layers of interconnected nodes. Each connection has an adjustable weight that tunes itself to recognize patterns like handwriting or speech."',
      'cognitiveFocus': 'Basic algorithmic structure, input/output layers, pattern recognition.',
    },
    {
      'title': 'Undergraduate',
      'badge': 'College STEM',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF818CF8),
      'sample': '"A parameterized mapping function f(x; θ): ℝⁿ → ℝᵐ. Forward propagation applies affine transformations W·x + b followed by non-linear activations (ReLU, GELU). Optimization minimizes empirical loss using stochastic gradient descent and backpropagation."',
      'cognitiveFocus': 'Matrix algebra, gradient descent, loss landscapes, backpropagation.',
    },
    {
      'title': 'Graduate',
      'badge': 'Research / PhD',
      'icon': Icons.workspace_premium_rounded,
      'color': Color(0xFFC084FC),
      'sample': '"Analyzed through the empirical Neural Tangent Kernel (NTK) regime in the infinite-width limit. Evaluates inductive bias, spectral decay of the Fisher Information Matrix, Hessian conditioning, and generalization bounds on non-convex manifolds."',
      'cognitiveFocus': 'NTK analysis, FIM spectral decay, non-convex geometry, asymptotic generalization.',
    },
    {
      'title': 'General Curious',
      'badge': 'Lifelong Learner',
      'icon': Icons.lightbulb_rounded,
      'color': Color(0xFFFBBF24),
      'sample': '"A sophisticated pattern-matching engine that learns from millions of examples rather than rigid hand-coded rules, uncovering subtle mathematical structures hidden deep inside complex data."',
      'cognitiveFocus': 'High conceptual clarity, practical real-world impact, accessible vocabulary.',
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
            color: const Color(0xFF00F5D4).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: const Color(0xFF00F5D4).withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5D4).withValues(alpha: 0.16),
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
                  color: Color(0xFF00F5D4),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF00F5D4), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ADAPTIVE COGNITIVE CALIBRATION',
                style: TextStyle(
                  color: Color(0xFFCCFBF1),
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
          '3 Learning Modes. 5 Cognitive Levels.',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Text(
            'One size fits nobody. Every agent dynamically calibrates its vocabulary, diagram density, question rigor, and video recommendations to match your exact academic background.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: isMobile ? 15 : 17,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 48),

        // ─── Part 1: Learning Modes Switcher ───
        Text(
          '1. Choose How You Absorb Knowledge',
          style: TextStyle(
            color: const Color(0xFFF1F5F9),
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List.generate(_modes.length, (i) {
            final m = _modes[i];
            final isSelected = _selectedMode == i;
            final Color color = m['color'];

            return InkWell(
              onTap: () => setState(() => _selectedMode = i),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.16)
                      : const Color(0xDD0A0D1D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : Colors.white.withValues(alpha: 0.10),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.30),
                            blurRadius: 18,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      m['icon'] as IconData,
                      size: 20,
                      color: isSelected ? color : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      m['name'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Mode Specs Card
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Container(
            key: ValueKey<int>(_selectedMode),
            decoration: BoxDecoration(
              color: const Color(0xDD0A0D1D),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: (_modes[_selectedMode]['color'] as Color).withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_modes[_selectedMode]['color'] as Color).withValues(alpha: 0.12),
                  blurRadius: 32,
                ),
              ],
            ),
            padding: EdgeInsets.all(isMobile ? 22 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (_modes[_selectedMode]['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (_modes[_selectedMode]['color'] as Color).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        _modes[_selectedMode]['icon'] as IconData,
                        color: _modes[_selectedMode]['color'] as Color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _modes[_selectedMode]['name'],
                            style: TextStyle(
                              color: const Color(0xFFF8FAFC),
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _modes[_selectedMode]['tag'],
                            style: TextStyle(
                              color: _modes[_selectedMode]['color'] as Color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _modes[_selectedMode]['description'],
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 22),
                Divider(color: Colors.white.withValues(alpha: 0.08)),
                const SizedBox(height: 16),
                const Text(
                  'PIPELINE CALIBRATION SPECS:',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                ...(_modes[_selectedMode]['specs'] as List<String>).map((spec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: (_modes[_selectedMode]['color'] as Color).withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 11,
                            color: _modes[_selectedMode]['color'] as Color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            spec,
                            style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        const SizedBox(height: 56),

        // ─── Part 2: Education Levels Switcher ───
        Text(
          '2. Calibrated to Your Education Level',
          style: TextStyle(
            color: const Color(0xFFF1F5F9),
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Click a level to see how the Socratic Tutor adapts the exact same concept ("Neural Networks"):',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List.generate(_levels.length, (idx) {
            final lvl = _levels[idx];
            final isSelected = _selectedLevel == idx;
            final Color color = lvl['color'];

            return InkWell(
              onTap: () => setState(() => _selectedLevel = idx),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.16)
                      : const Color(0xDD0A0D1D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : Colors.white.withValues(alpha: 0.10),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.28),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      lvl['icon'] as IconData,
                      size: 16,
                      color: isSelected ? color : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lvl['title'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 22),

        // Live Dynamic Adaptation Preview Box
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Container(
            key: ValueKey<int>(_selectedLevel),
            decoration: BoxDecoration(
              color: const Color(0xDD0A0D1D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (_levels[_selectedLevel]['color'] as Color).withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_levels[_selectedLevel]['color'] as Color).withValues(alpha: 0.12),
                  blurRadius: 30,
                ),
              ],
            ),
            padding: EdgeInsets.all(isMobile ? 20 : 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: (_levels[_selectedLevel]['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _levels[_selectedLevel]['icon'] as IconData,
                        size: 17,
                        color: _levels[_selectedLevel]['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_levels[_selectedLevel]['title']} (${_levels[_selectedLevel]['badge']})',
                          style: const TextStyle(
                            color: Color(0xFFF1F5F9),
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          _levels[_selectedLevel]['cognitiveFocus'] as String,
                          style: TextStyle(
                            color: (_levels[_selectedLevel]['color'] as Color).withValues(alpha: 0.9),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: const Text(
                        'TOPIC: NEURAL NETWORKS',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF080A16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (_levels[_selectedLevel]['color'] as Color).withValues(alpha: 0.20),
                    ),
                  ),
                  child: Text(
                    _levels[_selectedLevel]['sample'] as String,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 14,
                      height: 1.65,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
