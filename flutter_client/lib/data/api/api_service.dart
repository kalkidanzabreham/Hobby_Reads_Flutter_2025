import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hobby_reads_flutter/data/repository/token_manager_repository.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'dart:io'; // Import for SocketException

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiException({required this.statusCode, required this.message, this.data});

  @override
  String toString() {
    return 'ApiException [' + statusCode.toString() + '] ' + message;
  }
}

class ApiService {
  final String baseUrl;
  final TokenManagerRepository _tokenManager;
  final Dio _dio;

  ApiService({
    required this.baseUrl,
    required TokenManagerRepository tokenManager,
    Dio? dio,
  })  : _tokenManager = tokenManager,
        _dio = dio ?? Dio();

  // HTTP Headers (will be handled by interceptors)
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = _tokenManager.getFormattedToken();
      if (token != null) {
        headers['Authorization'] = token;
      }
    }

    return headers;
  }

  // HTTP Methods
  Future<dynamic> get(
      String endpoint, {
        Map<String, String>? queryParams,
        bool requiresAuth = true,
      }) async {
    try {
      final response = await _dio.get(
        baseUrl + endpoint,
        queryParameters: queryParams,
        options:
        Options(headers: await _getHeaders(requiresAuth: requiresAuth)),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e, 'GET', endpoint);
    }
  }

  Future<dynamic> post(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? queryParams,
        bool requiresAuth = true,
      }) async {
    try {
      final response = await _dio.post(
        baseUrl + endpoint,
        queryParameters: queryParams,
        data: body,
        options:
        Options(headers: await _getHeaders(requiresAuth: requiresAuth)),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e, 'POST', endpoint);
    }
  }

  Future<dynamic> put(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? queryParams,
        bool requiresAuth = true,
      }) async {
    try {
      final response = await _dio.put(
        baseUrl + endpoint,
        queryParameters: queryParams,
        data: body,
        options:
        Options(headers: await _getHeaders(requiresAuth: requiresAuth)),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e, 'PUT', endpoint);
    }
  }

  Future<dynamic> patch(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? queryParams,
        bool requiresAuth = true,
      }) async {
    try {
      final response = await _dio.patch(
        baseUrl + endpoint,
        queryParameters: queryParams,
        data: body,
        options:
        Options(headers: await _getHeaders(requiresAuth: requiresAuth)),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e, 'PATCH', endpoint);
    }
  }

  Future<dynamic> delete(
      String endpoint, {
        Map<String, String>? queryParams,
        bool requiresAuth = true,
      }) async {
    try {
      final response = await _dio.delete(
        baseUrl + endpoint,
        queryParameters: queryParams,
        options:
        Options(headers: await _getHeaders(requiresAuth: requiresAuth)),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e, 'DELETE', endpoint);
    }
  }

  // File Upload
  Future<dynamic> uploadFile(
      String endpoint,
      List<int> fileBytes,
      String fileName, {
        Map<String, String>? fields,
        bool requiresAuth = true,
      }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
        ...?fields?.map((key, value) => MapEntry(key, value)),
      });

      final response = await _dio.post(
        baseUrl + endpoint,
        data: formData,
        options:
        Options(headers: await _getHeaders(requiresAuth: requiresAuth)),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e, 'UPLOAD', endpoint);
    }
  }

  // Cleanup
  void dispose() {
    _dio.close();
  }

  // Response handling
  dynamic _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (response.data == null) return null;
      return response.data;
    } else {
      debugPrint(
          'API Error: Status ${response.statusCode}, Body: ${response.data}');
      final errorBody = response.data;
      final message = errorBody?['message'] ?? 'Unknown error occurred';
      throw ApiException(
        statusCode: response.statusCode!,
        message: message,
        data: errorBody,
      );
    }
  }

  // Error handling
  Exception _handleError(dynamic error, String method, String endpoint) {
    if (error is DioException) {
      debugPrint('DioError: ${error.message}, Type: ${error.type}');
      if (error.response != null) {
        final errorBody = error.response?.data;
        final message =
            errorBody?['message'] ?? error.message ?? 'Unknown error occurred';
        return ApiException(
          statusCode: error.response!.statusCode!,
          message: message,
          data: errorBody,
        );
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return Exception('Connection timed out. Please try again.');
      } else if (error.type == DioExceptionType.badResponse) {
        final errorBody = error.response?.data;
        final message =
            errorBody?['message'] ?? error.message ?? 'Unknown error occurred';
        return ApiException(
          statusCode: error.response!.statusCode!,
          message: message,
          data: errorBody,
        );
      } else if (error.type == DioExceptionType.unknown) {
        if (error.error is SocketException) {
          return Exception(
              'Cannot connect to server. Please check your internet connection and ensure the backend server is running.');
        }
      }
      return ApiException(
        statusCode: error.response?.statusCode ?? 500,
        message: error.message ?? 'Unknown error occurred',
        data: error.response?.data,
      );
    } else if (error is ApiException) {
      return error;
    }

    // Generic error
    return Exception('Failed to make $method request to $endpoint: $error');
  }
}

