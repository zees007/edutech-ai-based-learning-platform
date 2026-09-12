import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/providers/active_session_provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/text_styles.dart';
import '../../../../../../data/models/learning/quiz_result.dart';

/// Redesigned Knowledge Check Quiz matching the EduTech AI dark glassmorphic theme.
/// Features discrete question cards, animated option tiles, live progress tracking,
/// terminal-style fill-in-the-blank inputs, and gamified XP completion rewards.
class KnowledgeCheckQuiz extends ConsumerStatefulWidget {
  final List<dynamic>? quiz;
  final Future<void> Function()? onNextStep;
  final int stepIndex;
  final VoidCallback? onQuizSubmitted;
  final dynamic step;

  const KnowledgeCheckQuiz({
    super.key,
    this.quiz,
    this.onNextStep,
    required this.stepIndex,
    this.onQuizSubmitted,
    this.step,
  });

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
  QuizResult? _quizResult;

  @override
  void initState() {
    super.initState();
    _initFromStep();
  }

  @override
  void didUpdateWidget(covariant KnowledgeCheckQuiz oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepIndex != widget.stepIndex || oldWidget.step != widget.step) {
      _initFromStep(forceReset: oldWidget.stepIndex != widget.stepIndex);
    }
  }

  void _initFromStep({bool forceReset = false}) {
    if (forceReset) {
      _submitted = false;
      _selectedAnswers.clear();
      _textAnswers.clear();
      _quizResult = null;
    }

    dynamic step = widget.step;
    final sessionStep = _findStepFromSession();
    if (sessionStep != null) {
      if (step == null ||
          (step.quizScore == null && sessionStep.quizScore != null) ||
          ((step.userAnswers == null || (step.userAnswers as Map).isEmpty) &&
              sessionStep.userAnswers != null &&
              (sessionStep.userAnswers as Map).isNotEmpty)) {
        step = sessionStep;
      }
    }
    if (step == null) return;

    final bool hasScore = step.quizScore != null;
    final bool hasUserAnswers = step.userAnswers != null &&
        step.userAnswers is Map &&
        (step.userAnswers as Map).isNotEmpty;
    final bool hasUserFullAnswers = step.userFullAnswers != null &&
        step.userFullAnswers is Map &&
        (step.userFullAnswers as Map).isNotEmpty;

    if (!hasScore && !hasUserAnswers && !hasUserFullAnswers) {
      if (_submitted) {
        setState(() {
          _submitted = false;
          _selectedAnswers.clear();
          _textAnswers.clear();
          _quizResult = null;
        });
      }
      return;
    }

    _submitted = true;

    // Clear stale answers before populating this step's answers.
    _selectedAnswers.clear();
    _textAnswers.clear();

    final Map answers = hasUserFullAnswers
        ? (step.userFullAnswers as Map)
        : (hasUserAnswers ? (step.userAnswers as Map) : {});

    final quizList = (widget.quiz != null && widget.quiz!.isNotEmpty)
        ? widget.quiz!
        : ((step.quiz is List) ? (step.quiz as List) : <dynamic>[]);

    for (int i = 0; i < quizList.length; i++) {
      final qData = quizList[i] is Map
          ? (quizList[i] as Map<String, dynamic>)
          : <String, dynamic>{};
      // Support both integer keys and string keys (e.g. 0 and "0")
      final rawAns = answers[i.toString()] ?? answers[i];
      if (rawAns != null) {
        final ansStr = rawAns.toString().trim();
        if (_isFillInTheBlank(qData)) {
          _textAnswers[i] = ansStr;
          _getController(i).text = ansStr;
        } else {
          final options = (qData['options'] as List?)
                  ?.map((e) => (e is Map ? (e['text'] ?? e['option'] ?? e.toString()) : e).toString())
                  .toList() ??
              [];
          // Try exact full-string match first
          int matchIndex = options.indexWhere((opt) => opt.trim() == ansStr);
          // Fallback: match by option key letter (A, B, C, D) or containment
          if (matchIndex == -1) {
            matchIndex = options.indexWhere((opt) {
              final key = opt
                  .split(':')
                  .first
                  .split(')')
                  .first
                  .split('.')
                  .first
                  .trim()
                  .toUpperCase();
              return key == ansStr.toUpperCase() ||
                  opt.toUpperCase().contains(ansStr.toUpperCase());
            });
          }
          // Fallback: try matching by option index (e.g. answer stored as "0", "1")
          if (matchIndex == -1) {
            final parsedIndex = int.tryParse(ansStr);
            if (parsedIndex != null && parsedIndex >= 0 && parsedIndex < options.length) {
              matchIndex = parsedIndex;
            }
          }
          if (matchIndex != -1) {
            _selectedAnswers[i] = matchIndex;
          }
        }
      }
    }
  }

  dynamic _findStepFromSession() {
    try {
      final session = ref.read(activeSessionProvider).session;
      if (session != null &&
          widget.stepIndex >= 0 &&
          widget.stepIndex < session.steps.length) {
        return session.steps[widget.stepIndex];
      }
    } catch (_) {}
    return null;
  }

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

  (String letter, String text) _parseOption(String rawOption, int optIndex) {
    final defaultLetter = String.fromCharCode(65 + optIndex);
    final trimmed = rawOption.trim();
    final match = RegExp(r'^([A-Za-z])[\:\)\.]\s*(.*)$').firstMatch(trimmed);
    if (match != null) {
      final letter = match.group(1)!.toUpperCase();
      final text = match.group(2)!.trim();
      return (letter, text.isNotEmpty ? text : trimmed);
    }
    return (defaultLetter, trimmed);
  }

  bool _isQuestionCorrect(int questionIndex, Map<String, dynamic> qData) {
    if (_quizResult != null && _quizResult!.feedback.isNotEmpty) {
      final fb = _quizResult!.feedback.firstWhere(
        (f) => f.questionIndex == questionIndex,
        orElse: () => const QuestionFeedback(
          questionIndex: -1,
          isCorrect: false,
          studentAnswer: '',
          correctAnswer: '',
          explanation: '',
        ),
      );
      if (fb.questionIndex == questionIndex) {
        return fb.isCorrect;
      }
    }

    final correctRaw = (qData['correct_option'] ??
            qData['correct_answer'] ??
            '')
        .toString()
        .trim();
    final correctUpper = correctRaw.toUpperCase();

    if (_isFillInTheBlank(qData)) {
      final userAnswer = (_textAnswers[questionIndex] ?? '').trim();
      if (userAnswer.isEmpty) {
        return false;
      }
      final userUpper = userAnswer.toUpperCase();
      if (userUpper == correctUpper) {
        return true;
      }
      if (correctUpper.isNotEmpty && userUpper.contains(correctUpper)) {
        return true;
      }
      if (userUpper.isNotEmpty &&
          correctUpper.contains(userUpper) &&
          userUpper.length >= 3) {
        return true;
      }
      return false;
    } else {
      final selectedOptionIndex = _selectedAnswers[questionIndex];
      if (selectedOptionIndex == null) {
        return false;
      }
      final options = (qData['options'] as List?)
              ?.map((e) => (e is Map ? (e['text'] ?? e['option'] ?? e.toString()) : e).toString())
              .toList() ??
          [];
      if (selectedOptionIndex < 0 || selectedOptionIndex >= options.length) {
        return false;
      }

      final selectedFull = options[selectedOptionIndex];
      final selectedKey = selectedFull
          .split(':')
          .first
          .split(')')
          .first
          .split('.')
          .first
          .trim()
          .toUpperCase();

      if (selectedKey == correctUpper) {
        return true;
      }
      final correctKey = correctUpper
          .split(':')
          .first
          .split(')')
          .first
          .split('.')
          .first
          .trim();
      if (correctKey.isNotEmpty && correctKey == selectedKey) {
        return true;
      }
      if (correctUpper.length > 1 &&
          selectedFull.toUpperCase().contains(correctUpper)) {
        return true;
      }
      return false;
    }
  }

  int _getAnsweredCount(List<dynamic> quizList) {
    int count = 0;
    for (int i = 0; i < quizList.length; i++) {
      final qData = quizList[i] is Map
          ? (quizList[i] as Map<String, dynamic>)
          : <String, dynamic>{};
      if (_isFillInTheBlank(qData)) {
        if ((_textAnswers[i]?.trim().isNotEmpty ?? false)) {
          count++;
        }
      } else {
        if (_selectedAnswers.containsKey(i)) {
          count++;
        }
      }
    }
    return count;
  }

  bool _isAllAnswered(List<dynamic> quizList) {
    return _getAnsweredCount(quizList) >= quizList.length;
  }

  Future<void> _handleSubmit(List<dynamic> quizList) async {
    if (!_isAllAnswered(quizList)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please answer all questions before submitting.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.accentAmber,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final Map<int, String> formattedAnswers = {};
    for (int i = 0; i < quizList.length; i++) {
      final qData = quizList[i] is Map
          ? (quizList[i] as Map<String, dynamic>)
          : <String, dynamic>{};
      if (_isFillInTheBlank(qData)) {
        formattedAnswers[i] = _textAnswers[i] ?? '';
      } else {
        final options =
            (qData['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final selectedIndex = _selectedAnswers[i];
        if (selectedIndex != null && selectedIndex < options.length) {
          formattedAnswers[i] = options[selectedIndex];
        }
      }
    }

    final result = await ref
        .read(activeSessionProvider.notifier)
        .submitStepQuiz(widget.stepIndex, formattedAnswers);

    if (mounted) {
      setState(() {
        _submitted = true;
        _isSubmitting = false;
        _quizResult = result;
      });
      widget.onQuizSubmitted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic step = widget.step;
    final sessionStep = _findStepFromSession();
    if (sessionStep != null) {
      if (step == null ||
          (step.quizScore == null && sessionStep.quizScore != null) ||
          ((step.userAnswers == null || (step.userAnswers as Map).isEmpty) &&
              sessionStep.userAnswers != null &&
              (sessionStep.userAnswers as Map).isNotEmpty)) {
        step = sessionStep;
      }
    }

    final quizList = (widget.quiz != null && widget.quiz!.isNotEmpty)
        ? widget.quiz!
        : ((step?.quiz is List) ? (step!.quiz as List) : <dynamic>[]);

    if (quizList.isEmpty) {
      return const SizedBox.shrink();
    }

    // Auto-sync submission status if step has quiz score or answers but _submitted is false
    final bool stepHasQuiz = step != null &&
        (step.quizScore != null ||
            (step.userAnswers != null &&
                step.userAnswers is Map &&
                (step.userAnswers as Map).isNotEmpty) ||
            (step.userFullAnswers != null &&
                step.userFullAnswers is Map &&
                (step.userFullAnswers as Map).isNotEmpty));
    if (!_submitted && stepHasQuiz) {
      _submitted = true;
      if (_selectedAnswers.isEmpty && _textAnswers.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _initFromStep();
        });
      }
    }

    final totalQuestions = quizList.length;
    final answeredCount = _getAnsweredCount(quizList);
    final isAllAnswered = answeredCount >= totalQuestions;

    int correctCount = 0;
    if (_submitted) {
      for (int i = 0; i < totalQuestions; i++) {
        final qData = quizList[i] is Map
            ? (quizList[i] as Map<String, dynamic>)
            : <String, dynamic>{};
        if (_isQuestionCorrect(i, qData)) {
          correctCount++;
        }
      }
    }

    // Safety fallback: if submitted and server has a quizScore, but client-side matching yielded 0
    if (_submitted && correctCount == 0 && step?.quizScore != null && step!.quizScore! > 0) {
      correctCount = (step.quizScore! * totalQuestions).round();
    }

    final double scoreRatio = totalQuestions > 0
        ? (step?.quizScore ?? (correctCount / totalQuestions))
        : 0.0;
    final int scorePct = (scoreRatio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Header & Progress Banner ───
        _buildHeader(totalQuestions, answeredCount, isAllAnswered, scorePct),

        const SizedBox(height: 18),

        // ─── Individual Question Cards ───
        ...List.generate(totalQuestions, (index) {
          final quizData = quizList[index] is Map
              ? (quizList[index] as Map<String, dynamic>)
              : <String, dynamic>{};
          return _buildQuestionCard(index, quizData, totalQuestions);
        }),

        const SizedBox(height: 12),

        // ─── Gamified Results Card or Submit Action ───
        if (_submitted)
          _buildResultsSummaryCard(quizList, correctCount, scorePct)
        else
          _buildSubmitActionRow(quizList, isAllAnswered),
      ],
    );
  }

  Widget _buildHeader(
      int totalQuestions, int answeredCount, bool isAllAnswered, int scorePct) {
    final double progressFraction =
        totalQuestions > 0 ? (answeredCount / totalQuestions).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _submitted
              ? AppColors.accentGreen.withValues(alpha: 0.3)
              : AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Themed Quiz Icon Badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _submitted
                          ? AppColors.accentGreen.withValues(alpha: 0.25)
                          : AppColors.primary.withValues(alpha: 0.25),
                      _submitted
                          ? AppColors.emerald.withValues(alpha: 0.15)
                          : AppColors.purpleDeep.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _submitted
                        ? AppColors.accentGreen.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  _submitted ? Icons.verified_rounded : Icons.quiz_rounded,
                  color: _submitted ? AppColors.accentGreen : AppColors.purpleLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Milestone Knowledge Check',
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _submitted
                          ? 'Step knowledge verified • Review explanations below'
                          : 'Test your grasp of this milestone to proceed',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Status / Count Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _submitted
                      ? AppColors.accentGreen.withValues(alpha: 0.12)
                      : (isAllAnswered
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.accentAmber.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _submitted
                        ? AppColors.accentGreen.withValues(alpha: 0.35)
                        : (isAllAnswered
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.accentAmber.withValues(alpha: 0.35)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _submitted
                          ? Icons.check_circle_rounded
                          : (isAllAnswered
                              ? Icons.task_alt_rounded
                              : Icons.schedule_rounded),
                      size: 13,
                      color: _submitted
                          ? AppColors.accentGreen
                          : (isAllAnswered
                              ? AppColors.purpleLight
                              : AppColors.accentAmber),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _submitted
                          ? '$scorePct% Score'
                          : '$answeredCount of $totalQuestions Answered',
                      style: AppTextStyles.badge.copyWith(
                        color: _submitted
                            ? AppColors.accentGreen
                            : (isAllAnswered
                                ? AppColors.purpleLight
                                : AppColors.accentAmber),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_submitted) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressFraction,
                minHeight: 4,
                backgroundColor: AppColors.surfaceMid.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isAllAnswered ? AppColors.accentGreen : AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
      int index, Map<String, dynamic> quizData, int totalQuestions) {
    final question =
        quizData['question']?.toString() ?? 'Question ${index + 1}';
    final isFillBlank = _isFillInTheBlank(quizData);
    final List<String> options = quizData['options'] is List
        ? (quizData['options'] as List).map((e) => e.toString()).toList()
        : [];
    final explanation = quizData['explanation']?.toString() ?? '';
    final correctAnswerRaw = quizData['correct_option']?.toString() ??
        quizData['correct_answer']?.toString() ??
        '';

    final bool isCorrect =
        _submitted ? _isQuestionCorrect(index, quizData) : false;

    final bool isCardAnswered = isFillBlank
        ? (_textAnswers[index]?.trim().isNotEmpty ?? false)
        : _selectedAnswers.containsKey(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _submitted
              ? (isCorrect
                  ? AppColors.accentGreen.withValues(alpha: 0.4)
                  : AppColors.accentRose.withValues(alpha: 0.35))
              : (isCardAnswered
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.glassBorder),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Question Metadata Row ───
          Row(
            children: [
              // Question Number Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: AppTextStyles.captionBold.copyWith(
                    color: AppColors.purpleLight,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Question Type Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.glassSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.glassBorderSubtle,
                  ),
                ),
                child: Text(
                  isFillBlank ? 'Fill in the Blank' : 'Multiple Choice',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSubtle,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),

              // Status Pill
              if (_submitted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppColors.accentGreen.withValues(alpha: 0.12)
                        : AppColors.accentRose.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCorrect
                          ? AppColors.accentGreen.withValues(alpha: 0.35)
                          : AppColors.accentRose.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 13,
                        color: isCorrect
                            ? AppColors.accentGreen
                            : AppColors.accentRose,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isCorrect ? 'Correct' : 'Needs Review',
                        style: AppTextStyles.captionBold.copyWith(
                          color: isCorrect
                              ? AppColors.accentGreen
                              : AppColors.accentRose,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCardAnswered
                        ? AppColors.accentGreen.withValues(alpha: 0.1)
                        : AppColors.surfaceMid.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCardAnswered
                          ? AppColors.accentGreen.withValues(alpha: 0.3)
                          : AppColors.glassBorderSubtle,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCardAnswered
                            ? Icons.check_rounded
                            : Icons.circle_outlined,
                        size: 11,
                        color: isCardAnswered
                            ? AppColors.accentGreen
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCardAnswered ? 'Answered' : 'Pending',
                        style: AppTextStyles.caption.copyWith(
                          color: isCardAnswered
                              ? AppColors.accentGreen
                              : AppColors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // ─── Question Prompt ───
          Text(
            question,
            style: AppTextStyles.subtitle2.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // ─── Options or Fill in Blank ───
          if (isFillBlank) ...[
            _buildFillInTheBlankInput(index, isCorrect)
          ] else ...[
            ...List.generate(options.length, (optIndex) {
              return _OptionTile(
                optIndex: optIndex,
                rawOption: options[optIndex],
                isSelected: _selectedAnswers[index] == optIndex,
                isSubmitted: _submitted,
                correctAnswerRaw: correctAnswerRaw,
                onTap: _submitted
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswers[index] = optIndex;
                        });
                      },
                parseOption: _parseOption,
              );
            }),
          ],

          // ─── Post-Submission Feedback & Explanation ───
          if (_submitted) ...[
            const SizedBox(height: 14),
            _buildExplanationCard(isCorrect, correctAnswerRaw, explanation),
          ],
        ],
      ),
    );
  }

  Widget _buildFillInTheBlankInput(int index, bool isCorrect) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMid.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _submitted
              ? (isCorrect ? AppColors.accentGreen : AppColors.accentRose)
              : (_textAnswers[index]?.trim().isNotEmpty ?? false
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.glassBorder),
          width: _submitted ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: _getController(index),
        enabled: !_submitted,
        style: AppTextStyles.bodyPrimary.copyWith(fontSize: 13.5),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Type your answer here...',
          hintStyle: AppTextStyles.bodyPrimary.copyWith(
            color: AppColors.textMuted,
            fontSize: 13.5,
          ),
          icon: Icon(
            Icons.edit_note_rounded,
            color: _submitted
                ? (isCorrect ? AppColors.accentGreen : AppColors.accentRose)
                : AppColors.primary,
            size: 20,
          ),
          suffixIcon: _submitted
              ? Icon(
                  isCorrect
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: isCorrect
                      ? AppColors.accentGreen
                      : AppColors.accentRose,
                  size: 20,
                )
              : (_textAnswers[index]?.trim().isNotEmpty ?? false
                  ? const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.accentGreen,
                      size: 18,
                    )
                  : null),
        ),
        onChanged: (val) {
          setState(() {
            _textAnswers[index] = val;
          });
        },
      ),
    );
  }

  Widget _buildExplanationCard(
      bool isCorrect, String correctAnswerRaw, String explanation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isCorrect ? AppColors.accentGreen : AppColors.accentRose)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isCorrect ? AppColors.accentGreen : AppColors.accentRose)
              .withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle_outline_rounded
                    : Icons.lightbulb_outline_rounded,
                color: isCorrect ? AppColors.accentGreen : AppColors.accentAmber,
                size: 17,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct Insight' : 'Key Explanation',
                style: AppTextStyles.captionBold.copyWith(
                  color: isCorrect ? AppColors.accentGreen : AppColors.accentAmber,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (!isCorrect && correctAnswerRaw.isNotEmpty) ...[
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                text: 'Correct answer: ',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: correctAnswerRaw,
                    style: AppTextStyles.captionBold.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              explanation,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSummaryCard(
      List<dynamic> quizList, int correctCount, int scorePct) {
    // According to Gamification specification:
    // - 20 XP per correct question
    // - +30 XP bonus strictly for 100% accuracy
    final int baseQuizXp = correctCount * 20;
    final int bonusXp = (correctCount == quizList.length && quizList.isNotEmpty) ? 30 : 0;
    final int fallbackXp = baseQuizXp + bonusXp;
    final int xpEarned = _quizResult?.xpEarned ?? fallbackXp;

    final bool isPassed = scorePct >= 70;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceDark.withValues(alpha: 0.95),
            AppColors.surfaceDeep.withValues(alpha: 0.90),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPassed
              ? AppColors.accentGreen.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPassed ? AppColors.accentGreen : AppColors.primary)
                .withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Radial / Circular Score Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isPassed
                      ? AppColors.accentGreen.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPassed
                        ? AppColors.accentGreen
                        : AppColors.purpleLight,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$scorePct%',
                    style: AppTextStyles.captionBold.copyWith(
                      color: isPassed
                          ? AppColors.accentGreen
                          : AppColors.purpleLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPassed
                          ? 'Milestone Mastered! 🏆'
                          : 'Milestone Knowledge Check Completed 📝',
                      style: AppTextStyles.h4.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$correctCount of ${quizList.length} questions correct.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // XP Reward Badge
              if (xpEarned > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentAmber.withValues(alpha: 0.25),
                        AppColors.amberDeep.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.accentAmber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.accentAmber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+$xpEarned XP',
                        style: AppTextStyles.captionBold.copyWith(
                          color: AppColors.accentAmber,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (widget.onNextStep != null) ...[
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _isAdvancing
                      ? null
                      : () async {
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isPassed
                          ? const LinearGradient(
                              colors: [
                                AppColors.accentGreen,
                                AppColors.greenDeep,
                              ],
                            )
                          : AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (isPassed
                                  ? AppColors.accentGreen
                                  : AppColors.primary)
                              .withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isAdvancing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Next Step',
                                style: AppTextStyles.badge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitActionRow(List<dynamic> quizList, bool isAllAnswered) {
    return Align(
      alignment: Alignment.centerRight,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _isSubmitting ? null : () => _handleSubmit(quizList),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            decoration: BoxDecoration(
              gradient: isAllAnswered
                  ? AppColors.primaryGradient
                  : LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.6),
                        AppColors.purpleDeep.withValues(alpha: 0.6),
                      ],
                    ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary
                      .withValues(alpha: isAllAnswered ? 0.35 : 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSubmitting) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else ...[
                  const Icon(
                    Icons.send_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _isSubmitting ? 'Evaluating...' : 'Submit Answers',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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

/// Interactive multiple choice option tile with tactile desktop hover and selection effects.
class _OptionTile extends StatefulWidget {
  final int optIndex;
  final String rawOption;
  final bool isSelected;
  final bool isSubmitted;
  final String correctAnswerRaw;
  final VoidCallback? onTap;
  final (String, String) Function(String, int) parseOption;

  const _OptionTile({
    required this.optIndex,
    required this.rawOption,
    required this.isSelected,
    required this.isSubmitted,
    required this.correctAnswerRaw,
    required this.onTap,
    required this.parseOption,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final parsed = widget.parseOption(widget.rawOption, widget.optIndex);
    final letter = parsed.$1;
    final text = parsed.$2;

    bool isThisOptionCorrect = false;
    if (widget.isSubmitted) {
      final correctUpper = widget.correctAnswerRaw.trim().toUpperCase();
      final optUpper = widget.rawOption.trim().toUpperCase();
      final correctKey = correctUpper
          .split(':')
          .first
          .split(')')
          .first
          .split('.')
          .first
          .trim();
      if (letter == correctUpper ||
          (correctKey.isNotEmpty && letter == correctKey) ||
          (correctUpper.length > 1 && optUpper.contains(correctUpper))) {
        isThisOptionCorrect = true;
      }
    }

    Color bgColor = AppColors.glassSurface.withValues(alpha: 0.04);
    Color borderColor = AppColors.glassBorder;
    Color letterBg = AppColors.surfaceMid.withValues(alpha: 0.6);
    Color letterTextColor = AppColors.textSecondary;
    IconData? trailingIcon;
    Color? trailingIconColor;

    if (widget.isSelected) {
      bgColor = AppColors.primary.withValues(alpha: 0.15);
      borderColor = AppColors.primary;
      letterBg = AppColors.primary;
      letterTextColor = Colors.white;
      trailingIcon = Icons.check_circle_rounded;
      trailingIconColor = AppColors.purpleLight;
    }

    if (widget.isSubmitted) {
      if (isThisOptionCorrect) {
        bgColor = AppColors.accentGreen.withValues(alpha: 0.15);
        borderColor = AppColors.accentGreen;
        letterBg = AppColors.accentGreen;
        letterTextColor = Colors.white;
        trailingIcon = Icons.check_circle_rounded;
        trailingIconColor = AppColors.accentGreen;
      } else if (widget.isSelected && !isThisOptionCorrect) {
        bgColor = AppColors.accentRose.withValues(alpha: 0.15);
        borderColor = AppColors.accentRose;
        letterBg = AppColors.accentRose;
        letterTextColor = Colors.white;
        trailingIcon = Icons.cancel_rounded;
        trailingIconColor = AppColors.accentRose;
      }
    } else if (_isHovered && !widget.isSelected) {
      bgColor = AppColors.primary.withValues(alpha: 0.07);
      borderColor = AppColors.primary.withValues(alpha: 0.4);
    }

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: (widget.isSelected ||
                      (widget.isSubmitted &&
                          (isThisOptionCorrect || widget.isSelected)))
                  ? 1.5
                  : 1.0,
            ),
            boxShadow: widget.isSelected && !widget.isSubmitted
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Option Letter Badge (A, B, C, D)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: letterBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isSelected ||
                            (widget.isSubmitted &&
                                (isThisOptionCorrect || widget.isSelected))
                        ? Colors.transparent
                        : AppColors.glassBorderSubtle,
                  ),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: letterTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Option Text
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.body2.copyWith(
                    color: widget.isSelected ||
                            (widget.isSubmitted && isThisOptionCorrect)
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: widget.isSelected ||
                            (widget.isSubmitted && isThisOptionCorrect)
                        ? FontWeight.w600
                        : FontWeight.w400,
                    fontSize: 13.5,
                  ),
                ),
              ),
              // Trailing Indicator
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  trailingIcon,
                  size: 18,
                  color: trailingIconColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
