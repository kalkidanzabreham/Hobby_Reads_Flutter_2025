import 'package:shared_preferences/shared_preferences.dart';

class TokenManagerRepository {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _tokenTypeKey = 'token_type';

  final SharedPreferences _prefs;

  TokenManagerRepository(this._prefs);

  // Token Management
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiryDate,
    String tokenType = 'Bearer',
  }) async {
    try {
      if (accessToken.isEmpty) {
        throw TokenException('Access token cannot be empty');
      }
      if (refreshToken.isEmpty) {
        throw TokenException('Refresh token cannot be empty');
      }
      if (expiryDate.isBefore(DateTime.now())) {
        throw TokenException('Token expiry date cannot be in the past');
      }

      await Future.wait([
        _prefs.setString(_accessTokenKey, accessToken),
        _prefs.setString(_refreshTokenKey, refreshToken),
        _prefs.setString(_tokenExpiryKey, expiryDate.toIso8601String()),
        _prefs.setString(_tokenTypeKey, tokenType),
      ]);
    } catch (e) {
      if (e is TokenException) rethrow;
      throw TokenException('Failed to save tokens: ${e.toString()}');
    }
  }

  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _prefs.remove(_accessTokenKey),
        _prefs.remove(_refreshTokenKey),
        _prefs.remove(_tokenExpiryKey),
        _prefs.remove(_tokenTypeKey),
      ]);
    } catch (e) {
      throw TokenException('Failed to clear tokens: ${e.toString()}');
    }
  }

  // Token Retrieval
  String? getAccessToken() {
    try {
      return _prefs.getString(_accessTokenKey);
    } catch (e) {
      throw TokenException('Failed to retrieve access token: ${e.toString()}');
    }
  }

  String? getRefreshToken() {
    try {
      return _prefs.getString(_refreshTokenKey);
    } catch (e) {
      throw TokenException('Failed to retrieve refresh token: ${e.toString()}');
    }
  }

  String? getTokenType() {
    try {
      return _prefs.getString(_tokenTypeKey);
    } catch (e) {
      throw TokenException('Failed to retrieve token type: ${e.toString()}');
    }
  }

  DateTime? getTokenExpiry() {
    try {
      final expiryString = _prefs.getString(_tokenExpiryKey);
      if (expiryString == null) return null;
      return DateTime.parse(expiryString);
    } catch (e) {
      throw TokenException('Failed to retrieve token expiry: ${e.toString()}');
    }
  }

  // Token Formatting
  String? getFormattedToken() {
    try {
      final token = getAccessToken();
      final type = getTokenType();
      if (token == null || type == null) return null;
      return '$type $token';
    } catch (e) {
      throw TokenException('Failed to format token: ${e.toString()}');
    }
  }

  // Token Validation
  bool hasValidTokens() {
    try {
      final accessToken = getAccessToken();
      final refreshToken = getRefreshToken();
      final expiryDate = getTokenExpiry();

      if (accessToken == null || refreshToken == null || expiryDate == null) {
        return false;
      }

      // Check if token is expired (with 5-minute buffer)
      final now = DateTime.now();
      const buffer =  Duration(minutes: 5);
      return expiryDate.isAfter(now.add(buffer));
    } catch (e) {
      throw TokenException('Failed to validate tokens: ${e.toString()}');
    }
  }

  bool isTokenExpired() {
    try {
      final expiryDate = getTokenExpiry();
      if (expiryDate == null) return true;

      // Check if token is expired (with 5-minute buffer)
      final now = DateTime.now();
      final buffer = const Duration(minutes: 5);
      return expiryDate.isBefore(now.add(buffer));
    } catch (e) {
      throw TokenException('Failed to check token expiry: ${e.toString()}');
    }
  }

  // Token Refresh Check
  bool shouldRefreshToken() {
    try {
      final expiryDate = getTokenExpiry();
      if (expiryDate == null) return false;

      // Refresh token if it expires in less than 15 minutes
      final now = DateTime.now();
      const refreshThreshold =  Duration(minutes: 15);
      return expiryDate.difference(now) < refreshThreshold;
    } catch (e) {
      throw TokenException('Failed to check token refresh status: ${e.toString()}');
    }
  }

  // Token State
  bool isAuthenticated() {
    try {
      return getAccessToken() != null && hasValidTokens();
    } catch (e) {
      throw TokenException('Failed to check authentication status: ${e.toString()}');
    }
  }

  // Token Update
  Future<void> updateAccessToken({
    required String accessToken,
    required DateTime expiryDate,
  }) async {
    try {
      if (accessToken.isEmpty) {
        throw TokenException('Access token cannot be empty');
      }
      if (expiryDate.isBefore(DateTime.now())) {
        throw TokenException('Token expiry date cannot be in the past');
      }

      await Future.wait([
        _prefs.setString(_accessTokenKey, accessToken),
        _prefs.setString(_tokenExpiryKey, expiryDate.toIso8601String()),
      ]);
    } catch (e) {
      if (e is TokenException) rethrow;
      throw TokenException('Failed to update access token: ${e.toString()}');
    }
  }

  // Token Migration (for future use)
  Future<void> migrateTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiryDate,
    String tokenType = 'Bearer',
  }) async {
    try {
      if (accessToken.isEmpty) {
        throw TokenException('Access token cannot be empty');
      }
      if (refreshToken.isEmpty) {
        throw TokenException('Refresh token cannot be empty');
      }
      if (expiryDate.isBefore(DateTime.now())) {
        throw TokenException('Token expiry date cannot be in the past');
      }

      await clearTokens();
      await saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiryDate: expiryDate,
        tokenType: tokenType,
      );
    } catch (e) {
      if (e is TokenException) rethrow;
      throw TokenException('Failed to migrate tokens: ${e.toString()}');
    }
  }

  // Token Validation
  bool validateTokenFormat(String token) {
    // Basic token format validation
    return token.isNotEmpty && token.length >= 32;
  }

  // Error Handling
  String _handleTokenError(dynamic error) {
    // TODO: Implement specific error handling for token-related operations
    return error.toString();
  }
}

class TokenException implements Exception {
  final String message;

  TokenException(this.message);

  @override
  String toString() => 'TokenException: $message';
} 