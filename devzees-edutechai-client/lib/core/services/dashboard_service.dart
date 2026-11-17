import 'package:dio/dio.dart';
import '../../data/models/dashboard/dashboard_response.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

class DashboardService {
  final Dio _dio;

  DashboardService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  /// Fetch consolidated learner dashboard metrics.
  ///
  /// [timeRange] can be '7d', '30d', '90d', or 'all'.
  Future<DashboardResponse> fetchDashboard({String timeRange = '30d'}) async {
    try {
      final response = await _dio.get(
        ApiConstants.learningDashboard,
        queryParameters: {'time_range': timeRange},
      );

      if (response.data is Map<String, dynamic>) {
        return DashboardResponse.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Unexpected response format from dashboard endpoint');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['errors']?.toString() ?? e.message;
      throw Exception('Failed to load dashboard metrics: $errorMsg');
    } catch (e) {
      throw Exception('Failed to load dashboard metrics: $e');
    }
  }
}
