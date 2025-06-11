import 'package:hobby_reads_flutter/data/api/api_service.dart';
import 'package:hobby_reads_flutter/data/model/hobby_model.dart';

class HobbyRepository {
  final ApiService _apiService;

  HobbyRepository(this._apiService);

  Future<List<HobbyModel>> getAllHobbies() async {
    try {
      final response = await _apiService.get('/hobbies');
      print(
          'Get All Hobbies API Response: $response, Type: ${response.runtimeType}');
      final List<dynamic> hobbiesJson = response;
      return hobbiesJson.map((json) => HobbyModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get hobbies: $e');
    }
  }

  Future<HobbyModel> createHobby(String name) async {
    try {
      final response = await _apiService.post('/hobbies', body: {'name': name});
      print(
          'Create Hobby API Response: $response, Type: ${response.runtimeType}');
      return HobbyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create hobby: $e');
    }
  }

  Future<void> deleteHobby(String hobbyId) async {
    try {
      await _apiService.delete('/hobbies/$hobbyId');
    } catch (e) {
      throw Exception('Failed to delete hobby: $e');
    }
  }
}
