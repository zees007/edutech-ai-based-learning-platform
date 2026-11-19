import 'package:dio/dio.dart';
import '../../data/models/dashboard/dashboard_response.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

class DashboardService {
  final Dio _dio;

  DashboardService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  /// Fetch all-time learner standing HUD (Level, XP, Streaks, Trophies).
  Future<LearnerStanding> fetchStanding({String? userId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null && userId.trim().isNotEmpty) {
        queryParams['user_id'] = userId.trim();
      }

      final response = await _dio.get(
        ApiConstants.learnerStanding,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.data is Map<String, dynamic>) {
        return LearnerStanding.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Unexpected response format from standing endpoint');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['errors']?.toString() ?? e.message;
      throw Exception('Failed to load learner standing: $errorMsg');
    } catch (e) {
      throw Exception('Failed to load learner standing: $e');
    }
  }

  /// Fetch interval-scoped performance metrics.
  Future<PeriodPerformance> fetchPerformance({
    String? userId,
    String timeRange = '30d',
    DateTime? startDate,
    DateTime? endDate,
    int? tzOffsetMinutes,
  }) async {
    try {
      final offset = tzOffsetMinutes ?? DateTime.now().timeZoneOffset.inMinutes;
      final queryParams = <String, dynamic>{
        'time_range': timeRange,
        'tz_offset_minutes': offset,
      };

      if (userId != null && userId.trim().isNotEmpty) {
        queryParams['user_id'] = userId.trim();
      }

      if (timeRange == 'custom' && startDate != null && endDate != null) {
        String formatYmd(DateTime d) =>
            '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        queryParams['start_date'] = formatYmd(startDate);
        queryParams['end_date'] = formatYmd(endDate);
      }

      final response = await _dio.get(
        ApiConstants.learnerPerformance,
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        return PeriodPerformance.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Unexpected response format from performance endpoint');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['errors']?.toString() ?? e.message;
      throw Exception('Failed to load performance metrics: $errorMsg');
    } catch (e) {
      throw Exception('Failed to load performance metrics: $e');
    }
  }

  /// Fetch consolidated learner dashboard metrics combining standing and performance.
  Future<DashboardResponse> fetchDashboard({
    String? userId,
    String timeRange = '30d',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final results = await Future.wait([
        fetchStanding(userId: userId),
        fetchPerformance(userId: userId, timeRange: timeRange, startDate: startDate, endDate: endDate),
      ]);

      final standing = results[0] as LearnerStanding;
      final performance = results[1] as PeriodPerformance;

      final summary = DashboardSummary(
        totalSessions: performance.summary.totalSessions,
        completedSessions: performance.summary.completedSessions,
        completionRate: performance.summary.completionRate,
        totalStepsMastered: performance.summary.totalStepsMastered,
        totalStudyMinutes: performance.summary.totalStudyMinutes,
        averageQuizScoreOverall: performance.summary.averageQuizScoreOverall,
        totalXp: standing.totalXp,
        currentLevel: standing.currentLevel,
        levelTitle: standing.levelTitle,
        xpProgressInLevel: standing.xpProgressInLevel,
        xpNeededForNext: standing.xpNeededForNext,
        isMaxLevel: standing.isMaxLevel,
        currentStreak: standing.currentStreak,
        longestStreak: standing.longestStreak,
      );

      return DashboardResponse(
        summary: summary,
        quizMetrics: performance.quizMetrics,
        activityHeatmap: performance.activityHeatmap,
        topicBreakdown: performance.topicBreakdown,
        modeDistribution: performance.modeDistribution,
        achievements: standing.achievements,
      );
    } catch (e) {
      throw Exception('Failed to load dashboard metrics: $e');
    }
  }
}
