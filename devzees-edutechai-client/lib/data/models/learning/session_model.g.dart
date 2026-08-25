// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionModel _$SessionModelFromJson(Map<String, dynamic> json) =>
    _SessionModel(
      sessionId: json['session_id'] as String,
      topic: json['topic'] as String,
      learningMode: json['learning_mode'] as String,
      studentLevel: json['student_level'] as String,
      isComplete: json['is_complete'] as bool,
      stepsCompleted: (json['completed_steps'] as num).toInt(),
      xpEarned: (json['xp_earned'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SessionModelToJson(_SessionModel instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'topic': instance.topic,
      'learning_mode': instance.learningMode,
      'student_level': instance.studentLevel,
      'is_complete': instance.isComplete,
      'completed_steps': instance.stepsCompleted,
      'xp_earned': instance.xpEarned,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_PaginatedSessionResponse _$PaginatedSessionResponseFromJson(
  Map<String, dynamic> json,
) => _PaginatedSessionResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$PaginatedSessionResponseToJson(
  _PaginatedSessionResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'page': instance.page,
  'size': instance.size,
};
