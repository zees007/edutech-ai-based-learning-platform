import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/feedback/feedback_model.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService();
});

class FeedbackService {
  final Dio _dio = ApiClient.instance.dio;

  String _parseError(DioException e, String defaultMessage) {
    if (e.response?.data != null && e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('errors') && data['errors'] is List) {
        final errors = data['errors'] as List;
        if (errors.isNotEmpty) return errors.first.toString();
      }
      final detail = data['detail'];
      if (detail is List && detail.isNotEmpty) {
        return detail.first['msg']?.toString() ?? defaultMessage;
      } else if (detail is String) {
        return detail;
      }
    }
    return defaultMessage;
  }

  /// Submit feedback upon completing a learning journey. Awards +30 XP.
  Future<FeedbackSubmissionResponse> submitFeedback({
    required String sessionId,
    required int rating,
    required String quote,
    bool isPublicConsent = true,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.feedback,
        data: {
          'session_id': sessionId,
          'rating': rating,
          'quote': quote,
          'is_public_consent': isPublicConsent,
        },
      );
      return FeedbackSubmissionResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to submit feedback'));
    }
  }

  /// Fetch admin-featured public testimonials for the homepage Wall of Love.
  Future<List<PublicFeedbackModel>> getPublicFeaturedFeedback() async {
    try {
      final response = await _dio.get(ApiConstants.feedbackPublic);
      final list = (response.data as List<dynamic>? ?? [])
          .map((e) => PublicFeedbackModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to fetch public testimonials'));
    }
  }

  /// Admin endpoint to fetch paginated submitted feedback.
  Future<PaginatedAdminFeedbackResponse> getAdminFeedbacks({
    String? status,
    String? lookupText,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }
      if (lookupText != null && lookupText.isNotEmpty) {
        queryParams['lookup_text'] = lookupText;
      }

      final response = await _dio.get(
        ApiConstants.adminFeedback,
        queryParameters: queryParams,
      );
      return PaginatedAdminFeedbackResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to fetch admin feedback'));
    }
  }

  /// Admin endpoint to feature/unfeature feedback and add private notes.
  Future<AdminFeedbackModel> updateFeedbackStatus({
    required String feedbackId,
    required String status,
    String? adminNotes,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.adminFeedbackStatus(feedbackId),
        data: {
          'status': status,
          'admin_notes': ?adminNotes,
        },
      );
      return AdminFeedbackModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to update feedback status'));
    }
  }
}

