import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/providers/active_session_provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/text_styles.dart';

class KnowledgeCheckQuiz extends ConsumerStatefulWidget {
  final List<dynamic>? quiz;
  final Future<void> Function()? onNextStep;
  final int stepIndex;
  final VoidCallback? onQuizSubmitted;

  const KnowledgeCheckQuiz({super.key, this.quiz, this.onNextStep, required this.stepIndex, this.onQuizSubmitted});

  @override
  ConsumerState<KnowledgeCheckQuiz> createState() => _KnowledgeCheckQuizState();
}

class _KnowledgeCheckQuizState extends ConsumerState<KnowledgeCheckQuiz> {
  final Map<int, int> _selectedAnswers = {};
  final Map<int, String> _textAnswers = {};
  final Map<int, TextEditingController> _controllers = {};
  bool _submitted = false;
  bool _isSubmitting = false;
  bool _isAdvancing = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(int index) {
    return _controllers.putIfAbsent(
      index,
      () => TextEditingController(text: _textAnswers[index] ?? ''),
    );
  }

  bool _isFillInTheBlank(Map<String, dynamic> qData) {
    final qType = (qData['question_type'] ?? '').toString().toLowerCase();
    final options = qData['options'] is List ? (qData['options'] as List) : [];
    return qType.contains('blank') || qType.contains('fill') || options.isEmpty;
  }

