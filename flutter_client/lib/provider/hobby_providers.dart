import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_reads_flutter/data/model/hobby_model.dart';
import 'package:hobby_reads_flutter/data/repository/hobby_repository.dart';

final hobbyRepositoryProvider = Provider<HobbyRepository>((ref) {
  throw UnimplementedError('HobbyRepository provider not initialized');
});

final allHobbiesProvider = FutureProvider<List<HobbyModel>>((ref) async {
  final repository = ref.watch(hobbyRepositoryProvider);
  return repository.getAllHobbies();
});

final createHobbyProvider =
    FutureProvider.family<HobbyModel, String>((ref, name) async {
  final repository = ref.watch(hobbyRepositoryProvider);
  final hobby = await repository.createHobby(name);
  // Invalidate the hobbies list to trigger a refresh
  ref.invalidate(allHobbiesProvider);
  return hobby;
});

final deleteHobbyProvider =
    FutureProvider.family<void, String>((ref, hobbyId) async {
  final repository = ref.watch(hobbyRepositoryProvider);
  await repository.deleteHobby(hobbyId);
  // Invalidate the hobbies list to trigger a refresh
  ref.invalidate(allHobbiesProvider);
});
