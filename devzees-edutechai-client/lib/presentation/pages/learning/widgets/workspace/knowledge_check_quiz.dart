import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KnowledgeCheckQuiz extends StatefulWidget {
  final List<dynamic>? quiz;

  const KnowledgeCheckQuiz({super.key, this.quiz});

  @override
  State<KnowledgeCheckQuiz> createState() => _KnowledgeCheckQuizState();
}

class _KnowledgeCheckQuizState extends State<KnowledgeCheckQuiz> {
  int? _selectedIndex;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    if (widget.quiz == null || widget.quiz!.isEmpty) {
      return const SizedBox.shrink();
    }

    final quizData = widget.quiz!.first;
    final question = quizData is Map ? quizData['question'] ?? 'What is the primary concept discussed?' : 'Sample Question';
    final List<String> options = quizData is Map && quizData['options'] is List
        ? (quizData['options'] as List).map((e) => e.toString()).toList()
        : ['Option A', 'Option B', 'Option C', 'Option D'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF43F5E).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📝', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Milestone Knowledge Check',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            question,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(options.length, (index) {
            final isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: _submitted ? null : () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF43F5E).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFF43F5E) : Colors.white.withValues(alpha: 0.1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFF43F5E) : Colors.white54,
                          width: 2,
                        ),
                        color: isSelected ? const Color(0xFFF43F5E) : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        options[index],
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _selectedIndex == null || _submitted
                  ? null
                  : () {
                      setState(() {
                        _submitted = true;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _submitted ? 'Submitted' : 'Submit Answer',
                style: GoogleFonts.inter(
                  color: _selectedIndex == null ? Colors.white54 : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
