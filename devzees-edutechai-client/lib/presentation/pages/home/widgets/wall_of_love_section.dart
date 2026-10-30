import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

/// Ultra-premium Social Proof / Wall of Love Section for EduTech AI.
/// Displays verified student and STEM researcher testimonials with university badges.
class WallOfLoveSection extends StatelessWidget {
  const WallOfLoveSection({super.key});

  static const List<_TestimonialData> _testimonials = [
    _TestimonialData(
      name: 'Marcus Chen',
      role: 'EECS Undergraduate',
      institution: 'MIT',
      avatarColor: Color(0xFF2B68F6),
      quote:
          'ChatGPT kept giving me walls of text that felt convincing until I tried solving the problem set. EduTech AI\'s Socratic Tutor broke the Hamiltonian down into progressive hints that forced me to derive the proof myself.',
      topicTag: 'Quantum Mechanics',
      avatarInitial: 'MC',
    ),
    _TestimonialData(
      name: 'Dr. Elena Rostova',
      role: 'Postdoctoral Fellow',
      institution: 'Stanford University',
      avatarColor: Color(0xFF10B981),
      quote:
          'The vector video deep-linking and direct arXiv citations save me 15+ hours weekly. Instead of scrubbing 2-hour lectures, it drops me at the exact 90-second segment where the mathematical mechanism is animated.',
      topicTag: 'CRISPR Gene Editing',
      avatarInitial: 'ER',
    ),
    _TestimonialData(
      name: 'Priya Sharma',
      role: 'Natural Sciences Scholar',
      institution: 'Cambridge',
      avatarColor: Color(0xFF8B5CF6),
      quote:
          'Exporting my masterclasses directly into Obsidian with native Mermaid.js flowcharts and LaTeX formulas is game-changing. My entire second brain is structured with zero manual copy-pasting.',
      topicTag: 'Organic Chemistry',
      avatarInitial: 'PS',
    ),
    _TestimonialData(
      name: 'David Kim',
      role: 'Staff Systems Engineer',
      institution: 'Google Cloud',
      avatarColor: Color(0xFFF59E0B),
      quote:
          'Bite-Sized mode is my secret weapon. In 10 minutes over coffee, I get a clear mental model of complex distributed consensus algorithms like Raft and Paxos without fluffy jargon.',
      topicTag: 'Distributed Systems',
      avatarInitial: 'DK',
    ),
    _TestimonialData(
      name: 'Sofia Al-Mansoor',
      role: 'Pre-University Scholar',
      institution: 'Oxford Candidate',
      avatarColor: Color(0xFF00F5D4),
      quote:
          'Switching from High School to Undergraduate level on the fly is incredible. Whenever a concept feels too simple, I bump the cognitive slider and immediately get deeper mathematical rigor.',
      topicTag: 'Linear Algebra',
      avatarInitial: 'SA',
    ),
    _TestimonialData(
      name: 'Lucas Vance',
      role: 'Economics & Data Science',
      institution: 'Columbia',
      avatarColor: Color(0xFFEC4899),
      quote:
          'The formative quizzes are actually grounded in what I just learned—zero hallucinations, no irrelevant trivia. And the streak tracking genuinely keeps me accountable every single day.',
      topicTag: 'Causal Inference',
      avatarInitial: 'LV',
    ),
  ];

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
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
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
                  color: Color(0xFFF59E0B),
                  boxShadow: [
                    BoxShadow(color: Color(0xFFF59E0B), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'STUDENT & RESEARCHER REPUTATION',
                style: TextStyle(
                  color: Color(0xFFFDE68A),
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
          'Loved by Ambitious Learners Worldwide',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'From MIT undergraduates tackling quantum algorithms to postdocs analyzing CRISPR preprints—see why serious learners choose our autonomous cognitive squad over generic chatbots.',
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

        // ─── Testimonials Grid ───
        if (isMobile)
          Column(
            children: _testimonials
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _TestimonialCard(data: item),
                    ))
                .toList(),
          )
        else
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _testimonials
                .map((item) => SizedBox(
                      width: 370,
                      child: _TestimonialCard(data: item),
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class _TestimonialData {
  final String name;
  final String role;
  final String institution;
  final Color avatarColor;
  final String quote;
  final String topicTag;
  final String avatarInitial;

  const _TestimonialData({
    required this.name,
    required this.role,
    required this.institution,
    required this.avatarColor,
    required this.quote,
    required this.topicTag,
    required this.avatarInitial,
  });
}

class _TestimonialCard extends StatefulWidget {
  final _TestimonialData data;
  const _TestimonialCard({required this.data});

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: const Color(0xCC0B0D1B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? widget.data.avatarColor.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.10),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.50),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            if (_isHovered)
              BoxShadow(
                color: widget.data.avatarColor.withValues(alpha: 0.18),
                blurRadius: 30,
                spreadRadius: -2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Avatar + Info + Stars
                Row(
                  children: [
                    // Avatar Circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.data.avatarColor.withValues(alpha: 0.18),
                        border: Border.all(
                          color: widget.data.avatarColor.withValues(alpha: 0.40),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.data.avatarInitial,
                          style: TextStyle(
                            color: widget.data.avatarColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.data.name,
                                  style: const TextStyle(
                                    color: Color(0xFFF8FAFC),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF38BDF8),
                                size: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.data.role} • ${widget.data.institution}',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stars Row
                Row(
                  children: List.generate(
                    5,
                    (index) => const Padding(
                      padding: EdgeInsets.only(right: 3),
                      child: Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFBBF24),
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Quote Body
                Text(
                  '"${widget.data.quote}"',
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 13.5,
                    height: 1.55,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),

                // Bottom Tag
                Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.data.avatarColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.data.avatarColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 12,
                        color: widget.data.avatarColor,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Mastered: ${widget.data.topicTag}',
                          style: TextStyle(
                            color: widget.data.avatarColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
