import 'package:dio/dio.dart';
import '../../data/models/admin/paginated_user_response.dart';
import '../../data/models/admin/paginated_role_response.dart';
import '../../data/models/admin/privilege_response.dart';
import '../../data/models/admin/role_create_request.dart';
import '../../data/models/admin/role_response.dart';
import '../../data/models/admin/subscription_update_request.dart';
import '../../data/models/admin/user_response.dart';
import '../../data/models/admin/user_role_assign_request.dart';
import '../../data/models/auth/subscription_response.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

/// Admin service handling all admin-related API calls:
/// User search, role management, privilege listing, and subscription tier updates.
class AdminService {
  final Dio _dio = ApiClient.instance.dio;

  String _parseError(DioException e, String defaultMessage) {
    if (e.response?.data != null && e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('error_code') && data['error_code'] != null) {
        if (data.containsKey('errors') && data['errors'] is List) {
          final errors = data['errors'] as List;
          if (errors.isNotEmpty) return errors.first.toString();
        }
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

  // ─── Metrics / Analytics ────────────────────────────────────────

  /// Fetch global admin dashboard metrics.
  Future<Map<String, dynamic>> getAdminMetrics() async {
    try {
      final response = await _dio.get(ApiConstants.adminMetrics);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to fetch admin metrics'));
    }
  }

  // ─── User Management ──────────────────────────────────────────

  /// Search users with pagination and optional lookup text.
  Future<PaginatedUserResponse> searchUsers({
    int page = 0,
    int size = 50,
    String? lookupText,
    String? sortBy,
    bool? isDesc,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.usersSearch,
        queryParameters: {
          'page': page,
          'size': size,
          if (lookupText != null && lookupText.isNotEmpty) 'lookupText': lookupText,
          if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
          if (isDesc != null) 'isDesc': isDesc,
        },
      );
      return PaginatedUserResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to fetch users'));
    }
  }

  /// Get a single user by ID.
  Future<AdminUserResponse> getUserById(String userId) async {
    try {
      final response = await _dio.get(ApiConstants.userById(userId));
      return AdminUserResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to fetch user'));
    }
  }

  /// Assign roles to a user.
  Future<AdminUserResponse> assignUserRoles(String userId, List<String> roleIds) async {
    try {
      final request = UserRoleAssignRequest(roleIds: roleIds);
      final response = await _dio.put(
        ApiConstants.userRoles(userId),
        data: request.toJson(),
      );
      return AdminUserResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to assign roles'));
    }
  }

  // ─── Role Management ──────────────────────────────────────────

  /// Search roles with pagination.
  Future<PaginatedRoleResponse> searchRoles({
    int page = 0,
    int size = 50,
    String? lookupText,
    String? sortBy,
    bool? isDesc,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.rolesSearch,
        queryParameters: {
          'page': page,
          'size': size,
          if (lookupText != null && lookupText.isNotEmpty) 'lookupText': lookupText,
          if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
          if (isDesc != null) 'isDesc': isDesc,
        },
      );
      return PaginatedRoleResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to fetch roles'));
    }
  }

  /// Create a new role with assigned privilege IDs.
  Future<RoleResponse> createRole(RoleCreateRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.rolesCreate,
        data: request.toJson(),
      );
      return RoleResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to create role'));
    }
  }

  /// Get all available privileges (flat list).
  Future<List<PrivilegeResponse>> getAllPrivileges() async {
    try {
      final response = await _dio.get(ApiConstants.privileges);
      return (response.data as List)
          .map((json) => PrivilegeResponse.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to fetch privileges'));
    }
  }

  // ─── Subscription Management ──────────────────────────────────

  /// Update a user's subscription tier and sync their database role.
  Future<SubscriptionResponse> updateSubscriptionTier(
    String userId,
    SubscriptionUpdateRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.userSubscriptionTier(userId),
        data: request.toJson(),
      );
      return SubscriptionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to update subscription'));
    }
  }
}
