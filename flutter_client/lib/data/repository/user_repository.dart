import 'package:hobby_reads_flutter/data/api/api_service.dart';
import 'package:hobby_reads_flutter/data/model/user_model.dart';
import 'package:hobby_reads_flutter/data/repository/token_manager_repository.dart';

class UserRepository {
  final ApiService _apiService;
  final TokenManagerRepository _tokenManager;

  UserRepository(this._apiService, this._tokenManager);

  // User Profile Operations
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId');
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<UserModel> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put('/users/$userId', body: updates);
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // User Settings
  Future<Map<String, dynamic>> getUserSettings(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/settings');
      return response;
    } catch (e) {
      throw Exception('Failed to get user settings: $e');
    }
  }

  Future<Map<String, dynamic>> updateUserSettings(
      String userId, Map<String, dynamic> settings) async {
    try {
      final response =
          await _apiService.put('/users/$userId/settings', body: settings);
      return response;
    } catch (e) {
      throw Exception('Failed to update user settings: $e');
    }
  }

  // User Activity
  Future<List<Map<String, dynamic>>> getUserActivity(String userId,
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/users/$userId/activity',
        queryParams: {'page': page.toString(), 'limit': limit.toString()},
      );
      return List<Map<String, dynamic>>.from(response['activities']);
    } catch (e) {
      throw Exception('Failed to get user activity: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserReadingHistory(String userId,
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/users/$userId/reading-history',
        queryParams: {'page': page.toString(), 'limit': limit.toString()},
      );
      return List<Map<String, dynamic>>.from(response['history']);
    } catch (e) {
      throw Exception('Failed to get reading history: $e');
    }
  }

  // User Statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/statistics');
      return response;
    } catch (e) {
      throw Exception('Failed to get user statistics: $e');
    }
  }

  // User Search
  Future<List<UserModel>> searchUsers(String query,
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/users/search',
        queryParams: {
          'query': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      return (response['users'] as List)
          .map((user) => UserModel.fromJson(user))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // User Verification
  Future<bool> verifyUserEmail(String token) async {
    try {
      final response =
          await _apiService.post('/users/verify-email', body: {'token': token});
      return response['verified'] ?? false;
    } catch (e) {
      throw Exception('Failed to verify email: $e');
    }
  }

  Future<bool> requestEmailVerification(String email) async {
    try {
      final response = await _apiService
          .post('/users/request-verification', body: {'email': email});
      return response['sent'] ?? false;
    } catch (e) {
      throw Exception('Failed to request email verification: $e');
    }
  }

  // User Account Management
  Future<bool> deleteUserAccount(String userId) async {
    try {
      final response = await _apiService.delete('/users/$userId');
      return response['deleted'] ?? false;
    } catch (e) {
      throw Exception('Failed to delete user account: $e');
    }
  }

  Future<bool> deactivateUserAccount(String userId) async {
    try {
      final response = await _apiService.post('/users/$userId/deactivate');
      return response['deactivated'] ?? false;
    } catch (e) {
      throw Exception('Failed to deactivate user account: $e');
    }
  }

  Future<bool> reactivateUserAccount(String userId) async {
    try {
      final response = await _apiService.post('/users/$userId/reactivate');
      return response['reactivated'] ?? false;
    } catch (e) {
      throw Exception('Failed to reactivate user account: $e');
    }
  }

  // User Preferences
  Future<Map<String, dynamic>> updateUserPreferences(
      String userId, Map<String, dynamic> preferences) async {
    try {
      final response = await _apiService.put('/users/$userId/preferences',
          body: preferences);
      return response;
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/preferences');
      return response;
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  // User Notifications
  Future<Map<String, dynamic>> updateNotificationSettings(
      String userId, Map<String, dynamic> settings) async {
    try {
      final response =
          await _apiService.put('/users/$userId/notifications', body: settings);
      return response;
    } catch (e) {
      throw Exception('Failed to update notification settings: $e');
    }
  }

  Future<Map<String, dynamic>> getNotificationSettings(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/notifications');
      return response;
    } catch (e) {
      throw Exception('Failed to get notification settings: $e');
    }
  }

  // User Privacy
  Future<Map<String, dynamic>> updatePrivacySettings(
      String userId, Map<String, dynamic> settings) async {
    try {
      final response =
          await _apiService.put('/users/$userId/privacy', body: settings);
      return response;
    } catch (e) {
      throw Exception('Failed to update privacy settings: $e');
    }
  }

  Future<Map<String, dynamic>> getPrivacySettings(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/privacy');
      return response;
    } catch (e) {
      throw Exception('Failed to get privacy settings: $e');
    }
  }

  // Error Handling
  Exception _handleUserError(dynamic error) {
    if (error is Exception) {
      return error;
    }
    return Exception('An unexpected error occurred: $error');
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _apiService.get('/users');

      if (response is List) {
        // If the API directly returns a list of user objects
        return response
            .map((user) => UserModel.fromJson(user as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('users')) {
        // If the API returns a map with a 'users' key containing the list
        return (response['users'] as List)
            .map((user) => UserModel.fromJson(user as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('data')) {
        // If the API returns a map with a 'data' key containing the list
        return (response['data'] as List)
            .map((user) => UserModel.fromJson(user as Map<String, dynamic>))
            .toList();
      }

      // If the response format is unexpected
      throw Exception('Unexpected API response format for fetching all users.');
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete('/users/$userId');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
