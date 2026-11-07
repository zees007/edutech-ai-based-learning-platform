import 'package:dio/dio.dart';
import '../../data/models/auth/user_current_profile_response.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';
import 'auth_service.dart';

/// User service handling self-service user operations:
/// Profile editing and password changes.
class UserService {
  final Dio _dio = ApiClient.instance.dio;

  String _parseError(DioException e, String defaultMessage) {
    if (e.response?.data != null && e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;

      // Check for EduTech custom error format { error_code: ..., errors: [...] }
      if (data.containsKey('error_code') && data['error_code'] != null) {
        if (data.containsKey('errors') && data['errors'] is List) {
          final errors = data['errors'] as List;
          if (errors.isNotEmpty) {
            return errors.first.toString();
          }
        }
      }

      // Check standard FastAPI detail
      final detail = data['detail'];
      if (detail is List && detail.isNotEmpty) {
        return detail.first['msg']?.toString() ?? defaultMessage;
      } else if (detail is String) {
        return detail;
      }
    }
    return defaultMessage;
  }

  /// Updates the current user's profile details.
  Future<UserCurrentProfileResponse> updateProfile(
    String userId, {
    required String firstName,
    required String lastName,
    String? country,
    String? mobile,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.editUser(userId),
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'country': ?country,
          'mobile': ?mobile,
        },
      );

      // Re-fetch the verified user profile from /auth/me
      final me = await AuthService().getMe();
      if (me != null) {
        return me;
      }

      return UserCurrentProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to update profile'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Changes the user's password.
  /// Backend automatically invalidates prior sessions and rotates session cookies.
  Future<Map<String, dynamic>> changePassword(
    String userId, {
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.changePassword(userId),
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      return (response.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      throw Exception(_parseError(e, 'Failed to change password'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

