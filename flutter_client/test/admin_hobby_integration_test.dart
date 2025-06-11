import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_reads_flutter/data/api/api_service.dart';
import 'package:hobby_reads_flutter/data/model/hobby_model.dart';
import 'package:hobby_reads_flutter/providers/api_providers.dart';
import 'package:hobby_reads_flutter/screens/admin/add_hobby_screen.dart';
import 'package:hobby_reads_flutter/screens/admin/admin_scaffold.dart';
import 'package:hobby_reads_flutter/screens/admin/hobbies_screen.dart';
import 'package:hobby_reads_flutter/data/repository/token_manager_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Mock SharedPreferences for testing
class MockSharedPreferences implements SharedPreferences {
  final Map<String, Object> _data = <String, Object>{};

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }

  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  Object? get(String key) => _data[key];

  @override
  Future<void> reload() async {}

  @override
  Future<bool> commit() async => true;
}

// A simple fake ApiService for testing
class FakeApiService implements ApiService {
  final String baseUrl;
  final TokenManagerRepository _tokenManager;
  final http.Client _client;
  Map<String, dynamic> _mockData = {};
  int _nextHobbyId = 1;

  FakeApiService({
    this.baseUrl = 'http://localhost:3000',
    SharedPreferences? sharedPreferences,
    http.Client? client,
  })  : _tokenManager = TokenManagerRepository(
            sharedPreferences ?? MockSharedPreferences()),
        _client = client ?? http.Client();

  @override
  Future<dynamic> delete(String endpoint,
      {Map<String, String>? queryParams, bool requiresAuth = true}) async {
    if (endpoint.startsWith('/hobbies/')) {
      final id = endpoint.split('/').last;
      if (_mockData.containsKey(id)) {
        _mockData.remove(id);
        return {'message': 'Deleted successfully'};
      }
    }
    return {'message': 'Not found'};
  }

  @override
  Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParams, bool requiresAuth = true}) async {
    if (endpoint == '/hobbies') {
      return _mockData.values.toList();
    }
    return {};
  }

  @override
  Future<dynamic> post(String endpoint,
      {Map<String, dynamic>? body,
      Map<String, String>? queryParams,
      bool requiresAuth = true}) async {
    if (endpoint == '/hobbies' && body != null && body.containsKey('name')) {
      final newHobby = HobbyModel(
        id: (_nextHobbyId++).toString(),
        name: body['name'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _mockData[newHobby.id] = newHobby.toJson();
      return {
        'message': 'Hobby created successfully',
        'hobby': newHobby.toJson()
      };
    }
    return {};
  }

  @override
  Future<dynamic> put(String endpoint,
      {Map<String, dynamic>? body,
      Map<String, String>? queryParams,
      bool requiresAuth = true}) async {
    return {}; // Not implemented for this test
  }

  @override
  Future<dynamic> patch(String endpoint,
      {Map<String, dynamic>? body,
      Map<String, String>? queryParams,
      bool requiresAuth = true}) async {
    return {}; // Not implemented for this test
  }

  @override
  Future<dynamic> uploadFile(
      String endpoint, List<int> fileBytes, String fileName,
      {Map<String, String>? fields, bool requiresAuth = true}) async {
    return {}; // Not implemented for this test
  }

  @override
  void dispose() {
    _client.close();
  }
}

void main() {
  group('Admin Hobby Integration Test', () {
    late FakeApiService fakeApiService;

    setUp(() {
      fakeApiService = FakeApiService();
    });

    testWidgets('Admin can add and delete a hobby',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(fakeApiService),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => AdminScaffold(
                currentRoute: '/admin/hobbies',
                body: const AdminHobbiesScreen(),
              ),
            ),
            routes: {
              '/admin/hobbies/add': (context) => const AddHobbyScreen(),
            },
          ),
        ),
      );

      // Initial state: No hobbies should be displayed
      expect(find.text('No hobbies found.'), findsOneWidget);

      // --- Test Adding a Hobby ---
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Add New Hobby'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Basketball');
      await tester.tap(find.text('Add Hobby'));
      await tester.pumpAndSettle();

      // Verify success snackbar
      expect(find.text('Hobby added successfully'), findsOneWidget);

      // Verify that we are back on the hobbies screen and the hobby is displayed
      expect(find.text('Basketball'), findsOneWidget);

      // --- Test Deleting a Hobby ---
      // Find the hobby's menu button and tap it
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // Tap the delete option
      await tester.tap(find.text('Delete').first);
      await tester.pumpAndSettle();

      // Confirm deletion dialog
      expect(find.text('Delete Hobby'), findsOneWidget);
      expect(
          find.text(
              'Are you sure you want to delete Basketball? This action cannot be undone.'),
          findsOneWidget);

      await tester.tap(find
          .text('Delete')
          .last); // Tap the second 'Delete' button in the dialog
      await tester.pumpAndSettle();

      // Verify success snackbar
      expect(find.text('Hobby deleted successfully'), findsOneWidget);

      // Verify that the hobby is no longer displayed
      expect(find.text('Basketball'), findsNothing);
      expect(find.text('No hobbies found.'), findsOneWidget);
    });
  });
}
