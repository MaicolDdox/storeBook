import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../errors/api_exception.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient(this._tokenStorage)
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<Response<dynamic>> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<Response<dynamic>> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  ApiException _mapException(DioException error) {
    final statusCode = error.response?.statusCode;
    final body = error.response?.data;

    if (statusCode == 401) {
      return ApiException(
        statusCode: 401,
        message: 'Session expired. Please sign in again.',
      );
    }
    if (statusCode == 403) {
      return ApiException(
        statusCode: 403,
        message: 'You are not authorized to perform this action.',
      );
    }
    if (statusCode == 422) {
      return ApiException(
        statusCode: 422,
        message: (body?['message'] ?? 'Validation failed.') as String,
        validationErrors: (body?['errors'] as Map?)?.cast<String, dynamic>(),
      );
    }

    return ApiException(
      statusCode: statusCode,
      message: (body?['message'] ?? 'Unexpected network error.') as String,
    );
  }
}
