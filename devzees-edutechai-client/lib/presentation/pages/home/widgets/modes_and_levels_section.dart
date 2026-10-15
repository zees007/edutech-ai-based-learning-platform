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
      'icon': '🎬',
      'tag': 'Media-First Scaffolding',
      'color': AppColors.accentCyan,
      'description': 'Designed for students who learn by seeing and watching. Prioritizes video curation and interactive architectural diagrams.',
      'specs': [
        'Up to 3 timestamped YouTube clips / step',
        'Auto-embedded Mermaid.js concept diagrams',
        'Descriptive real-world mental models',
        'Curated literature limited to 2 papers for low cognitive load',
      ],
    },
    {
      'name': 'Deep Dive Mode',
      'icon': '🔬',
      'tag': 'Research & Rigor',
      'color': AppColors.accentPurple,
      'description': 'For undergraduates, researchers, and engineers demanding thorough mathematical, conceptual, and empirical rigor.',
      'specs': [
        'Full arXiv, Semantic Scholar & OpenAlex research preprints',
        'Mathematical notation, proofs, and edge-case mechanics',
        '5–8 paragraph comprehensive Socratic lessons',
        'High-difficulty contextual comprehension quizzes',
      ],
    },
    {
      'name': 'Bite-Sized Mode',
      'icon': '⚡',
      'tag': 'Fast Micro-Learning',
      'color': AppColors.accentAmber,
      'description': 'Engineered for busy professionals and rapid exam revision. Ultra-concise, high-impact insights in under 10 minutes.',
      'specs': [
        'Capped at exactly 4 focused milestone steps (2–3 mins each)',
        'Returns only the 1 single best video explanation',
        'Academic papers automatically skipped for zero clutter',
        'Bulleted key insights and rapid knowledge checks',
      ],
    },
  ];

  final List<Map<String, String>> _levels = [
    {
      'title': 'Middle School',
      'badge': 'Ages 11–14',
      'icon': '🏫',
      'sample': '"Think of an artificial neural network like a group of friends trying to guess what animal is in a picture. One friend looks at the fur, another at the ears. Together, they vote on the answer!"',
    },
    {
      'title': 'High School',
      'badge': 'Ages 15–18',
      'icon': '🎒',
      'sample': '"A neural network is a computer algorithm inspired by brain cells. It processes inputs through connected layers of nodes that adjust their connection strengths to recognize patterns like handwriting."',
    },
    {
      'title': 'Undergraduate',
      'badge': 'College STEM',
      'icon': '🏛️',
      'sample': '"A parameterized function f(x; θ) mapping an input space ℝⁿ to ℝᵐ. Forward propagation applies affine transformations Wx + b followed by non-linear activations like ReLU, optimized via stochastic gradient descent."',
    },
    {
      'title': 'Graduate',
      'badge': 'Research / PhD',
      'icon': '🎓',
      'sample': '"High-dimensional non-convex optimization analyzed through the empirical Neural Tangent Kernel (NTK) regime. Investigates generalization bounds, Hessian spectral decay, and inductive biases."',
    },
    {
      'title': 'General Curious',
      'badge': 'Lifelong Learner',
      'icon': '💡',
      'sample': '"A sophisticated pattern-matching machine that learns from thousands of examples rather than hand-coded rules, finding subtle mathematical patterns across complex data."',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎯', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                'ADAPTIVE COGNITIVE CALIBRATION',
                style: TextStyle(
                  color: AppColors.blueLight,
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
          '3 Learning Modes & 5 Education Levels',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Text(
            'One size fits nobody. Every AI agent in EduTech AI dynamically calibrates its vocabulary, reasoning depth, diagram density, and research rigor to your exact cognitive profile.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              fontSize: isMobile ? 15 : 17,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 48),

        // ─── Part 1: Learning Modes Switcher ───
        Text(
          '1. Choose How You Absorb Knowledge',
          style: AppTextStyles.h4.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
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
                      ? color.withValues(alpha: 0.18)
                      : AppColors.surfaceMid.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 16,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(m['icon'], style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Text(
                      m['name'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
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
          duration: const Duration(milliseconds: 300),
          child: GlassCard(
            key: ValueKey<int>(_selectedMode),
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_modes[_selectedMode]['icon'], style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Text(
                      _modes[_selectedMode]['name'],
                      style: AppTextStyles.h3.copyWith(color: _modes[_selectedMode]['color']),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (_modes[_selectedMode]['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (_modes[_selectedMode]['color'] as Color).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        _modes[_selectedMode]['tag'],
                        style: TextStyle(
                          color: _modes[_selectedMode]['color'],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _modes[_selectedMode]['description'],
                  style: AppTextStyles.body1.copyWith(color: AppColors.textSlate, height: 1.5),
                ),
                const SizedBox(height: 20),
                Divider(color: AppColors.border),
                const SizedBox(height: 16),
                const Text(
                  'AGENT PIPELINE ADAPTATION:',
                  style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
                const SizedBox(height: 12),
                ...(_modes[_selectedMode]['specs'] as List<String>).map((spec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: _modes[_selectedMode]['color']),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            spec,
                            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
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
          '2. Calibrated to Your Education Background',
          style: AppTextStyles.h4.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Click a level to see how the Socratic Tutor adapts the exact same concept ("Neural Networks"):',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List.generate(_levels.length, (idx) {
            final lvl = _levels[idx];
            final isSelected = _selectedLevel == idx;
            return InkWell(
              onTap: () => setState(() => _selectedLevel = idx),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentPink.withValues(alpha: 0.2) : AppColors.surfaceMid,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.accentPink : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lvl['icon']!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      lvl['title']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        // Live Dynamic Adaptation Preview Box
        GlassCard(
          padding: EdgeInsets.all(isMobile ? 18 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentPink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_levels[_selectedLevel]['icon']!, style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_levels[_selectedLevel]['title']} Level (${_levels[_selectedLevel]['badge']})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const Spacer(),
                  const Text('Topic: Neural Networks', style: TextStyle(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  _levels[_selectedLevel]['sample']!,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
