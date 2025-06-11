import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hobby_reads_flutter/data/repository/token_manager_repository.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

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
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    required TokenManagerRepository tokenManager,
    http.Client? client,
  })  : _tokenManager = tokenManager,
        _client = client ?? http.Client();

  // HTTP Headers
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
      final uri =
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final response = await _client.get(
        uri,
        headers: await _getHeaders(requiresAuth: requiresAuth),
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
      final uri =
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final response = await _client.post(
        uri,
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: body != null ? json.encode(body) : null,
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
      final uri =
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final response = await _client.put(
        uri,
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: body != null ? json.encode(body) : null,
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
      final uri =
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final response = await _client.patch(
        uri,
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: body != null ? json.encode(body) : null,
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
      final uri =
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final response = await _client.delete(
        uri,
        headers: await _getHeaders(requiresAuth: requiresAuth),
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
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Do not set Content-Type header for MultipartRequest, it's handled automatically
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      headers.remove('Content-Type'); // Remove application/json
      request.headers.addAll(headers);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Cleanup
  void dispose() {
    _client.close();
  }

  // Response handling
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      debugPrint(
          'API Error: Status ${response.statusCode}, Body: ${response.body}');
      final errorBody =
          response.body.isNotEmpty ? json.decode(response.body) : null;
      final message = errorBody?['message'] ?? 'Unknown error occurred';
      throw ApiException(
        statusCode: response.statusCode,
        message: message,
        data: errorBody,
      );
    }
  }

  // Error handling
  Exception _handleError(dynamic error, String method, String endpoint) {
    if (error is ApiException) {
      return error;
    }

    // Network/connection errors
    if (error.toString().contains('Failed host lookup') ||
        error.toString().contains('Connection refused') ||
        error.toString().contains('No address associated with hostname')) {
      return Exception(
          'Cannot connect to server. Please check your internet connection and ensure the backend server is running.');
    }

    if (error.toString().contains('Connection timed out')) {
      return Exception('Server request timed out. Please try again.');
    }

    return Exception('Failed to make $method request to $endpoint: $error');
  }
}
