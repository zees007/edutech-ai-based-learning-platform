import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

final academicServiceProvider = Provider<AcademicService>((ref) {
  return AcademicService();
});

class AcademicService {
  final Dio _dio;

  AcademicService() : _dio = ApiClient.instance.dio;

  /// Search academic papers via the backend API.
  /// Deduplication, parallel searching, and privilege checks 
  /// are all handled securely on the backend.
  Future<List<Map<String, dynamic>>> searchAll(
    String query, {
    int maxResults = 5,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    try {
      final response = await _dio.get(
        ApiConstants.academicSearch,
        queryParameters: {
          'query': cleanQuery,
          'max_results': maxResults,
        },
      );

      final List data = response.data ?? [];
      
      // Convert list of dynamic maps to List<Map<String, dynamic>>
      final List<Map<String, dynamic>> papers = [];
      for (final item in data) {
        if (item is Map) {
          papers.add(Map<String, dynamic>.from(item));
        }
      }
      return papers;
    } catch (_) {
      return [];
    }
  }
}
