

class ReviewModel {
  final String id;
  final String bookId;
  final String userId;
  final String username;
  final String handle;
  final String? userProfilePicture;
  final int rating;
  final String comment;
  final int likes;
  final List<String> likedBy;
  final List<ReviewReply> replies;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.username,
    required this.handle,
    this.userProfilePicture,
    required this.rating,
    required this.comment,
    required this.likes,
    required this.likedBy,
    required this.replies,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a copy of the model with some fields updated
  ReviewModel copyWith({
    String? id,
    String? bookId,
    String? userId,
    String? username,
    String? handle,
    String? userProfilePicture,
    int? rating,
    String? comment,
    int? likes,
    List<String>? likedBy,
    List<ReviewReply>? replies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      handle: handle ?? this.handle,
      userProfilePicture: userProfilePicture ?? this.userProfilePicture,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      replies: replies ?? this.replies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'username': username,
      'handle': handle,
      'userProfilePicture': userProfilePicture,
      'rating': rating,
      'comment': comment,
      'likes': likes,
      'likedBy': likedBy,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create model from JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      handle: json['handle'] as String,
      userProfilePicture: json['userProfilePicture'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      likes: json['likes'] as int,
      likedBy: List<String>.from(json['likedBy'] as List),
      replies: (json['replies'] as List)
          .map((reply) => ReviewReply.fromJson(reply as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Create an empty model
  factory ReviewModel.empty() {
    return ReviewModel(
      id: '',
      bookId: '',
      userId: '',
      username: '',
      handle: '',
      rating: 0,
      comment: '',
      likes: 0,
      likedBy: [],
      replies: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Check if the model is empty
  bool get isEmpty => id.isEmpty;

  // Check if the model is not empty
  bool get isNotEmpty => !isEmpty;

  // Check if a user has liked the review
  bool isLikedBy(String userId) => likedBy.contains(userId);

  // Add a like to the review
  ReviewModel addLike(String userId) {
    if (!likedBy.contains(userId)) {
      return copyWith(
        likes: likes + 1,
        likedBy: [...likedBy, userId],
      );
    }
    return this;
  }

  // Remove a like from the review
  ReviewModel removeLike(String userId) {
    if (likedBy.contains(userId)) {
      return copyWith(
        likes: likes - 1,
        likedBy: likedBy.where((id) => id != userId).toList(),
      );
    }
    return this;
  }

  // Add a reply to the review
  ReviewModel addReply(ReviewReply reply) {
    return copyWith(
      replies: [...replies, reply],
    );
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, bookId: $bookId, userId: $userId, username: $username, handle: $handle, userProfilePicture: $userProfilePicture, rating: $rating, comment: $comment, likes: $likes, likedBy: $likedBy, replies: $replies, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel &&
        other.id == id &&
        other.bookId == bookId &&
        other.userId == userId &&
        other.username == username &&
        other.handle == handle &&
        other.userProfilePicture == userProfilePicture &&
        other.rating == rating &&
        other.comment == comment &&
        other.likes == likes &&
        other.likedBy == likedBy &&
        other.replies == replies &&
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
      handle,
      userProfilePicture,
      rating,
      comment,
      likes,
      Object.hashAll(likedBy),
      Object.hashAll(replies),
      createdAt,
      updatedAt,
    );
  }
}

class ReviewReply {
  final String id;
  final String userId;
  final String username;
  final String handle;
  final String? userProfilePicture;
  final String comment;
  final int likes;
  final List<String> likedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewReply({
    required this.id,
    required this.userId,
    required this.username,
    required this.handle,
    this.userProfilePicture,
    required this.comment,
    required this.likes,
    required this.likedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a copy of the reply with some fields updated
  ReviewReply copyWith({
    String? id,
    String? userId,
    String? username,
    String? handle,
    String? userProfilePicture,
    String? comment,
    int? likes,
    List<String>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewReply(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      handle: handle ?? this.handle,
      userProfilePicture: userProfilePicture ?? this.userProfilePicture,
      comment: comment ?? this.comment,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert reply to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'handle': handle,
      'userProfilePicture': userProfilePicture,
      'comment': comment,
      'likes': likes,
      'likedBy': likedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create reply from JSON
  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      handle: json['handle'] as String,
      userProfilePicture: json['userProfilePicture'] as String?,
      comment: json['comment'] as String,
      likes: json['likes'] as int,
      likedBy: List<String>.from(json['likedBy'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Check if a user has liked the reply
  bool isLikedBy(String userId) => likedBy.contains(userId);

  // Add a like to the reply
  ReviewReply addLike(String userId) {
    if (!likedBy.contains(userId)) {
      return copyWith(
        likes: likes + 1,
        likedBy: [...likedBy, userId],
      );
    }
    return this;
  }

  // Remove a like from the reply
  ReviewReply removeLike(String userId) {
    if (likedBy.contains(userId)) {
      return copyWith(
        likes: likes - 1,
        likedBy: likedBy.where((id) => id != userId).toList(),
      );
    }
    return this;
  }

  @override
  String toString() {
    return 'ReviewReply(id: $id, userId: $userId, username: $username, handle: $handle, userProfilePicture: $userProfilePicture, comment: $comment, likes: $likes, likedBy: $likedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewReply &&
        other.id == id &&
        other.userId == userId &&
        other.username == username &&
        other.handle == handle &&
        other.userProfilePicture == userProfilePicture &&
        other.comment == comment &&
        other.likes == likes &&
        other.likedBy == likedBy &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      username,
      handle,
      userProfilePicture,
      comment,
      likes,
      Object.hashAll(likedBy),
      createdAt,
      updatedAt,
    );
  }
} 