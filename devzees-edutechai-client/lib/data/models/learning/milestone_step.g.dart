// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MilestoneStep _$MilestoneStepFromJson(Map<String, dynamic> json) =>
    _MilestoneStep(
      index: (json['index'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      isPrerequisite: json['is_prerequisite'] as bool? ?? false,
      prerequisite: json['prerequisite'] as String?,
      status: json['status'] as String? ?? 'pending',
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 5,
      tutorExplanation: json['tutor_explanation'] as String?,
      socraticQuestions: json['socratic_questions'] as List<dynamic>?,
      conversationHistory: json['conversation_history'] as List<dynamic>?,
      quiz: json['quiz'] as List<dynamic>?,
      quizScore: (json['quiz_score'] as num?)?.toDouble(),
      userAnswers: json['user_answers'] as Map<String, dynamic>?,
      userFullAnswers: json['user_full_answers'] as Map<String, dynamic>?,
      videos: json['videos'] as List<dynamic>?,
      papers: json['papers'] as List<dynamic>?,
    );

Map<String, dynamic> _$MilestoneStepToJson(_MilestoneStep instance) =>
    <String, dynamic>{
      'index': instance.index,
      'title': instance.title,
      'description': instance.description,
      'is_prerequisite': instance.isPrerequisite,
      'prerequisite': instance.prerequisite,
      'status': instance.status,
      'estimated_minutes': instance.estimatedMinutes,
      'tutor_explanation': instance.tutorExplanation,
      'socratic_questions': instance.socraticQuestions,
      'conversation_history': instance.conversationHistory,
      'quiz': instance.quiz,
      'quiz_score': instance.quizScore,
      'user_answers': instance.userAnswers,
      'user_full_answers': instance.userFullAnswers,
      'videos': instance.videos,
      'papers': instance.papers,
    };
