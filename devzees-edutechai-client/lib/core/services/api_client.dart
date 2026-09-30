import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../constants/api_constants.dart';

class AuthInterceptor extends QueuedInterceptor {
  final ApiClient apiClient;

  AuthInterceptor(this.apiClient);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is 401 and it's not from refresh or login itself
    if (err.response?.statusCode == 401 && 
        !err.requestOptions.path.contains(ApiConstants.refresh) && 
        !err.requestOptions.path.contains(ApiConstants.login)) {
      
      final data = err.response?.data;
      bool isTokenExpired = false;
      bool isTokenRevoked = false;
      
      if (data is Map) {
         if (data['error_code'] == 'TOKEN_EXPIRED' || data['error_code'] == 'UNAUTHORIZED' || data['error_code'] == 'INVALID_TOKEN') {
            isTokenExpired = true;
         } else if (data['error_code'] == 'TOKEN_REVOKED' || data['error_code'] == 'TOKEN_REUSE_DETECTED') {
            isTokenRevoked = true;
         }
      } else {
         isTokenExpired = true; // Fallback assume expired
      }

      if (isTokenRevoked) {
         apiClient.onSessionExpired?.call();
         return handler.next(err);
      }

      if (isTokenExpired) {
        try {
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: apiClient.dio.options.baseUrl,
              extra: {'withCredentials': true},
            )
          );
          
          if (apiClient.cookieJar != null) {
            refreshDio.interceptors.add(CookieManager(apiClient.cookieJar!));
          }

          final refreshResponse = await refreshDio.post(ApiConstants.refresh);
          
          if (refreshResponse.statusCode == 200) {
            // Successfully refreshed token, retry original request
            final opts = err.requestOptions;
            final response = await apiClient.dio.fetch(opts);
            return handler.resolve(response);
          }
        } catch (_) {
          // Refresh failed (e.g. refresh token expired)
          apiClient.onSessionExpired?.call();
          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }
}

class ApiClient {
  late final Dio _dio;
  void Function()? onSessionExpired;
  PersistCookieJar? cookieJar;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(AuthInterceptor(this));
  }

  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  Dio get dio => _dio;

  Future<void> initCookieJar() async {
    if (!kIsWeb) {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      cookieJar = PersistCookieJar(
        ignoreExpires: true,
        storage: FileStorage("$appDocPath/.cookies/"),
      );
      _dio.interceptors.add(CookieManager(cookieJar!));
    } else {
      _dio.options.extra['withCredentials'] = true;
    }
  }
}
