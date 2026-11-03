import 'dart:async';
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
  Timer? _modeTimer;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _startModeTimer();
  }

  void _startModeTimer() {
    _modeTimer?.cancel();
    _modeTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (_isHovered) return; // Pause auto-rotation when user is hovering
      setState(() {
        _selectedMode = (_selectedMode + 1) % _modes.length;
      });
    });
  }

  void _onModeSelected(int index) {
    if (_selectedMode == index) return;
    setState(() {
      _selectedMode = index;
    });
    _startModeTimer(); // Reset auto-switch timer on manual selection
  }

  @override
  void dispose() {
    _modeTimer?.cancel();
    super.dispose();
  }

  final List<Map<String, dynamic>> _modes = [
    {
      'name': 'Visual Mode',
      'icon': Icons.smart_display_rounded,
      'tag': 'Video & Diagram-First Learning',
      'color': Color(0xFF00F5D4),
      'description':
          'Designed for visual learners who understand concepts faster through video demonstrations, clean flowcharts, and relatable real-world comparisons.',
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
                  'ADAPTIVE LEARNING MODES',
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
          'Learn At Your Pace, In Your Style',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Text(
            'Whether you absorb concepts faster with interactive diagrams, demand rigorous university-level proofs, or need rapid 10-minute revisions, our multi-agent squad dynamically calibrates to how you learn best.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: isMobile ? 15 : 17,
              height: 1.6,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 24 : 36),

        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Column(
            children: [
              _buildModeSwitcher(isMobile),
              SizedBox(height: isMobile ? 18 : 24),

              // Mode Specs Card
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Container(
                  key: ValueKey<int>(_selectedMode),
                  decoration: BoxDecoration(
                    color: const Color(0xDD0A0D1D),
                    borderRadius: BorderRadius.circular(isMobile ? 18 : 22),
                    border: Border.all(
                      color: (_modes[_selectedMode]['color'] as Color)
                          .withValues(
                        alpha: 0.35,
                      ),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_modes[_selectedMode]['color'] as Color)
                            .withValues(
                          alpha: 0.12,
                        ),
                        blurRadius: isMobile ? 20 : 32,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(isMobile ? 18 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: isMobile ? 38 : 44,
                            height: isMobile ? 38 : 44,
                            decoration: BoxDecoration(
                              color: (_modes[_selectedMode]['color'] as Color)
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(isMobile ? 10 : 12),
                              border: Border.all(
                                color: (_modes[_selectedMode]['color']
                                        as Color)
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Icon(
                              _modes[_selectedMode]['icon'] as IconData,
                              color: _modes[_selectedMode]['color'] as Color,
                              size: isMobile ? 19 : 22,
                            ),
                          ),
                          SizedBox(width: isMobile ? 12 : 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _modes[_selectedMode]['name'],
                                  style: TextStyle(
                                    color: const Color(0xFFF8FAFC),
                                    fontSize: isMobile ? 17 : 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _modes[_selectedMode]['tag'],
                                  style: TextStyle(
                                    color: _modes[_selectedMode]['color']
                                        as Color,
                                    fontSize: isMobile ? 10.5 : 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 14 : 16),
                      Text(
                        _modes[_selectedMode]['description'],
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: isMobile ? 13 : 14,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 22),
                      Divider(color: Colors.white.withValues(alpha: 0.08)),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'HOW THIS MODE WORKS:',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 14),
                      ...(_modes[_selectedMode]['specs'] as List<String>)
                          .map((spec) {
                        final int colonIndex = spec.indexOf(':');
                        final bool hasLabel = colonIndex != -1;
                        final String label = hasLabel
                            ? spec.substring(0, colonIndex + 1)
                            : '';
                        final String body = hasLabel
                            ? spec.substring(colonIndex + 1)
                            : spec;

                        return Padding(
                          padding: EdgeInsets.only(bottom: isMobile ? 11 : 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2.5),
                                width: isMobile ? 15 : 16,
                                height: isMobile ? 15 : 16,
                                decoration: BoxDecoration(
                                  color:
                                      (_modes[_selectedMode]['color'] as Color)
                                          .withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: isMobile ? 10 : 11,
                                  color:
                                      _modes[_selectedMode]['color'] as Color,
                                ),
                              ),
                              SizedBox(width: isMobile ? 10 : 12),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      if (hasLabel)
                                        TextSpan(
                                          text: label,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize:
                                                isMobile ? 12.5 : 13.5,
                                          ),
                                        ),
                                      TextSpan(
                                        text: body,
                                        style: TextStyle(
                                          color: const Color(0xFFCBD5E1),
                                          fontSize:
                                              isMobile ? 12.5 : 13.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeSwitcher(bool isMobile) {
    if (isMobile) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xDD0A0D1D),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 1.0,
          ),
        ),
        child: Row(
          children: List.generate(_modes.length, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < _modes.length - 1 ? 4 : 0,
                ),
                child: _buildSegmentItem(i, isMobile: true),
              ),
            );
          }),
        ),
      );
    }

    // Desktop pill track
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xDD0A0D1D),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_modes.length, (i) {
          return Padding(
            padding: EdgeInsets.only(
              right: i < _modes.length - 1 ? 6 : 0,
            ),
            child: _buildSegmentItem(i, isMobile: false),
          );
        }),
      ),
    );
  }

  Widget _buildSegmentItem(int i, {required bool isMobile}) {
    final m = _modes[i];
    final isSelected = _selectedMode == i;
    final Color color = m['color'];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onModeSelected(i),
        borderRadius: BorderRadius.circular(9999),
        splashColor: color.withValues(alpha: 0.20),
        hoverColor: color.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 6 : 22,
            vertical: isMobile ? 11 : 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.45)
                  : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: isMobile ? 10 : 16,
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  m['icon'] as IconData,
                  size: isMobile ? 16 : 19,
                  color: isSelected ? color : const Color(0xFF94A3B8),
                ),
                SizedBox(width: isMobile ? 5 : 9),
                Text(
                  m['name'],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFFCBD5E1),
                    fontSize: isMobile ? 12.5 : 14,
                    fontWeight: isSelected
                        ? FontWeight.w800
                        : FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
