import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_reads_flutter/data/model/user_model.dart';
import 'package:hobby_reads_flutter/data/repository/user_repository.dart';
import 'package:hobby_reads_flutter/providers/api_providers.dart';

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final tokenManager = ref.watch(tokenManagerProvider);
  return UserRepository(apiService, tokenManager);
});

// Provider to fetch all users
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getAllUsers();
});

final deleteUserProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  final repository = ref.watch(userRepositoryProvider);
  await repository.deleteUser(userId);
  // Invalidate the users list to trigger a refresh
  ref.invalidate(allUsersProvider);
});
