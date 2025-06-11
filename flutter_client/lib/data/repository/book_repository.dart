import 'dart:io';
import 'dart:typed_data';
import 'package:hobby_reads_flutter/data/api/api_service.dart';
import 'package:hobby_reads_flutter/data/model/book_model.dart';
import 'package:hobby_reads_flutter/data/model/review_model.dart';
import 'package:hobby_reads_flutter/data/model/trade_request_model.dart';

class BookRepository {
  final ApiService _apiService;

  BookRepository(this._apiService);

  // Book Management
  Future<List<BookModel>> getBooks({
    int page = 1,
    int limit = 20,
    String? search,
    String? genre,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (genre != null && genre.isNotEmpty) {
        queryParams['genre'] = genre;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        '/books',
        queryParams: queryParams,
      );

      // Handle different response formats
      if (response is List) {
        return response
            .map((book) => BookModel.fromJson(book as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('data')) {
        return (response['data'] as List)
            .map((book) => BookModel.fromJson(book))
            .toList();
      } else if (response is Map && response.containsKey('books')) {
        return (response['books'] as List)
            .map((book) => BookModel.fromJson(book))
            .toList();
      }

      return [];
    } catch (e) {
      print('Get books error: $e');
      return [];
    }
  }

  Future<List<BookModel>> getMyBooks() async {
    try {
      final response = await _apiService.get('/books/my');

      if (response is List) {
        return response
            .map((book) => BookModel.fromJson(book as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('books')) {
        return (response['books'] as List)
            .map((book) => BookModel.fromJson(book))
            .toList();
      }

      return [];
    } catch (e) {
      print('Get my books error: $e');
      return [];
    }
  }

  Future<BookModel?> getBookById(int bookId) async {
    try {
      final response = await _apiService.get('/books/$bookId');

      if (response is Map) {
        if (response.containsKey('book')) {
          return BookModel.fromJson(response['book'] as Map<String, dynamic>);
        } else if (response.containsKey('data')) {
          return BookModel.fromJson(response['data'] as Map<String, dynamic>);
        } else {
          return BookModel.fromJson(response as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      print('Get book by ID error: $e');
      return null;
    }
  }

  Future<BookModel?> addBook({
    required String title,
    required String author,
    required String description,
    String? genre,
    String? bookCondition,
    String status = 'Available',
    dynamic coverImage,
  }) async {
    try {
      // If there's an image, we need to use multipart
      if (coverImage != null) {
        Uint8List imageBytes;
        String fileName;

        if (coverImage is File) {
          imageBytes = await coverImage.readAsBytes();
          fileName = coverImage.path.split('/').last;
        } else if (coverImage is Uint8List) {
          imageBytes = coverImage;
          fileName =
              'cover_${DateTime.now().millisecondsSinceEpoch}.jpg'; // Generate a filename for web
        } else {
          throw Exception('Unsupported image type');
        }

        final response = await _apiService.uploadFile(
          '/books',
          imageBytes,
          fileName,
          fields: {
            'title': title,
            'author': author,
            'description': description,
            'status': status,
            'bookCondition': bookCondition ?? 'Good',
            if (genre != null) 'genre': genre,
          },
        );

        if (response is Map) {
          if (response.containsKey('book')) {
            return BookModel.fromJson(response['book']);
          } else if (response.containsKey('data')) {
            return BookModel.fromJson(response['data']);
          }
        }
        // If response is not a map with 'book' or 'data', throw an exception
        throw Exception('Failed to parse book data from server response.');
      } else {
        // Regular JSON request without image
        final response = await _apiService.post(
          '/books',
          body: {
            'title': title,
            'author': author,
            'description': description,
            'status': status,
            'bookCondition': bookCondition ?? 'Good',
            if (genre != null) 'genre': genre,
          },
        );

        if (response is Map) {
          if (response.containsKey('book')) {
            return BookModel.fromJson(response['book'] as Map<String, dynamic>);
          } else if (response.containsKey('data')) {
            return BookModel.fromJson(response['data'] as Map<String, dynamic>);
          } else {
            return BookModel.fromJson(response as Map<String, dynamic>);
          }
        }
        // If response is not a map with 'book' or 'data', throw an exception
        throw Exception('Failed to parse book data from server response.');
      }
    } catch (e) {
      print('Add book error: $e');
      if (e is ApiException) {
        // Directly use the message from ApiException
        throw Exception(e.message);
      } else if (e.toString().contains('Cannot connect to server')) {
        throw Exception(
            'Cannot connect to server. Please check your internet connection.');
      } else {
        // For any other unexpected errors
        throw Exception('Failed to add book: ${e.toString()}');
      }
    }
  }

  Future<BookModel?> updateBook({
    required int bookId,
    String? title,
    String? author,
    String? description,
    String? genre,
    String? bookCondition,
    String? status,
    File? coverImage,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (title != null) body['title'] = title;
      if (author != null) body['author'] = author;
      if (description != null) body['description'] = description;
      if (genre != null) body['genre'] = genre;
      if (bookCondition != null) body['bookCondition'] = bookCondition;
      if (status != null) body['status'] = status;

      final response = await _apiService.put(
        '/books/$bookId',
        body: body,
      );

      if (response is Map) {
        if (response.containsKey('book')) {
          return BookModel.fromJson(response['book'] as Map<String, dynamic>);
        } else if (response.containsKey('data')) {
          return BookModel.fromJson(response['data'] as Map<String, dynamic>);
        } else {
          return BookModel.fromJson(response as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      print('Update book error: $e');
      throw Exception('Failed to update book. Please try again.');
    }
  }

  Future<bool> deleteBook(int bookId) async {
    try {
      await _apiService.delete('/books/$bookId');
      return true;
    } catch (e) {
      print('Delete book error: $e');
      if (e.toString().contains('ApiException')) {
        final errorMatch = RegExp(r'\[(\d+)\] (.+)').firstMatch(e.toString());
        if (errorMatch != null) {
          final statusCode = int.parse(errorMatch.group(1)!);
          final message = errorMatch.group(2)!;

          switch (statusCode) {
            case 403:
              throw Exception('You can only delete your own books.');
            case 404:
              throw Exception('Book not found.');
            case 500:
              throw Exception('Server error occurred. Please try again later.');
            default:
              throw Exception(
                  message.isNotEmpty ? message : 'Failed to delete book.');
          }
        }
      }

      throw Exception('Failed to delete book. Please try again.');
    }
  }

  // Review Management
  Future<List<Review>> getBookReviews(int bookId) async {
    try {
      final response = await _apiService.get('/books/$bookId/reviews');

      if (response is List) {
        return response
            .map((review) => Review.fromJson(review as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('reviews')) {
        return (response['reviews'] as List)
            .map((review) => Review.fromJson(review as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Get book reviews error: $e');
      return [];
    }
  }

  Future<Review?> addReview({
    required int bookId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _apiService.post(
        '/books/$bookId/reviews',
        body: {
          'rating': rating,
          'comment': comment,
        },
      );

      if (response is Map) {
        if (response.containsKey('review')) {
          return Review.fromJson(response['review'] as Map<String, dynamic>);
        } else if (response.containsKey('data')) {
          return Review.fromJson(response['data'] as Map<String, dynamic>);
        } else {
          return Review.fromJson(response as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      print('Add review error: $e');
      if (e.toString().contains('ApiException')) {
        final errorMatch = RegExp(r'\[(\d+)\] (.+)').firstMatch(e.toString());
        if (errorMatch != null) {
          final statusCode = int.parse(errorMatch.group(1)!);
          final message = errorMatch.group(2)!;

          switch (statusCode) {
            case 400:
              if (message.contains('already reviewed')) {
                throw Exception('You have already reviewed this book.');
              }
              throw Exception(
                  'Invalid review data. Rating must be between 1 and 5.');
            case 401:
              throw Exception('You must be logged in to add reviews.');
            case 409:
              throw Exception('You have already reviewed this book.');
            default:
              throw Exception(
                  message.isNotEmpty ? message : 'Failed to add review.');
          }
        }
      }

      throw Exception('Failed to add review. Please try again.');
    }
  }

  Future<bool> deleteReview({
    required int bookId,
    required int reviewId,
  }) async {
    try {
      await _apiService.delete('/books/$bookId/reviews/$reviewId');
      return true;
    } catch (e) {
      print('Delete review error: $e');
      throw Exception('Failed to delete review. Please try again.');
    }
  }

  // Search functionality
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final response = await _apiService.get(
        '/books/search',
        queryParams: {'q': query},
      );

      if (response is List) {
        return response.map((book) => BookModel.fromJson(book)).toList();
      } else if (response is Map && response.containsKey('books')) {
        return (response['books'] as List)
            .map((book) => BookModel.fromJson(book))
            .toList();
      }

      return [];
    } catch (e) {
      print('Search books error: $e');
      return [];
    }
  }

  // Get available genres
  Future<List<String>> getGenres() async {
    try {
      final response = await _apiService.get('/books/genres');

      if (response is List) {
        return response.cast<String>();
      } else if (response is Map && response.containsKey('genres')) {
        return (response['genres'] as List).cast<String>();
      }

      return [
        'Fiction',
        'Mystery',
        'Science Fiction',
        'Romance',
        'Biography',
        'History',
        'Self-Help',
        'Comic',
        'Fantasy',
        'Non-Fiction',
      ];
    } catch (e) {
      print('Get genres error: $e');
      // Return default genres if API fails
      return [
        'Fiction',
        'Mystery',
        'Science Fiction',
        'Romance',
        'Biography',
        'History',
        'Self-Help',
        'Comic',
        'Fantasy',
        'Non-Fiction',
      ];
    }
  }

  // Trade Management
  Future<List<TradeRequestModel>> getBookTrades({
    required String bookId,
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final response = await _apiService.get(
        '/books/$bookId/trades?${Uri(queryParameters: queryParams).query}',
      );

      return (response['data'] as List)
          .map((trade) => TradeRequestModel.fromJson(trade))
          .toList();
    } catch (e) {
      throw _handleBookError(e);
    }
  }

  Future<TradeRequestModel> createTradeRequest({
    required String bookId,
    required String offeredBookId,
    String? message,
  }) async {
    try {
      final response = await _apiService.post(
        '/books/$bookId/trades',
        body: {
          'offeredBookId': offeredBookId,
          if (message != null) 'message': message,
        },
      );
      return TradeRequestModel.fromJson(response['data']);
    } catch (e) {
      throw _handleBookError(e);
    }
  }

  Future<TradeRequestModel> updateTradeStatus({
    required String bookId,
    required String tradeId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final response = await _apiService.patch(
        '/books/$bookId/trades/$tradeId',
        body: {
          'status': status,
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );
      return TradeRequestModel.fromJson(response['data']);
    } catch (e) {
      throw _handleBookError(e);
    }
  }

  Future<void> cancelTrade({
    required String bookId,
    required String tradeId,
  }) async {
    try {
      await _apiService.delete('/books/$bookId/trades/$tradeId');
    } catch (e) {
      throw _handleBookError(e);
    }
  }

  // Book Recommendations
  Future<List<BookModel>> getRecommendedBooks({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiService.get(
        '/books/recommendations?${Uri(queryParameters: queryParams).query}',
      );

      return (response['data'] as List)
          .map((book) => BookModel.fromJson(book))
          .toList();
    } catch (e) {
      throw _handleBookError(e);
    }
  }

  Future<List<BookModel>> getSimilarBooks({
    required String bookId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiService.get(
        '/books/$bookId/similar?${Uri(queryParameters: queryParams).query}',
      );

      return (response['data'] as List)
          .map((book) => BookModel.fromJson(book))
          .toList();
    } catch (e) {
      throw _handleBookError(e);
    }
  }

  // Book Statistics
  Future<Map<String, dynamic>> getBookStatistics(String bookId) async {
    try {
      final response = await _apiService.get('/books/$bookId/statistics');
      return response['data'];
    } catch (e) {
      throw _handleBookError(e);
    }
  }

  // Error Handling
  String _handleBookError(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return 'Invalid book data provided.';
        case 401:
          return 'Authentication required.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'Book not found.';
        case 409:
          return 'A trade request already exists for this book.';
        case 422:
          return 'Invalid input data.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return error.message;
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
