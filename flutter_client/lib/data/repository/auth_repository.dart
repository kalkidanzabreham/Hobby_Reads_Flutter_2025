import 'package:hobby_reads_flutter/data/api/api_service.dart';
import 'package:hobby_reads_flutter/data/model/auth_model.dart';
import 'package:hobby_reads_flutter/data/repository/token_manager_repository.dart';

class AuthRepository {
  final ApiService _apiService;
  final TokenManagerRepository _tokenManager;

  AuthRepository(this._apiService, this._tokenManager);

  // Authentication
  Future<AuthModel> login(String identifier, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        body: {
          'username': identifier,  // Can be username or email
          'password': password,
        },
        requiresAuth: false,
      );
      
      // Debug print the response
      print('Login response: $response');
      
      if (response['token'] == null) {
        throw Exception('Login was successful but no authentication token was received. Please try again.');
      }
      
      await _tokenManager.saveTokens(
        accessToken: response['token'],
        refreshToken: response['token'], // Backend only returns one token
        expiryDate: DateTime.now().add(const Duration(hours: 24)), // 24h expiry
      );
      
      if (response['user'] == null) {
        throw Exception('Login was successful but user information was not received. Please try again.');
      }
      
      return AuthModel.fromJson(response['user']);
    } catch (e) {
      print('Login error: $e');
      
      // Handle specific error types
      if (e.toString().contains('ApiException')) {
        final errorMatch = RegExp(r'\[(\d+)\] (.+)').firstMatch(e.toString());
        if (errorMatch != null) {
          final statusCode = int.parse(errorMatch.group(1)!);
          final message = errorMatch.group(2)!;
          
          switch (statusCode) {
            case 400:
              throw Exception('Please check your username/email and password.');
            case 401:
              throw Exception('Incorrect username/email or password. Please check your credentials and try again.');
            case 403:
              throw Exception('Your account has been suspended. Please contact support.');
            case 404:
              throw Exception('No account found with these credentials. Please check your username/email or create a new account.');
            case 429:
              throw Exception('Too many login attempts. Please wait a few minutes before trying again.');
            case 500:
              throw Exception('Server error occurred during login. Please try again later.');
            default:
              throw Exception(message.isNotEmpty ? message : 'Login failed. Please try again.');
          }
        }
      }
      
      // Handle connection errors
      if (e.toString().contains('Cannot connect to server')) {
        throw Exception('Cannot connect to server. Please check your internet connection and make sure the backend is running.');
      }
      
      if (e.toString().contains('timed out')) {
        throw Exception('Login request timed out. Please check your connection and try again.');
      }
      
      // Handle parsing errors
      if (e.toString().contains('type \'Null\' is not a subtype') || 
          e.toString().contains('FormatException') ||
          e.toString().contains('TypeError')) {
        throw Exception('There was an issue processing your login. Please try again or contact support if the problem persists.');
      }
      
      // Generic fallback
      throw Exception('Login failed. Please check your credentials and try again.');
    }
  }

  Future<AuthModel> register({
    required String email,
    required String password,
    required String name,
    String? username,
    String? bio,
    List<String>? hobbies,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        body: {
          'email': email,
          'password': password,
          'name': name,
          'username': username ?? email.split('@')[0], // Use email prefix as default username
          if (bio != null) 'bio': bio,
          if (hobbies != null) 'hobbies': hobbies,
        },
        requiresAuth: false,
      );
      
      // Debug print the response
      print('Register response: $response');
      
      if (response['token'] == null) {
        throw Exception('Registration was successful but no authentication token was received. Please try logging in.');
      }
      
      await _tokenManager.saveTokens(
        accessToken: response['token'],
        refreshToken: response['token'], // Backend only returns one token
        expiryDate: DateTime.now().add(const Duration(hours: 24)), // 24h expiry
      );
      
      if (response['user'] == null) {
        throw Exception('Registration was successful but user information was not received. Please try logging in.');
      }
      
      return AuthModel.fromJson(response['user']);
    } catch (e) {
      print('Register error: $e');
      
      // Handle specific error types
      if (e.toString().contains('ApiException')) {
        final errorMatch = RegExp(r'\[(\d+)\] (.+)').firstMatch(e.toString());
        if (errorMatch != null) {
          final statusCode = int.parse(errorMatch.group(1)!);
          final message = errorMatch.group(2)!;
          
          switch (statusCode) {
            case 400:
              if (message.toLowerCase().contains('email')) {
                throw Exception('This email is already registered. Please use a different email or try logging in.');
              } else if (message.toLowerCase().contains('username')) {
                throw Exception('This username is already taken. Please choose a different username.');
              } else if (message.toLowerCase().contains('password')) {
                throw Exception('Password is too weak. Please use a stronger password with at least 6 characters.');
              } else {
                throw Exception('Invalid registration information. Please check your details and try again.');
              }
            case 409:
              throw Exception('An account with this email or username already exists. Please use different credentials or try logging in.');
            case 422:
              throw Exception('Please check your information. Make sure all required fields are filled correctly.');
            case 500:
              throw Exception('Server error occurred during registration. Please try again later.');
            default:
              throw Exception(message.isNotEmpty ? message : 'Registration failed. Please try again.');
          }
        }
      }
      
      // Handle connection errors
      if (e.toString().contains('Cannot connect to server')) {
        throw Exception('Cannot connect to server. Please check your internet connection and make sure the backend is running.');
      }
      
      if (e.toString().contains('timed out')) {
        throw Exception('Registration request timed out. Please check your connection and try again.');
      }
      
      // Handle parsing errors
      if (e.toString().contains('type \'Null\' is not a subtype') || 
          e.toString().contains('FormatException') ||
          e.toString().contains('TypeError')) {
        throw Exception('There was an issue processing your registration. Please try again or contact support if the problem persists.');
      }
      
      // Generic fallback
      throw Exception('Registration failed. Please check your information and try again.');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(
        '/auth/logout',
        body: {},
      );
      await _tokenManager.clearTokens();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiService.post(
        '/auth/forgot-password',
        body: {'email': email},
      );
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _apiService.post(
        '/auth/reset-password',
        body: {
          'token': token,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _apiService.post(
        '/auth/change-password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Profile Management
  Future<AuthModel> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/profile');
      return AuthModel.fromJson(response['user']);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<AuthModel> updateProfile({
    String? name,
    String? handle,
    String? bio,
    String? profilePicture,
  }) async {
    try {
      final response = await _apiService.put(
        '/auth/profile',
        body: {
          if (name != null) 'name': name,
          if (handle != null) 'handle': handle,
          if (bio != null) 'bio': bio,
          if (profilePicture != null) 'profilePicture': profilePicture,
        },
      );
      return AuthModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _apiService.delete('/auth/account');
      await _tokenManager.clearTokens();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Email Verification
  Future<void> sendVerificationEmail() async {
    try {
      await _apiService.post(
        '/auth/send-verification',
        body: {},
      );
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
      await _apiService.post(
        '/auth/verify-email',
        body: {'token': token},
      );
    } catch (e) {
      throw Exception('Failed to verify email: $e');
    }
  }

  // Session Management
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _apiService.post(
        '/auth/refresh',
        body: {'refreshToken': refreshToken},
      );

      await _tokenManager.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
        expiryDate: DateTime.parse(response['expiresAt']),
      );
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  Future<bool> isAuthenticated() async {
    return _tokenManager.hasValidTokens();
  }

  // Social Authentication
  Future<AuthModel> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiService.post(
        '/auth/google',
        body: {'idToken': idToken},
      );
      
      await _tokenManager.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
        expiryDate: DateTime.parse(response['expiresAt']),
      );
      
      return AuthModel.fromJson(response['user']);
    } catch (e) {
      throw Exception('Failed to login with Google: $e');
    }
  }

  Future<AuthModel> loginWithApple(String identityToken) async {
    try {
      final response = await _apiService.post(
        '/auth/apple',
        body: {'identityToken': identityToken},
      );
      
      await _tokenManager.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
        expiryDate: DateTime.parse(response['expiresAt']),
      );
      
      return AuthModel.fromJson(response['user']);
    } catch (e) {
      throw Exception('Failed to login with Apple: $e');
    }
  }
} 