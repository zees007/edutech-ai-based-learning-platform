import 'package:freezed_annotation/freezed_annotation.dart';

part 'milestone_step.freezed.dart';
part 'milestone_step.g.dart';

@freezed
abstract class MilestoneStep with _$MilestoneStep {
  const factory MilestoneStep({
    required int index,
    required String title,
    required String description,
    @JsonKey(name: 'is_prerequisite') @Default(false) bool isPrerequisite,
    String? prerequisite,
    @Default('pending') String status, // 'pending', 'in_progress', 'complete'
    @JsonKey(name: 'estimated_minutes') @Default(5) int estimatedMinutes,
    
    // Dynamic payload fields
    @JsonKey(name: 'tutor_explanation') String? tutorExplanation,
    @JsonKey(name: 'socratic_questions') List<dynamic>? socraticQuestions,
    List<dynamic>? quiz,
    @JsonKey(name: 'quiz_score') double? quizScore,
    @JsonKey(name: 'user_answers') Map<String, dynamic>? userAnswers,
    @JsonKey(name: 'user_full_answers') Map<String, dynamic>? userFullAnswers,
    List<dynamic>? videos,
    List<dynamic>? papers,
  }) = _MilestoneStep;

  factory MilestoneStep.fromJson(Map<String, dynamic> json) => _$MilestoneStepFromJson(json);
}
