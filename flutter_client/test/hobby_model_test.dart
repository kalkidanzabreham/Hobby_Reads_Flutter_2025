import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_reads_flutter/data/model/hobby_model.dart';

void main() {
  group('HobbyModel', () {
    test('fromJson creates a valid HobbyModel from JSON', () {
      final Map<String, dynamic> json = {
        'id': '123',
        'name': 'Reading',
        'createdAt': '2023-01-01T10:00:00Z',
        'updatedAt': '2023-01-01T11:00:00Z',
      };

      final hobby = HobbyModel.fromJson(json);

      expect(hobby.id, '123');
      expect(hobby.name, 'Reading');
      expect(hobby.createdAt, DateTime.parse('2023-01-01T10:00:00Z'));
      expect(hobby.updatedAt, DateTime.parse('2023-01-01T11:00:00Z'));
    });

    test('fromJson handles null or missing fields gracefully', () {
      final Map<String, dynamic> json = {
        'id': '456',
        'name': null, // Missing or null name
      };

      final hobby = HobbyModel.fromJson(json);

      expect(hobby.id, '456');
      expect(hobby.name, ''); // Expect empty string for null name
      expect(hobby.createdAt, isNull);
      expect(hobby.updatedAt, isNull);
    });

    test('toJson converts HobbyModel to JSON correctly', () {
      final hobby = HobbyModel(
        id: '789',
        name: 'Writing',
        createdAt: DateTime.parse('2023-02-01T12:00:00Z'),
        updatedAt: DateTime.parse('2023-02-01T13:00:00Z'),
      );

      final json = hobby.toJson();

      expect(json['id'], '789');
      expect(json['name'], 'Writing');
      expect(json['createdAt'], '2023-02-01T12:00:00.000Z');
      expect(json['updatedAt'], '2023-02-01T13:00:00.000Z');
    });
  });
}
