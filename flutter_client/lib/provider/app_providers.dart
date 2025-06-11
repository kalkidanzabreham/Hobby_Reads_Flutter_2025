import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobby_reads_flutter/data/api/api_service.dart';
import 'package:hobby_reads_flutter/data/repository/auth_repository.dart';
import 'package:hobby_reads_flutter/data/repository/book_repository.dart';
import 'package:hobby_reads_flutter/data/repository/connection_repository.dart';
import 'package:hobby_reads_flutter/data/repository/token_manager_repository.dart';
import 'package:hobby_reads_flutter/data/repository/user_repository.dart';

class AppProviders extends ChangeNotifier {
  // Services
  late final ApiService _apiService;
  late final TokenManagerRepository _tokenManager;

  // Repositories
  late final AuthRepository _authRepository;
  late final BookRepository _bookRepository;
  late final ConnectionRepository _connectionRepository;
  late final UserRepository _userRepository;

  // Getters
  ApiService get apiService => _apiService;
  TokenManagerRepository get tokenManager => _tokenManager;
  AuthRepository get authRepository => _authRepository;
  BookRepository get bookRepository => _bookRepository;
  ConnectionRepository get connectionRepository => _connectionRepository;
  UserRepository get userRepository => _userRepository;

  // Initialize providers
  Future<void> initialize() async {
    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Initialize services
    _tokenManager = TokenManagerRepository(prefs);
    _apiService = ApiService(
      baseUrl:  "http://192.168.8.73:3000/api", 
      tokenManager: _tokenManager,
    );

    // Initialize repositories
    _authRepository = AuthRepository(_apiService, _tokenManager);
    _bookRepository = BookRepository(_apiService);
    _connectionRepository = ConnectionRepository(_apiService);
    _userRepository = UserRepository(_apiService, _tokenManager);

    notifyListeners();
  }

  // Dispose providers
  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
} 