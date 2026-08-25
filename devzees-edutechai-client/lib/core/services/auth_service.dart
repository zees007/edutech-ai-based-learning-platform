import 'package:dio/dio.dart';
import '../../data/models/auth/login_request.dart';
import '../../data/models/auth/user_create_request.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  String _parseError(DioException e, String defaultMessage) {
    if (e.response?.data != null && e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      
      // Handle custom APIError format from main.py
      if (data.containsKey('error_code') && data['error_code'] != null) {
        if (data.containsKey('errors') && data['errors'] is List) {
          final errors = data['errors'] as List;
          if (errors.isNotEmpty) {
            return errors.first.toString();
          }
        }
      }
      
      // Fallback for standard FastAPI detail
      final detail = data['detail'];
      if (detail is List && detail.isNotEmpty) {
        return detail.first['msg']?.toString() ?? defaultMessage;
      } else if (detail is String) {
        return detail;
      }
    }
    return defaultMessage;
  }

  Future<bool> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(_parseError(e, 'Login failed'));
      }
      throw Exception('Network error occurred. Please check if the server is running on ${ApiConstants.baseUrl}.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> createUser(UserCreateRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.createUser,
        data: request.toJson(),
      );
      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(_parseError(e, 'Registration failed'));
      }
      throw Exception('Network error occurred. Please check if the server is running on ${ApiConstants.baseUrl}.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> logout() async {
    try {
      final response = await _dio.post(ApiConstants.logout);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      // If API logout fails, still return false but don't crash
      return false;
    }
  }
}
