import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

class ExportService {
  final Dio _dio;

  ExportService() : _dio = ApiClient.instance.dio;

  /// Fetches the learning session summary as Markdown plain text.
  /// Requires `ET_EXPORT_MARKDOWN` privilege (Pro/Ultra).
  /// Only available when all steps in the session are completed.
  Future<String> fetchMarkdown(String sessionId) async {
    try {
      final response = await _dio.get<String>(
        ApiConstants.exportMarkdown(sessionId),
        options: Options(
          responseType: ResponseType.plain,
          headers: {'Accept': 'text/plain'},
        ),
      );
      return response.data ?? '';
    } on DioException catch (e) {
      throw _handleDioError(e, 'Markdown');
    } catch (e) {
      throw Exception('Failed to export markdown: $e');
    }
  }

  /// Fetches the learning session study guide as PDF binary bytes.
  /// Requires `ET_EXPORT_PDF` privilege (Ultra).
  /// Only available when all steps in the session are completed.
  Future<List<int>> fetchPdf(String sessionId) async {
    try {
      final response = await _dio.get<List<int>>(
        ApiConstants.exportPdf(sessionId),
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );
      return response.data ?? [];
    } on DioException catch (e) {
      throw _handleDioError(e, 'PDF');
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  Exception _handleDioError(DioException e, String format) {
    final status = e.response?.statusCode;
    if (status == 400) {
      final data = e.response?.data;
      if (data is Map && data['error_code'] == 'SESSION_INCOMPLETE') {
        return Exception('Export is only available when the learning journey is 100% completed. All steps must be finished first.');
      }
      return Exception('Journey incomplete: please complete all milestones to export.');
    } else if (status == 403) {
      if (format == 'PDF') {
        return Exception('PDF Study Guide export requires an active Ultra subscription.');
      }
      return Exception('Markdown export requires an active Pro or Ultra subscription.');
    } else if (status == 404) {
      return Exception('Session not found or unavailable.');
    }
    return Exception('Failed to generate $format: ${e.message ?? 'Unknown network error'}');
  }
}
