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
  int _selectedLevel =
      2; // 0: Middle School, 1: High School, 2: Undergrad, 3: Grad, 4: General

  final List<Map<String, dynamic>> _modes = [
    {
      'name': 'Visual Mode',
      'icon': Icons.smart_display_rounded,
      'tag': 'Video & Diagram-First Learning',
      'color': Color(0xFF00F5D4),
      'description':
          'Designed for visual learners who understand concepts faster through video demonstrations, clean flowcharts, and and relatable real-world comparisons.',
      'specs': [
        'Ideal Pace: 5 to 7 visual steps (around 20 minutes total)',
        'Interactive Visuals: Clean concept flowcharts and diagrams embedded directly into each lesson',
        'Exact Video Moments: Up to 3 curated YouTube clips that start playing at the exact second the concept is explained',
        'Light Reading: Up to 3 short article summaries so you are never overwhelmed with dense text',
        'Everyday Analogies: Friendly step-by-step explanations using real-world examples to help tricky ideas click easily',
      ],
    },
    {
      'name': 'Deep Dive Mode',
      'icon': Icons.biotech_rounded,
      'tag': 'Comprehensive & Academic Depth',
      'color': Color(0xFF8B5CF6),
      'description':
          'It is engineered for students, researchers, and professionals who demand a complete, in-depth understanding through rigorous proofs and peer-reviewed citations.',
      'specs': [
        'Ideal Pace: 6 to 10 comprehensive steps (around 45 minutes total)',
        'Formulas & Clear Proofs: Complete mathematical formulas, calculations, and in-depth explanations for why things work',
        'Real Published Research: Up to 4 in-depth research papers and preprints with 1-click direct PDF links',
        'Thought-Provoking Questions: Deep Socratic questions at every step that guide you to think like a subject-matter expert',
        'Challenging Quizzes: In-depth quizzes that test your true understanding, not just surface memorization',
      ],
    },
    {
      'name': 'Bite-Sized Mode',
      'icon': Icons.bolt_rounded,
      'tag': 'Fast Revision (<10 Mins)',
      'color': Color(0xFFF59E0B),
      'description':
          'Built for busy schedules and fast exam prep. Get the core takeaways and key concepts in quick, easy-to-digest breakdowns.',
      'specs': [
        'Ideal Pace: Strictly capped at 4 quick steps (under 10 minutes total)',
        'Straight to the Point: Concise, bullet-point summaries with zero filler or unnecessary reading',
        'Single Best Video: Handpicks the single best clip for fast, focused viewing',
        'Distraction-Free: Skips heavy academic papers and complex charts so you can focus purely on the key takeaway',
        'Quick Knowledge Checks: 30-second rapid quizzes to lock in what you just learned',
      ],
    },
  ];

  final List<Map<String, dynamic>> _levels = [
    {
      'title': 'Middle School',
      'badge': 'Ages 11–14',
      'icon': Icons.school_rounded,
      'color': Color(0xFF38BDF8),
      'sample':
          '"Think of an artificial neural network like a team of friends guessing what animal is in a photo. One friend looks at the fur, another checks the ears, and a third spots the tail. Together, they vote on the answer!"',
      'cognitiveFocus':
          'Intuitive visual analogies, zero jargon, relatable scenarios.',
    },
    {
      'title': 'High School',
      'badge': 'Ages 15–18',
      'icon': Icons.backpack_rounded,
      'color': Color(0xFF34D399),
      'sample':
          '"A neural network is an algorithm inspired by biological neurons. It passes inputs through layers of interconnected nodes. Each connection has an adjustable weight that tunes itself to recognize patterns like handwriting or speech."',
      'cognitiveFocus':
          'Basic algorithmic structure, input/output layers, pattern recognition.',
    },
    {
      'title': 'Undergraduate',
      'badge': 'College STEM',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF818CF8),
      'sample':
          '"A parameterized mapping function f(x; θ): ℝⁿ → ℝᵐ. Forward propagation applies affine transformations W·x + b followed by non-linear activations (ReLU, GELU). Optimization minimizes empirical loss using stochastic gradient descent and backpropagation."',
      'cognitiveFocus':
          'Matrix algebra, gradient descent, loss landscapes, backpropagation.',
    },
    {
      'title': 'Graduate',
      'badge': 'Research / PhD',
      'icon': Icons.workspace_premium_rounded,
      'color': Color(0xFFC084FC),
      'sample':
          '"Analyzed through the empirical Neural Tangent Kernel (NTK) regime in the infinite-width limit. Evaluates inductive bias, spectral decay of the Fisher Information Matrix, Hessian conditioning, and generalization bounds on non-convex manifolds."',
      'cognitiveFocus':
          'NTK analysis, FIM spectral decay, non-convex geometry, asymptotic generalization.',
    },
    {
      'title': 'General Curious',
      'badge': 'Lifelong Learner',
      'icon': Icons.lightbulb_rounded,
      'color': Color(0xFFFBBF24),
      'sample':
          '"A sophisticated pattern-matching engine that learns from millions of examples rather than rigid hand-coded rules, uncovering subtle mathematical structures hidden deep inside complex data."',
      'cognitiveFocus':
          'High conceptual clarity, practical real-world impact, accessible vocabulary.',
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
            border: Border.all(
              color: const Color(0xFF00F5D4).withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5D4).withValues(alpha: 0.16),
                blurRadius: 18,
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
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
                      BoxShadow(
                        color: Color(0xFF00F5D4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.16)
                      : const Color(0xDD0A0D1D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : Colors.white.withValues(alpha: 0.10),
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
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFCBD5E1),
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
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
                color: (_modes[_selectedMode]['color'] as Color).withValues(
                  alpha: 0.35,
                ),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_modes[_selectedMode]['color'] as Color).withValues(
                    alpha: 0.12,
                  ),
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
                        color: (_modes[_selectedMode]['color'] as Color)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (_modes[_selectedMode]['color'] as Color)
                              .withValues(alpha: 0.4),
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
                  'HOW THIS MODE WORKS:',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                ...(_modes[_selectedMode]['specs'] as List<String>).map((spec) {
                  final int colonIndex = spec.indexOf(':');
                  final bool hasLabel = colonIndex != -1;
                  final String label = hasLabel
                      ? spec.substring(0, colonIndex + 1)
                      : '';
                  final String body = hasLabel
                      ? spec.substring(colonIndex + 1)
                      : spec;

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
                            color: (_modes[_selectedMode]['color'] as Color)
                                .withValues(alpha: 0.18),
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
                          child: Text.rich(
                            TextSpan(
                              children: [
                                if (hasLabel)
                                  TextSpan(
                                    text: label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                TextSpan(
                                  text: body,
                                  style: const TextStyle(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ],
                            ),
                            style: const TextStyle(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.16)
                      : const Color(0xDD0A0D1D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : Colors.white.withValues(alpha: 0.10),
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
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFCBD5E1),
                        fontSize: 12.5,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
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
                color: (_levels[_selectedLevel]['color'] as Color).withValues(
                  alpha: 0.35,
                ),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_levels[_selectedLevel]['color'] as Color).withValues(
                    alpha: 0.12,
                  ),
                  blurRadius: 30,
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: (_levels[_selectedLevel]['color'] as Color)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _levels[_selectedLevel]['icon'] as IconData,
                        size: 17,
                        color: _levels[_selectedLevel]['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_levels[_selectedLevel]['title']} (${_levels[_selectedLevel]['badge']})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFF1F5F9),
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                          Text(
                            _levels[_selectedLevel]['cognitiveFocus'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: (_levels[_selectedLevel]['color'] as Color)
                                  .withValues(alpha: 0.9),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                      color: (_levels[_selectedLevel]['color'] as Color)
                          .withValues(alpha: 0.20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: const Text(
                          'TOPIC: NEURAL NETWORKS',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Text(
                        _levels[_selectedLevel]['sample'] as String,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 14,
                          height: 1.65,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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
}
