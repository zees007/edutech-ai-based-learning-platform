import 'package:freezed_annotation/freezed_annotation.dart';
import 'milestone_step.dart';

part 'session_response.freezed.dart';
part 'session_response.g.dart';

@freezed
abstract class SessionResponse with _$SessionResponse {
  const factory SessionResponse({
    @JsonKey(name: 'session_id') required String sessionId,
    required String topic,
    @JsonKey(name: 'learning_mode') required String learningMode,
    @JsonKey(name: 'student_level') required String studentLevel,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default([]) List<MilestoneStep> steps,
    @JsonKey(name: 'current_step_index') @Default(0) int currentStepIndex,
    @JsonKey(name: 'xp_earned') @Default(0) int xpEarned,
    @JsonKey(name: 'steps_completed') @Default(0) int stepsCompleted,
    @JsonKey(name: 'conversation_history') List<dynamic>? conversationHistory,
  }) = _SessionResponse;

  factory SessionResponse.fromJson(Map<String, dynamic> json) => _$SessionResponseFromJson(json);
}
