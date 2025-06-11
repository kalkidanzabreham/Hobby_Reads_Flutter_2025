import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_reads_flutter/data/model/book_model.dart';
import 'package:hobby_reads_flutter/providers/book_providers.dart';
import 'package:hobby_reads_flutter/providers/auth_providers.dart';
import 'package:hobby_reads_flutter/screens/shared/app_scaffold.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final int bookId;
  final BookModel? book; // Optional - can be passed for immediate display

  const BookDetailScreen({
    super.key,
    required this.bookId,
    this.book,
  });

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  double _userRating = 0;
  final _reviewController = TextEditingController();
  bool _showReviewForm = false;

  // List of placeholder image paths
  final List<String> _placeholderImages = const [
    'assets/images/book.jpg',
    'assets/images/one.jpg',
    'assets/images/two.jpg',
    'assets/images/three.jpg',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_userRating == 0) {
      _showErrorDialog('Please select a rating');
      return;
    }

    try {
      await ref.read(reviewsProvider(widget.bookId).notifier).addReview(
            rating: _userRating.toInt(),
            comment: _reviewController.text.trim(),
          );

      setState(() {
        _userRating = 0;
        _reviewController.clear();
        _showReviewForm = false;
      });

      _showSuccessDialog('Review submitted successfully!');
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('already reviewed')) {
        _showErrorDialog(
            'You have already reviewed this book. You can find your review below and edit or delete it if needed.');
      } else {
        _showErrorDialog(errorMessage);
      }
    }
  }

  bool _hasUserReviewed(List<Review> reviews, String? userId) {
    if (userId == null) return false;
    return reviews.any((review) => review.userId.toString() == userId);
  }

  @override
  Widget build(BuildContext context) {
    final bookAsyncValue = ref.watch(bookByIdProvider(widget.bookId));
    final reviewsState = ref.watch(reviewsProvider(widget.bookId));
    final user = ref.watch(userProvider);

    return AppScaffold(
      title: 'Book Details',
      currentRoute: '/books/detail',
      body: bookAsyncValue.when(
        data: (book) {
          if (book == null) {
            return const Center(
              child: Text('Book not found'),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book Info Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Book Cover
                            Container(
                              width: 120,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: book.coverImage != null &&
                                      book.coverImage!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        book.fullImageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildPlaceholderImage(),
                                      ),
                                    )
                                  : _buildPlaceholderImage(),
                            ),
                            const SizedBox(width: 16),
                            // Book Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.displayTitle,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'by ${book.displayAuthor}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (book.genre != null) ...[
                                    Chip(
                                      label: Text(book.genre!),
                                      backgroundColor: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        book.ownerName ?? 'Unknown Owner',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        book.displayCondition,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.description.isNotEmpty
                              ? book.description
                              : 'No description available.',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 24),

                        // Rating Summary
                        if (book.reviews.isNotEmpty) ...[
                          Row(
                            children: [
                              ...List.generate(
                                  5,
                                  (index) => Icon(
                                        Icons.star,
                                        size: 20,
                                        color: index < book.rating.round()
                                            ? Colors.amber
                                            : Colors.grey[300],
                                      )),
                              const SizedBox(width: 8),
                              Text(
                                '${book.rating.toStringAsFixed(1)} (${book.reviews.length} review${book.reviews.length == 1 ? '' : 's'})',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Reviews Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Reviews',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user != null &&
                                !_showReviewForm &&
                                !_hasUserReviewed(
                                    reviewsState.reviews, user.id))
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showReviewForm = true;
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Review'),
                              ),
                            if (user != null &&
                                _hasUserReviewed(reviewsState.reviews, user.id))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle,
                                        size: 16, color: Colors.green[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'You reviewed this book',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Review Form
                        if (_showReviewForm) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your rating',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(
                                      5,
                                      (index) => GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _userRating = index + 1;
                                              });
                                            },
                                            child: Icon(
                                              Icons.star,
                                              size: 32,
                                              color: index < _userRating
                                                  ? Colors.amber
                                                  : Colors.grey[300],
                                            ),
                                          )),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Your review (optional)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _reviewController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Share your thoughts about this book...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _userRating = 0;
                                          _reviewController.clear();
                                          _showReviewForm = false;
                                        });
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: reviewsState.isSubmitting
                                          ? null
                                          : _submitReview,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: reviewsState.isSubmitting
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text('Submit Review'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Reviews List
                        if (reviewsState.isLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else if (reviewsState.error != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Error loading reviews: ${reviewsState.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(reviewsProvider(widget.bookId)
                                            .notifier)
                                        .loadReviews();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        else if (reviewsState.reviews.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No reviews yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Be the first to review this book!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: reviewsState.reviews
                                .map((review) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: _ReviewItem(
                                        review: review,
                                        currentUserId: user?.id,
                                        onDelete: (reviewId) {
                                          ref
                                              .read(
                                                  reviewsProvider(widget.bookId)
                                                      .notifier)
                                              .deleteReview(reviewId);
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading book details',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(bookByIdProvider(widget.bookId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    final int imageIndex = widget.bookId % _placeholderImages.length;
    return Image.asset(
      _placeholderImages[imageIndex],
      fit: BoxFit.cover,
      height: 160,
      width: 120,
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;
  final String? currentUserId;
  final Function(int)? onDelete;

  const _ReviewItem({
    required this.review,
    this.currentUserId,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = currentUserId != null &&
        review.userId != null &&
        review.userId.toString() == currentUserId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrentUser ? Colors.blue[300]! : Colors.grey[200]!,
          width: isCurrentUser ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isCurrentUser ? Colors.blue[50] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text(
                  (review.username ?? 'U')[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.username ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Your Review',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (review.createdAt != null)
                      Text(
                        _formatDate(review.createdAt!),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (isCurrentUser && onDelete != null && review.id != null)
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
                5,
                (index) => Icon(
                      Icons.star,
                      size: 16,
                      color: index < review.rating
                          ? Colors.amber
                          : Colors.grey[300],
                    )),
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (review.id != null) {
                onDelete!(review.id!);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
