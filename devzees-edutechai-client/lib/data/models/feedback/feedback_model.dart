import 'package:flutter/material.dart';

class FeedbackSubmissionResponse {
  final String feedbackId;
  final String sessionId;
  final int xpAwarded;
  final int totalXp;
  final int level;
  final String levelTitle;
  final bool leveledUp;
  final String message;

  const FeedbackSubmissionResponse({
    required this.feedbackId,
    required this.sessionId,
    required this.xpAwarded,
    required this.totalXp,
    required this.level,
    required this.levelTitle,
    required this.leveledUp,
    required this.message,
  });

  factory FeedbackSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackSubmissionResponse(
      feedbackId: json['feedback_id'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      xpAwarded: json['xp_awarded'] as int? ?? 0,
      totalXp: json['total_xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      levelTitle: json['level_title'] as String? ?? '',
      leveledUp: json['leveled_up'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

class PublicFeedbackModel {
  final String feedbackId;
  final String name;
  final String educationLevel;
  final String? country;
  final int rating;
  final String quote;
  final String topicTag;
  final String avatarInitial;
  final Color avatarColor;
  final DateTime? createdAt;

  const PublicFeedbackModel({
    required this.feedbackId,
    required this.name,
    required this.educationLevel,
    this.country,
    required this.rating,
    required this.quote,
    required this.topicTag,
    required this.avatarInitial,
    required this.avatarColor,
    this.createdAt,
  });

  factory PublicFeedbackModel.fromJson(Map<String, dynamic> json) {
    Color parseColor(String? hexString) {
      if (hexString == null || hexString.isEmpty) return const Color(0xFF2B68F6);
      try {
        final clean = hexString.replaceAll('#', '');
        return Color(int.parse('FF$clean', radix: 16));
      } catch (_) {
        return const Color(0xFF2B68F6);
      }
    }

    return PublicFeedbackModel(
      feedbackId: json['feedback_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Anonymous Learner',
      educationLevel: json['education_level'] as String? ?? 'Undergraduate',
      country: json['country'] as String?,
      rating: json['rating'] as int? ?? 5,
      quote: json['quote'] as String? ?? '',
      topicTag: json['topic_tag'] as String? ?? 'STEM Topic',
      avatarInitial: json['avatar_initial'] as String? ?? 'ET',
      avatarColor: parseColor(json['avatar_color'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class AdminFeedbackModel {
  final int id;
  final String feedbackId;
  final String sessionId;
  final String userId;
  final String userName;
  final String userEmail;
  final String educationLevel;
  final String? country;
  final int rating;
  final String quote;
  final String topicTag;
  final bool isPublicConsent;
  final String status;
  final String? adminNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminFeedbackModel({
    required this.id,
    required this.feedbackId,
    required this.sessionId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.educationLevel,
    this.country,
    required this.rating,
    required this.quote,
    required this.topicTag,
    required this.isPublicConsent,
    required this.status,
    this.adminNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminFeedbackModel.fromJson(Map<String, dynamic> json) {
    return AdminFeedbackModel(
      id: json['id'] as int? ?? 0,
      feedbackId: json['feedback_id'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? 'Unknown',
      userEmail: json['user_email'] as String? ?? '',
      educationLevel: json['education_level'] as String? ?? '',
      country: json['country'] as String?,
      rating: json['rating'] as int? ?? 5,
      quote: json['quote'] as String? ?? '',
      topicTag: json['topic_tag'] as String? ?? '',
      isPublicConsent: json['is_public_consent'] as bool? ?? true,
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['admin_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  AdminFeedbackModel copyWith({
    String? status,
    String? adminNotes,
  }) {
    return AdminFeedbackModel(
      id: id,
      feedbackId: feedbackId,
      sessionId: sessionId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      educationLevel: educationLevel,
      country: country,
      rating: rating,
      quote: quote,
      topicTag: topicTag,
      isPublicConsent: isPublicConsent,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class AdminFeedbackSummaryMetrics {
  final int totalCount;
  final int pendingCount;
  final int featuredCount;
  final int archivedCount;
  final double averageRating;

  const AdminFeedbackSummaryMetrics({
    required this.totalCount,
    required this.pendingCount,
    required this.featuredCount,
    required this.archivedCount,
    required this.averageRating,
  });

  factory AdminFeedbackSummaryMetrics.fromJson(Map<String, dynamic> json) {
    return AdminFeedbackSummaryMetrics(
      totalCount: json['total_count'] as int? ?? 0,
      pendingCount: json['pending_count'] as int? ?? 0,
      featuredCount: json['featured_count'] as int? ?? 0,
      archivedCount: json['archived_count'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaginatedAdminFeedbackResponse {
  final List<AdminFeedbackModel> items;
  final int total;
  final AdminFeedbackSummaryMetrics metrics;

  const PaginatedAdminFeedbackResponse({
    required this.items,
    required this.total,
    required this.metrics,
  });

  factory PaginatedAdminFeedbackResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List<dynamic>? ?? [])
        .map((e) => AdminFeedbackModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedAdminFeedbackResponse(
      items: list,
      total: json['total'] as int? ?? 0,
      metrics: AdminFeedbackSummaryMetrics.fromJson(
        json['metrics'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

