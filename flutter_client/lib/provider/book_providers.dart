import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_reads_flutter/data/model/book_model.dart';
import 'package:hobby_reads_flutter/data/repository/book_repository.dart';
import 'package:hobby_reads_flutter/provider/api_providers.dart';

// Books state
class BooksState {
  final List<BookModel> books;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;

  const BooksState({
    this.books = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery,
  });

  BooksState copyWith({
    List<BookModel>? books,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
  }) {
    return BooksState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Books notifier
class BooksNotifier extends StateNotifier<BooksState> {
  final BookRepository _bookRepository;

  BooksNotifier(this._bookRepository) : super(const BooksState());

  Future<void> loadBooks({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    if (refresh) {
      state = const BooksState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final books = await _bookRepository.getBooks(
        page: refresh ? 1 : state.currentPage,
        limit: 20,
      );

      if (refresh) {
        state = BooksState(
          books: books,
          isLoading: false,
          hasMore: books.length >= 20,
          currentPage: books.isNotEmpty ? 2 : 1,
        );
      } else {
        state = state.copyWith(
          books: [...state.books, ...books],
          isLoading: false,
          hasMore: books.length >= 20,
          currentPage: state.currentPage + 1,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      await loadBooks(refresh: true);
      return;
    }

    state = BooksState(isLoading: true, searchQuery: query);

    try {
      final books = await _bookRepository.getBooks(search: query);
      state = BooksState(
        books: books,
        isLoading: false,
        hasMore: false,
        searchQuery: query,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> filterBooks({String? genre, String? status}) async {
    state = const BooksState(isLoading: true);

    try {
      final books = await _bookRepository.getBooks(
        genre: genre,
        status: status,
      );
      state = BooksState(
        books: books,
        isLoading: false,
        hasMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
      final newBook = await _bookRepository.addBook(
        title: title,
        author: author,
        description: description,
        genre: genre,
        bookCondition: bookCondition,
        status: status,
        coverImage: coverImage,
      );

      if (newBook != null) {
        state = state.copyWith(
          books: [newBook, ...state.books],
        );
      }

      return newBook;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
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
      final updatedBook = await _bookRepository.updateBook(
        bookId: bookId,
        title: title,
        author: author,
        description: description,
        genre: genre,
        bookCondition: bookCondition,
        status: status,
        coverImage: coverImage,
      );

      if (updatedBook != null) {
        final bookIndex = state.books.indexWhere((b) => b.id == bookId);
        if (bookIndex != -1) {
          final updatedBooks = [...state.books];
          updatedBooks[bookIndex] = updatedBook;
          state = state.copyWith(books: updatedBooks);
        }
      }

      return updatedBook;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteBook(int bookId) async {
    try {
      final success = await _bookRepository.deleteBook(bookId);
      if (success) {
        state = state.copyWith(
          books: state.books.where((book) => book.id != bookId).toList(),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSearch() {
    if (state.searchQuery != null) {
      loadBooks(refresh: true);
    }
  }
}

// My Books state for user's own books
class MyBooksState {
  final List<BookModel> books;
  final bool isLoading;
  final String? error;

  const MyBooksState({
    this.books = const [],
    this.isLoading = false,
    this.error,
  });

  MyBooksState copyWith({
    List<BookModel>? books,
    bool? isLoading,
    String? error,
  }) {
    return MyBooksState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// My Books notifier
class MyBooksNotifier extends StateNotifier<MyBooksState> {
  final BookRepository _bookRepository;

  MyBooksNotifier(this._bookRepository) : super(const MyBooksState());

  Future<void> loadMyBooks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final books = await _bookRepository.getMyBooks();
      state = MyBooksState(
        books: books,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addBook(BookModel book) async {
    state = state.copyWith(
      books: [book, ...state.books],
    );
  }

  Future<void> updateBook(BookModel book) async {
    final bookIndex = state.books.indexWhere((b) => b.id == book.id);
    if (bookIndex != -1) {
      final updatedBooks = [...state.books];
      updatedBooks[bookIndex] = book;
      state = state.copyWith(books: updatedBooks);
    }
  }

  Future<void> removeBook(int bookId) async {
    state = state.copyWith(
      books: state.books.where((book) => book.id != bookId).toList(),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Book details state for individual book
class BookDetailsState {
  final BookModel? book;
  final List<Review> reviews;
  final bool isLoading;
  final String? error;

  const BookDetailsState({
    this.book,
    this.reviews = const [],
    this.isLoading = false,
    this.error,
  });

  BookDetailsState copyWith({
    BookModel? book,
    List<Review>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return BookDetailsState(
      book: book ?? this.book,
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Book details notifier
class BookDetailsNotifier extends StateNotifier<BookDetailsState> {
  final BookRepository _bookRepository;

  BookDetailsNotifier(this._bookRepository) : super(const BookDetailsState());

  Future<void> loadBookDetails(int bookId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final book = await _bookRepository.getBookById(bookId);
      final reviews = await _bookRepository.getBookReviews(bookId);

      state = BookDetailsState(
        book: book,
        reviews: reviews,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addReview({
    required int bookId,
    required int rating,
    required String comment,
  }) async {
    try {
      final review = await _bookRepository.addReview(
        bookId: bookId,
        rating: rating,
        comment: comment,
      );

      if (review != null) {
        state = state.copyWith(
          reviews: [review, ...state.reviews],
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final booksProvider = StateNotifierProvider<BooksNotifier, BooksState>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return BooksNotifier(bookRepository);
});

final myBooksProvider =
    StateNotifierProvider<MyBooksNotifier, MyBooksState>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return MyBooksNotifier(bookRepository);
});

final bookDetailsProvider =
    StateNotifierProvider.family<BookDetailsNotifier, BookDetailsState, int>(
        (ref, bookId) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  final notifier = BookDetailsNotifier(bookRepository);
  notifier.loadBookDetails(bookId);
  return notifier;
});

// Genres provider
final genresProvider = FutureProvider<List<String>>((ref) async {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return await bookRepository.getGenres();
});

// Book search provider for real-time search
final bookSearchProvider =
    FutureProvider.family<List<BookModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final bookRepository = ref.watch(bookRepositoryProvider);
  return await bookRepository.searchBooks(query);
});

// Single book provider for simple book fetching
final bookByIdProvider =
    FutureProvider.family<BookModel?, int>((ref, bookId) async {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return await bookRepository.getBookById(bookId);
});

// Review-specific providers
class ReviewsState {
  final List<Review> reviews;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  const ReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  ReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ReviewsNotifier extends StateNotifier<ReviewsState> {
  final BookRepository _bookRepository;
  final int bookId;

  ReviewsNotifier(this._bookRepository, this.bookId)
      : super(const ReviewsState());

  Future<void> loadReviews() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reviews = await _bookRepository.getBookReviews(bookId);
      state = ReviewsState(
        reviews: reviews,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addReview({
    required int rating,
    required String comment,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final review = await _bookRepository.addReview(
        bookId: bookId,
        rating: rating,
        comment: comment,
      );

      if (review != null) {
        state = state.copyWith(
          reviews: [review, ...state.reviews],
          isSubmitting: false,
        );
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: 'Failed to add review',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      final success = await _bookRepository.deleteReview(
        bookId: bookId,
        reviewId: reviewId,
      );

      if (success) {
        state = state.copyWith(
          reviews:
              state.reviews.where((review) => review.id != reviewId).toList(),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Reviews provider for specific book
final reviewsProvider =
    StateNotifierProvider.family<ReviewsNotifier, ReviewsState, int>(
        (ref, bookId) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  final notifier = ReviewsNotifier(bookRepository, bookId);
  notifier.loadReviews();
  return notifier;
});

// Simple reviews provider for quick access
final bookReviewsProvider =
    FutureProvider.family<List<Review>, int>((ref, bookId) async {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return await bookRepository.getBookReviews(bookId);
});
