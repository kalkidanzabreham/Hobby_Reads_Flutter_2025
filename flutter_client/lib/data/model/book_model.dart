class BookModel {
  final int? id;
  final String title;
  final String author;
  final String? coverImage;
  final String description;
  final int? ownerId;
  final String? status;
  final String? genre;
  final String? bookCondition;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ownerName;
  final double rating;
  final List<Review> reviews;

  BookModel({
    this.id,
    required this.title,
    required this.author,
    this.coverImage,
    required this.description,
    this.ownerId,
    this.status,
    this.genre,
    this.bookCondition,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
    this.rating = 0.0,
    this.reviews = const [],
  });

  // Create a copy of the model with some fields updated
  BookModel copyWith({
    int? id,
    String? title,
    String? author,
    String? coverImage,
    String? description,
    int? ownerId,
    String? status,
    String? genre,
    String? bookCondition,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerName,
    double? rating,
    List<Review>? reviews,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      genre: genre ?? this.genre,
      bookCondition: bookCondition ?? this.bookCondition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerName: ownerName ?? this.ownerName,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
    );
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverImage': coverImage,
      'description': description,
      'ownerId': ownerId,
      'status': status,
      'genre': genre,
      'bookCondition': bookCondition,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'ownerName': ownerName,
      'rating': rating,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }

  // Create model from JSON
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      coverImage: json['coverImage'] as String?,
      description: json['description'] as String? ?? '',
      ownerId: json['ownerId'] as int?,
      status: json['status'] as String?,
      genre: json['genre'] as String?,
      bookCondition: json['bookCondition'] as String?,
      createdAt: json['createdAt'] != null 
        ? DateTime.tryParse(json['createdAt'] as String)
        : null,
      updatedAt: json['updatedAt'] != null 
        ? DateTime.tryParse(json['updatedAt'] as String)
        : null,
      ownerName: json['ownerName'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as List?)
          ?.map((review) => Review.fromJson(review as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Create an empty model
  factory BookModel.empty() {
    return BookModel(
      title: '',
      author: '',
      description: '',
      rating: 0.0,
      reviews: [],
    );
  }

  // Helper methods
  String get displayTitle => title.isEmpty ? 'Unknown Title' : title;
  String get displayAuthor => author.isEmpty ? 'Unknown Author' : author;
  String get displayStatus => status ?? 'Not for Trade';
  String get displayCondition => bookCondition ?? 'Good';
  String get displayGenre => genre ?? 'Unknown';
  String get fullImageUrl => coverImage != null 
    ? 'http://localhost:3000/uploads/books/$coverImage' 
    : '';

  // Check if the model is empty
  bool get isEmpty => title.isEmpty && author.isEmpty;

  // Check if the model is not empty
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return 'BookModel(id: $id, title: $title, author: $author, coverImage: $coverImage, description: $description, ownerId: $ownerId, status: $status, genre: $genre, bookCondition: $bookCondition, createdAt: $createdAt, updatedAt: $updatedAt, ownerName: $ownerName, rating: $rating, reviews: ${reviews.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookModel &&
        other.id == id &&
        other.title == title &&
        other.author == author &&
        other.coverImage == coverImage &&
        other.description == description &&
        other.ownerId == ownerId &&
        other.status == status &&
        other.genre == genre &&
        other.bookCondition == bookCondition &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.ownerName == ownerName &&
        other.rating == rating;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      author,
      coverImage,
      description,
      ownerId,
      status,
      genre,
      bookCondition,
      createdAt,
      updatedAt,
      ownerName,
      rating,
    );
  }
}

class Review {
  final int? id;
  final int? bookId;
  final int? userId;
  final String? username;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Review({
    this.id,
    this.bookId,
    this.userId,
    this.username,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });

  // Convert review to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'username': username,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create review from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int?,
      bookId: json['bookId'] as int?,
      userId: json['userId'] as int?,
      username: json['username'] as String?,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] != null 
        ? DateTime.tryParse(json['createdAt'] as String)
        : null,
      updatedAt: json['updatedAt'] != null 
        ? DateTime.tryParse(json['updatedAt'] as String)
        : null,
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, bookId: $bookId, userId: $userId, username: $username, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review &&
        other.id == id &&
        other.bookId == bookId &&
        other.userId == userId &&
        other.username == username &&
        other.rating == rating &&
        other.comment == comment &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      bookId,
      userId,
      username,
      rating,
      comment,
      createdAt,
      updatedAt,
    );
  }
} 