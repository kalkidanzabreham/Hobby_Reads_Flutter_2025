import 'package:hobby_reads_flutter/data/api/api_service.dart';
import 'package:hobby_reads_flutter/data/model/auth_model.dart';
import 'package:hobby_reads_flutter/data/model/connection_model.dart';


class ConnectionRepository {
  final ApiService _apiService;

  ConnectionRepository(this._apiService);

  // Connection Requests
  Future<List<ConnectionModel>> getPendingRequests({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get('/connections/pending');

      // Backend returns array directly
      final List<dynamic> connectionsData = response is List ? response : response['data'] ?? [];
      
      return connectionsData
          .map((conn) => ConnectionModel.fromJson(conn as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }

  Future<ConnectionModel> sendConnectionRequest(String userId) async {
    try {
      final response = await _apiService.post('/connections/$userId');
      return ConnectionModel.fromJson(_extractData(response));
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }

  Future<ConnectionModel> respondToRequest({
    required String requestId,
    required bool accept,
    String? message,
  }) async {
    try {
      final endpoint = accept ? '/connections/$requestId/accept' : '/connections/$requestId/reject';
      final response = await _apiService.put(endpoint, body: {
        if (message != null) 'message': message,
      });
      return ConnectionModel.fromJson(_extractData(response));
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }

  Future<void> cancelRequest(String requestId) => removeConnection(requestId);

  // Connection Management
  Future<List<ConnectionModel>> getConnections({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final response = await _apiService.get('/connections');

      // Backend returns array directly
      final List<dynamic> connectionsData = response is List ? response : response['data'] ?? [];
      
      return connectionsData
          .map((conn) => ConnectionModel.fromJson(conn as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }

  Future<ConnectionModel> getConnection(String userId) async {
    try {
      final response = await _apiService.get('/connections/$userId');
      return ConnectionModel.fromJson(_extractData(response));
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }

  Future<void> removeConnection(String connectionId) async {
    try {
      await _apiService.delete('/connections/$connectionId');
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _apiService.post(
        '/connections/block',
        body: {'userId': userId},
      );
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _apiService.delete('/connections/block/$userId');
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }

  // Connection Status
  Future<String> getConnectionStatus(String userId) async {
    try {
      final response = await _apiService.get('/connections/status/$userId');
      return _extractData(response)['status'];
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }

  Future<bool> isConnected(String userId) async {
    try {
      final response = await _apiService.get('/connections/check/$userId');
      return _extractData(response)['isConnected'];
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }

  Future<bool> isBlocked(String userId) async {
    try {
      final response = await _apiService.get('/connections/blocked/$userId');
      return _extractData(response)['isBlocked'];
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }

  // Connection Suggestions
  Future<List<ConnectionModel>> getConnectionSuggestions({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get('/connections/suggested');

      // Backend returns array directly
      final List<dynamic> suggestionsData = response is List ? response : response['data'] ?? [];
      
      return suggestionsData
          .map((suggestion) => ConnectionModel.fromJson(suggestion as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleConnectionError(e);
    }
  }



  // Helper methods
  Map<String, dynamic> _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response['data'] ?? response;
    }
    return {};
  }

  // Error Handling
  String _handleConnectionError(dynamic error) {
    if (error.toString().contains('ApiException')) {
      // Extract status code if available
      final errorStr = error.toString();
      if (errorStr.contains('400')) {
        return 'Invalid connection request data.';
      } else if (errorStr.contains('401')) {
        return 'Authentication required.';
      } else if (errorStr.contains('403')) {
        return 'You do not have permission to perform this action.';
      } else if (errorStr.contains('404')) {
        return 'User or connection not found.';
      } else if (errorStr.contains('409')) {
        return 'Connection request already exists.';
      } else if (errorStr.contains('422')) {
        return 'Invalid input data.';
      } else if (errorStr.contains('500')) {
        return 'Server error. Please try again later.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
} 