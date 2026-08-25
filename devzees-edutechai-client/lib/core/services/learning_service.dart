import 'package:dio/dio.dart';
import '../../data/models/learning/session_model.dart';
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
}
