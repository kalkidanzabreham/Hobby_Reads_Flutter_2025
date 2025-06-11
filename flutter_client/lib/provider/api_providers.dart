import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobby_reads_flutter/data/api/api_service.dart';
import 'package:hobby_reads_flutter/data/repository/auth_repository.dart';
import 'package:hobby_reads_flutter/data/repository/book_repository.dart';
import 'package:hobby_reads_flutter/data/repository/connection_repository.dart';
import 'package:hobby_reads_flutter/data/repository/token_manager_repository.dart';
import 'package:hobby_reads_flutter/data/repository/user_repository.dart';

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Token Manager provider
final tokenManagerProvider = Provider<TokenManagerRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TokenManagerRepository(prefs);
});

// API Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final tokenManager = ref.watch(tokenManagerProvider);
  return ApiService(
    baseUrl: "http://localhost:3000/api", // Updated to match your server port
    tokenManager: tokenManager,
  );
});

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final tokenManager = ref.watch(tokenManagerProvider);
  return AuthRepository(apiService, tokenManager);
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return BookRepository(apiService);
});

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ConnectionRepository(apiService);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final tokenManager = ref.watch(tokenManagerProvider);
  return UserRepository(apiService, tokenManager);
}); 