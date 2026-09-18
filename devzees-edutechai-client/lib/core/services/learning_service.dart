import 'package:dio/dio.dart';
import '../../data/models/learning/session_model.dart';
import '../../data/models/learning/session_response.dart';
import '../../data/models/learning/quiz_result.dart';
import '../constants/api_constants.dart';
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
        ApiConstants.sessions,
        queryParameters: queryParams,
      );

      return PaginatedSessionResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch learning sessions: $e');
    }
  }

  Future<SessionResponse> fetchSessionById(String sessionId) async {
    try {
      final response = await _dio.get(ApiConstants.sessionDetails(sessionId));
      return SessionResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch learning session details: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _dio.delete(ApiConstants.sessionDetails(sessionId));
    } catch (e) {
      throw Exception('Failed to delete learning session: $e');
    }
  }

  Future<String> sendFollowUpQuestion(String sessionId, int stepIndex, String question) async {
    try {
      final response = await _dio.post(
        ApiConstants.followUpQuestion(sessionId, stepIndex),
        data: {'question': question},
      );
      return response.data['answer'] as String;
    } catch (e) {
      throw Exception('Failed to send follow-up question: $e');
    }
  }

  Future<SessionResponse> startJourney({
    required String topic,
    required String mode,
    required String level,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.learn,
        data: {
          'topic': topic,
          'learning_mode': mode
              .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
              .replaceAll(RegExp(r'[^\w\s-]'), '')
              .trim()
              .toLowerCase()
              .replaceAll(RegExp(r'\s+'), '_')
              .replaceAll('-', '_'),
          'student_level': level
              .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
              .replaceAll(RegExp(r'[^\w\s-]'), '')
              .trim()
              .toLowerCase()
              .replaceAll(RegExp(r'\s+'), '_'),
        },
      );
      return SessionResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to start journey: $e');
    }
  }

  Future<QuizResult> submitQuiz(String sessionId, int stepIndex, Map<int, String> answers) async {
    try {
      // Dio/jsonEncode requires Map keys to be Strings
      final stringKeyAnswers = answers.map((k, v) => MapEntry(k.toString(), v));
      
      final response = await _dio.post(
        ApiConstants.quizSubmit,
        data: {
          'session_id': sessionId,
          'step_index': stepIndex,
          'answers': stringKeyAnswers,
        },
      );
      return QuizResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }

  Future<Map<String, dynamic>> completeStep(String sessionId, int stepIndex) async {
    try {
      final response = await _dio.post(
        ApiConstants.completeStep(sessionId, stepIndex),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to complete step: $e');
    }
  }

  Future<void> regenerateStep(String sessionId, int stepIndex) async {
    try {
      await _dio.post(
        ApiConstants.regenerateStep(sessionId, stepIndex),
      );
    } catch (e) {
      throw Exception('Failed to regenerate step: $e');
    }
  }
}
