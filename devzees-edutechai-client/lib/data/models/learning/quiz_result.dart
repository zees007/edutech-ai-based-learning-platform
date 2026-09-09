import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_result.freezed.dart';
part 'quiz_result.g.dart';

@freezed
abstract class QuizResult with _$QuizResult {
  const factory QuizResult({
    required int stepIndex,
    required int totalQuestions,
    required int correctCount,
    required double score,
    required int xpEarned,
    required List<QuestionFeedback> feedback,
  }) = _QuizResult;

  factory QuizResult.fromJson(Map<String, dynamic> json) =>
      _$QuizResultFromJson(json);
}

@freezed
abstract class QuestionFeedback with _$QuestionFeedback {
  const factory QuestionFeedback({
    required int questionIndex,
    required bool isCorrect,
    required String studentAnswer,
    required String correctAnswer,
    required String explanation,
  }) = _QuestionFeedback;

  factory QuestionFeedback.fromJson(Map<String, dynamic> json) =>
      _$QuestionFeedbackFromJson(json);
}
