import 'package:dio/dio.dart';
import '../../data/models/learning/session_model.dart';
import '../../data/models/learning/session_response.dart';
import 'api_client.dart';

class LearningService {
  final Dio _dio;

  LearningService() : _dio = ApiClient.instance.dio;

  Future<PaginatedSessionResponse> fetchSessions({
    required int page,
    required int size,
    String? lookupText,
    String statusFilter = 'all',
  }) async {
    try {
      final queryParams = {
        'page': page,
        'size': size,
        'status_filter': statusFilter,
      };

      if (lookupText != null && lookupText.trim().isNotEmpty) {
        queryParams['lookup_text'] = lookupText.trim();
      }

      final response = await _dio.get(
        '/sessions',
        queryParameters: queryParams,
      );

      return PaginatedSessionResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch learning sessions: $e');
    }
  }

  Future<SessionResponse> fetchSessionById(String sessionId) async {
    try {
      final response = await _dio.get('/sessions/$sessionId');
      return SessionResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch learning session details: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _dio.delete('/sessions/$sessionId');
    } catch (e) {
      throw Exception('Failed to delete learning session: $e');
    }
  }

  Future<String> sendFollowUpQuestion(String sessionId, int stepIndex, String question) async {
    try {
      final response = await _dio.post(
        '/sessions/$sessionId/step/$stepIndex/followup',
        data: {'question': question},
      );
      return response.data['answer'] as String;
    } catch (e) {
      throw Exception('Failed to send follow-up question: $e');
    }
  }
}
