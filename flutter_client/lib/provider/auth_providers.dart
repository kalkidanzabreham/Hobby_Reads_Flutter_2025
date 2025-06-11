import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_reads_flutter/data/model/auth_model.dart';
import 'package:hobby_reads_flutter/data/repository/auth_repository.dart';
import 'package:hobby_reads_flutter/data/repository/token_manager_repository.dart';
import 'package:hobby_reads_flutter/providers/api_providers.dart';

// Auth state
class AuthState {
  final AuthModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    AuthModel? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
    );
  }
}

// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final TokenManagerRepository _tokenManager;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._tokenManager, this._ref) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = _tokenManager.getAccessToken();
    if (token != null && _tokenManager.hasValidTokens()) {
      try {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } catch (e) {
        await _tokenManager.clearTokens();
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } else {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  Future<void> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authRepository.login(identifier, password);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password, String name, {String? bio, List<String>? hobbies}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        name: name,
        username: username,
        bio: bio,
        hobbies: hobbies,
      );
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _tokenManager.clearTokens();
    state = const AuthState(isAuthenticated: false);
    
    // Invalidate all connection-related providers to clear user-specific data
    _ref.invalidate(connectionRepositoryProvider);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final tokenManager = ref.watch(tokenManagerProvider);
  return AuthNotifier(authRepository, tokenManager, ref);
});

// Convenience providers
final userProvider = Provider<AuthModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
}); 