  bool _isQuestionCorrect(int questionIndex, Map<String, dynamic> qData) {
    final correctRaw = (qData['correct_option'] ?? qData['correct_answer'] ?? '').toString().trim();
    final correctUpper = correctRaw.toUpperCase();

    if (_isFillInTheBlank(qData)) {
      final userAnswer = (_textAnswers[questionIndex] ?? '').trim();
      if (userAnswer.isEmpty) return false;
      final userUpper = userAnswer.toUpperCase();
      if (userUpper == correctUpper) return true;
      if (correctUpper.isNotEmpty && userUpper.contains(correctUpper)) return true;
      if (userUpper.isNotEmpty && correctUpper.contains(userUpper) && userUpper.length >= 3) return true;
      return false;
    } else {
      final selectedOptionIndex = _selectedAnswers[questionIndex];
      if (selectedOptionIndex == null) return false;
      final options = (qData['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
      if (selectedOptionIndex < 0 || selectedOptionIndex >= options.length) return false;

      final selectedFull = options[selectedOptionIndex];
      final selectedKey = selectedFull.split(':').first.split(')').first.split('.').first.trim().toUpperCase();

      if (selectedKey == correctUpper) return true;
      if (correctUpper.length > 1 && selectedFull.toUpperCase().contains(correctUpper)) return true;
      return false;
    }
  }

  bool _isAllAnswered(List<dynamic> quizList) {
    for (int i = 0; i < quizList.length; i++) {
      final qData = quizList[i] is Map ? (quizList[i] as Map<String, dynamic>) : <String, dynamic>{};
      if (_isFillInTheBlank(qData)) {
        if ((_textAnswers[i]?.trim().isEmpty ?? true)) {
          return false;
        }
      } else {
        if (!_selectedAnswers.containsKey(i)) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quiz == null || widget.quiz!.isEmpty) {
      return const SizedBox.shrink();
    }

    final quizList = widget.quiz!;
    int correctCount = 0;
    if (_submitted) {
      for (int i = 0; i < quizList.length; i++) {
        final qData = quizList[i] is Map ? (quizList[i] as Map<String, dynamic>) : <String, dynamic>{};
        if (_isQuestionCorrect(i, qData)) {
          correctCount++;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.rose.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.rose.withValues(alpha: 0.3)),
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
                style: AppTextStyles.h2.copyWith(
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(quizList.length, (index) {
            final quizData = quizList[index] is Map ? (quizList[index] as Map<String, dynamic>) : <String, dynamic>{};
            final question = quizData['question']?.toString() ?? 'Question ${index + 1}';
            final isFillBlank = _isFillInTheBlank(quizData);
            final List<String> options = quizData['options'] is List
                ? (quizData['options'] as List).map((e) => e.toString()).toList()
                : [];
            final explanation = quizData['explanation']?.toString() ?? '';
            final correctAnswerRaw = quizData['correct_option']?.toString() ?? quizData['correct_answer']?.toString() ?? '';

            final isCorrect = _submitted ? _isQuestionCorrect(index, quizData) : false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Q${index + 1}: $question',
                          style: AppTextStyles.subtitle1.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                      if (isFillBlank)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.rose.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.rose.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Fill in Blank',
                            style: AppTextStyles.badge.copyWith(
                              color: AppColors.roseLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (isFillBlank) ...[
                    // Fill-in-the-blank stylish input field
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _submitted
                            ? (isCorrect ? AppColors.accentGreen.withValues(alpha: 0.1) : AppColors.accentRose.withValues(alpha: 0.1))
                            : AppColors.glassSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _submitted
                              ? (isCorrect ? AppColors.accentGreen : AppColors.accentRose)
                              : AppColors.rose.withValues(alpha: 0.35),
                          width: _submitted ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: TextField(
                        controller: _getController(index),
                        enabled: !_submitted,
                        style: AppTextStyles.bodyPrimary,
                        cursorColor: AppColors.rose,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type your answer for the blank here...',
                          hintStyle: AppTextStyles.bodyPrimary.copyWith(
                            color: AppColors.textMuted,
                          ),
                          icon: Icon(
                            Icons.edit_note_rounded,
                            color: _submitted
                                ? (isCorrect ? AppColors.accentGreen : AppColors.accentRose)
                                : AppColors.rose.withValues(alpha: 0.8),
                            size: 22,
                          ),
                          suffixIcon: _submitted
                              ? Icon(
                                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  color: isCorrect ? AppColors.accentGreen : AppColors.accentRose,
                                  size: 22,
                                )
                              : null,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _textAnswers[index] = val;
                          });
                        },
                      ),
                    ),
                  ] else ...[
                    // Multiple-choice options list
                    ...List.generate(options.length, (optIndex) {
                      final isSelected = _selectedAnswers[index] == optIndex;
                      Color borderColor = AppColors.glassBorder;
                      Color bgColor = AppColors.glassSurface.withValues(alpha: 0.05);
                      Color iconColor = AppColors.textMuted;
                      IconData? icon;

                      if (isSelected) {
                        borderColor = AppColors.rose;
                        bgColor = AppColors.rose.withValues(alpha: 0.15);
                        iconColor = AppColors.rose;
                        icon = Icons.check;
                      }

                      if (_submitted) {
                        bool isThisOptionCorrect = false;
                        final optKey = options[optIndex].split(':').first.split(')').first.split('.').first.trim().toUpperCase();
                        final correctUpper = correctAnswerRaw.trim().toUpperCase();
                        if (optKey == correctUpper || (correctUpper.length > 1 && options[optIndex].toUpperCase().contains(correctUpper))) {
                          isThisOptionCorrect = true;
                        }

                        if (isThisOptionCorrect) {
                          borderColor = AppColors.accentGreen;
                          bgColor = AppColors.accentGreen.withValues(alpha: 0.15);
                          iconColor = AppColors.accentGreen;
                          icon = Icons.check_circle;
                        } else if (isSelected && !isThisOptionCorrect) {
                          borderColor = AppColors.accentRose;
                          bgColor = AppColors.accentRose.withValues(alpha: 0.15);
                          iconColor = AppColors.accentRose;
                          icon = Icons.cancel;
                        }
                      }

                      return GestureDetector(
                        onTap: _submitted ? null : () {
                          setState(() {
                            _selectedAnswers[index] = optIndex;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: borderColor,
                              width: isSelected || (_submitted && (borderColor == AppColors.accentGreen || borderColor == AppColors.accentRose)) ? 2 : 1,
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
                                    color: iconColor,
                                    width: 2,
                                  ),
                                  color: (isSelected || (_submitted && (borderColor == AppColors.accentGreen || borderColor == AppColors.accentRose))) ? iconColor : Colors.transparent,
                                ),
                                child: icon != null && (isSelected || _submitted)
                                    ? Icon(icon, size: 16, color: AppColors.textPrimary)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  options[optIndex],
                                  style: AppTextStyles.bodyPrimary.copyWith(
                                    color: isSelected || (_submitted && borderColor == AppColors.accentGreen) ? AppColors.textPrimary : AppColors.textSecondary,
                                    fontWeight: isSelected || (_submitted && borderColor == AppColors.accentGreen) ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],

                  if (_submitted) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect ? AppColors.accentGreen.withValues(alpha: 0.1) : AppColors.accentRose.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isCorrect ? AppColors.accentGreen.withValues(alpha: 0.3) : AppColors.accentRose.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle_outline : Icons.error_outline,
                            color: isCorrect ? AppColors.accentGreen : AppColors.accentRose,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCorrect ? 'Correct!' : 'Incorrect',
                                  style: AppTextStyles.label.copyWith(
                                    color: isCorrect ? AppColors.accentGreen : AppColors.accentRose,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!isCorrect && correctAnswerRaw.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Correct Answer: $correctAnswerRaw',
                                    style: AppTextStyles.captionBold.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                                if (explanation.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    explanation,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textPrimary.withValues(alpha: 0.85),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (index < quizList.length - 1)
                    Divider(color: AppColors.glassBorder, height: 32),
                ],
              ),
            );
          }),
          
          if (_submitted) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.rose.withValues(alpha: 0.2),
                    AppColors.rose.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.rose.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quiz Results',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Score: ${((correctCount / quizList.length) * 100).toStringAsFixed(0)}% ($correctCount/${quizList.length} Correct)',
                        style: AppTextStyles.h3,
                      ),
                    ],
                  ),
                  if (widget.onNextStep != null)
                    ElevatedButton(
                      onPressed: _isAdvancing ? null : () async {
                        setState(() {
                          _isAdvancing = true;
                        });
                        await widget.onNextStep!();
                        if (mounted) {
                          setState(() {
                            _isAdvancing = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rose,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        shadowColor: AppColors.rose.withValues(alpha: 0.5),
                      ),
                      child: _isAdvancing 
                        ? const SizedBox(
                            width: 18, height: 18, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Next Step',
                                style: AppTextStyles.label.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                    ),
                ],
              ),
            ),
          ] else ...[
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () async {
                  if (!_isAllAnswered(quizList)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please answer all questions before submitting.'),
                        backgroundColor: AppColors.accentRose,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  } else {
                    setState(() {
                      _isSubmitting = true;
                    });
                    
                    // Format answers map for API: Map<int, String>
                    final Map<int, String> formattedAnswers = {};
                    for (int i = 0; i < quizList.length; i++) {
                      final qData = quizList[i] is Map ? (quizList[i] as Map<String, dynamic>) : <String, dynamic>{};
                      if (_isFillInTheBlank(qData)) {
                        formattedAnswers[i] = _textAnswers[i] ?? '';
                      } else {
                        final options = (qData['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
                        final selectedIndex = _selectedAnswers[i];
                        if (selectedIndex != null && selectedIndex < options.length) {
                          formattedAnswers[i] = options[selectedIndex];
                        }
                      }
                    }
                    
                    await ref.read(activeSessionProvider.notifier).submitStepQuiz(
                      widget.stepIndex,
                      formattedAnswers,
                    );
                    
                    if (mounted) {
                      setState(() {
                        _submitted = true;
                        _isSubmitting = false;
                      });
                      widget.onQuizSubmitted?.call();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rose,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const SizedBox(
                      width: 20, height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : Text(
                      'Submit Quiz',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
