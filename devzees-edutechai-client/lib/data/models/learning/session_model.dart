import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

@freezed
abstract class SessionModel with _$SessionModel {
  const factory SessionModel({
    @JsonKey(name: 'session_id') required String sessionId,
    required String topic,
    @JsonKey(name: 'learning_mode') required String learningMode,
    @JsonKey(name: 'student_level') required String studentLevel,
    @JsonKey(name: 'is_complete') required bool isComplete,
    @JsonKey(name: 'completed_steps') required int stepsCompleted,
    @JsonKey(name: 'xp_earned') required int xpEarned,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);
}

@freezed
abstract class PaginatedSessionResponse with _$PaginatedSessionResponse {
  const factory PaginatedSessionResponse({
    required List<SessionModel> items,
    required int total,
    required int page,
    required int size,
  }) = _PaginatedSessionResponse;

  factory PaginatedSessionResponse.fromJson(Map<String, dynamic> json) => _$PaginatedSessionResponseFromJson(json);
}
