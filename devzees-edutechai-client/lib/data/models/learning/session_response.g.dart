// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionResponse _$SessionResponseFromJson(Map<String, dynamic> json) =>
    _SessionResponse(
      sessionId: json['session_id'] as String,
      topic: json['topic'] as String,
      learningMode: json['learning_mode'] as String,
      studentLevel: json['student_level'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      steps:
          (json['steps'] as List<dynamic>?)
              ?.map((e) => MilestoneStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentStepIndex: (json['current_step_index'] as num?)?.toInt() ?? 0,
      xpEarned: (json['xp_earned'] as num?)?.toInt() ?? 0,
      stepsCompleted: (json['steps_completed'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SessionResponseToJson(_SessionResponse instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'topic': instance.topic,
      'learning_mode': instance.learningMode,
      'student_level': instance.studentLevel,
      'created_at': instance.createdAt.toIso8601String(),
      'steps': instance.steps,
      'current_step_index': instance.currentStepIndex,
      'xp_earned': instance.xpEarned,
      'steps_completed': instance.stepsCompleted,
    };
