import 'package:hobby_reads_flutter/data/api/api_service.dart';
import 'package:hobby_reads_flutter/data/model/auth_model.dart';
import 'package:hobby_reads_flutter/data/model/book_model.dart';
import 'package:hobby_reads_flutter/data/model/review_model.dart';
import 'package:hobby_reads_flutter/data/model/trade_request_model.dart';

class AdminRepository {
  final ApiService _apiService;

  AdminRepository(this._apiService);

  // User Management
  Future<List<AuthModel>> getUsers({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (searchQuery != null) 'search': searchQuery,
      };
      final response = await _apiService.get(
        '/admin/users?${Uri(queryParameters: queryParams).query}',
      );
      return (response['data'] as List)
          .map((user) => AuthModel.fromJson(user))
          .toList();
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<AuthModel> getUserById(String userId) async {
    try {
      final response = await _apiService.get('/admin/users/$userId');
      return AuthModel.fromJson(response['data']);
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _apiService.patch(
        '/admin/users/$userId/role',
        body: {'role': role},
      );
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> suspendUser(String userId, {required String reason}) async {
    try {
      await _apiService.post(
        '/admin/users/$userId/suspend',
        body: {'reason': reason},
      );
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> unsuspendUser(String userId) async {
    try {
      await _apiService.post(
        '/admin/users/$userId/unsuspend',
        body: {},
      );
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete('/admin/users/$userId');
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  // Book Management
  Future<List<BookModel>> getPendingBooks({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/books/pending?page=$page&limit=$limit',
      );
      return (response['data'] as List)
          .map((book) => BookModel.fromJson(book))
          .toList();
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<BookModel> getBookById(String bookId) async {
    try {
      final response = await _apiService.get('/admin/books/$bookId');
      return BookModel.fromJson(response['data']);
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> addBook(BookModel book) async {
    try {
      await _apiService.post(
        '/admin/books',
        body: book.toJson(),
      );
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> updateBookDetails({
    required String bookId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _apiService.patch(
        '/admin/books/$bookId',
        body: updates,
      );
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _apiService.delete('/admin/books/$bookId');
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> approveBook(String bookId) async {
    try {
      await _apiService.post(
        '/admin/books/$bookId/approve',
        body: {'status': 'approved'},
      );
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> rejectBook(String bookId, {required String reason}) async {
    try {
      await _apiService.post(
        '/admin/books/$bookId/reject',
        body: {'reason': reason},
      );
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  // Review Management
  Future<List<ReviewModel>> getAllReviews({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/reviews?page=$page&limit=$limit',
      );
      return (response['data'] as List)
          .map((review) => ReviewModel.fromJson(review))
          .toList();
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<ReviewModel> getReviewById(String reviewId) async {
    try {
      final response = await _apiService.get('/admin/reviews/$reviewId');
      return ReviewModel.fromJson(response['data']);
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _apiService.delete('/admin/reviews/$reviewId');
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> hideReview(String reviewId) async {
    try {
      await _apiService.patch(
        '/admin/reviews/$reviewId/hide',
        body: {'isHidden': true},
      );
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  // Trade Request Management
  Future<List<TradeRequestModel>> getAllTradeRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/trades?page=$page&limit=$limit',
      );
      return (response['data'] as List)
          .map((trade) => TradeRequestModel.fromJson(trade))
          .toList();
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<TradeRequestModel> getTradeRequestById(String tradeId) async {
    try {
      final response = await _apiService.get('/admin/trades/$tradeId');
      return TradeRequestModel.fromJson(response['data']);
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> cancelTradeRequest(String tradeId) async {
    try {
      await _apiService.post(
        '/admin/trades/$tradeId/cancel',
        body: {'status': 'cancelled'},
      );
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  // Content Moderation
  Future<List<Map<String, dynamic>>> getReportedContent({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/reports?page=$page&limit=$limit',
      );
      return (response['data'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> handleReport(String reportId, {
    required String action,
    String? reason,
  }) async {
    try {
      await _apiService.post(
        '/admin/reports/$reportId/handle',
        body: {
          'action': action,
          if (reason != null) 'reason': reason,
        },
      );
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  // Analytics and Statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.get('/admin/dashboard/stats');
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<Map<String, dynamic>> getUserStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/stats/users?start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}',
      );
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<Map<String, dynamic>> getBookStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/stats/books?start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}',
      );
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  // System Settings
  Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final response = await _apiService.get('/admin/settings');
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  Future<void> updateSystemSettings(Map<String, dynamic> settings) async {
    try {
      await _apiService.patch(
        '/admin/settings',
        body: settings,
      );
    } catch (e) {
      throw _handleAdminError(e);
    }
  }

  // Error Handling
  String _handleAdminError(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 401:
          return 'Unauthorized access. Please check your admin privileges.';
        case 403:
          return 'Forbidden. You do not have permission to perform this action.';
        case 404:
          return 'Resource not found.';
        case 500:
          return 'Internal server error. Please try again later.';
        default:
          return error.message;
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  Future<List<Map<String, dynamic>>> getErrorLogs() async {
    // TODO: Implement API call to get error logs
    throw UnimplementedError();
  }
} 