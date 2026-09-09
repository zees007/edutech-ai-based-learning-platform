// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuizResult _$QuizResultFromJson(Map<String, dynamic> json) => _QuizResult(
  stepIndex: (json['stepIndex'] as num).toInt(),
  totalQuestions: (json['totalQuestions'] as num).toInt(),
  correctCount: (json['correctCount'] as num).toInt(),
  score: (json['score'] as num).toDouble(),
  xpEarned: (json['xpEarned'] as num).toInt(),
  feedback: (json['feedback'] as List<dynamic>)
      .map((e) => QuestionFeedback.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QuizResultToJson(_QuizResult instance) =>
    <String, dynamic>{
      'stepIndex': instance.stepIndex,
      'totalQuestions': instance.totalQuestions,
      'correctCount': instance.correctCount,
      'score': instance.score,
      'xpEarned': instance.xpEarned,
      'feedback': instance.feedback,
    };

_QuestionFeedback _$QuestionFeedbackFromJson(Map<String, dynamic> json) =>
    _QuestionFeedback(
      questionIndex: (json['questionIndex'] as num).toInt(),
      isCorrect: json['isCorrect'] as bool,
      studentAnswer: json['studentAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
    );

Map<String, dynamic> _$QuestionFeedbackToJson(_QuestionFeedback instance) =>
    <String, dynamic>{
      'questionIndex': instance.questionIndex,
      'isCorrect': instance.isCorrect,
      'studentAnswer': instance.studentAnswer,
      'correctAnswer': instance.correctAnswer,
      'explanation': instance.explanation,
    };
