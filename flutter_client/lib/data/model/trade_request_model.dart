

enum TradeStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  completed
}

class TradeRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderBookId;
  final String receiverBookId;
  final TradeStatus status;
  final String? message;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BookDetails? senderBook;
  final BookDetails? receiverBook;
  final UserProfile? senderProfile;
  final UserProfile? receiverProfile;

  TradeRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderBookId,
    required this.receiverBookId,
    required this.status,
    this.message,
    this.acceptedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.senderBook,
    this.receiverBook,
    this.senderProfile,
    this.receiverProfile,
  });

  // Create a copy of the model with some fields updated
  TradeRequestModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? senderBookId,
    String? receiverBookId,
    TradeStatus? status,
    String? message,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    BookDetails? senderBook,
    BookDetails? receiverBook,
    UserProfile? senderProfile,
    UserProfile? receiverProfile,
  }) {
    return TradeRequestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderBookId: senderBookId ?? this.senderBookId,
      receiverBookId: receiverBookId ?? this.receiverBookId,
      status: status ?? this.status,
      message: message ?? this.message,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      senderBook: senderBook ?? this.senderBook,
      receiverBook: receiverBook ?? this.receiverBook,
      senderProfile: senderProfile ?? this.senderProfile,
      receiverProfile: receiverProfile ?? this.receiverProfile,
    );
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderBookId': senderBookId,
      'receiverBookId': receiverBookId,
      'status': status.toString().split('.').last,
      'message': message,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'senderBook': senderBook?.toJson(),
      'receiverBook': receiverBook?.toJson(),
      'senderProfile': senderProfile?.toJson(),
      'receiverProfile': receiverProfile?.toJson(),
    };
  }

  // Create model from JSON
  factory TradeRequestModel.fromJson(Map<String, dynamic> json) {
    return TradeRequestModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      senderBookId: json['senderBookId'] as String,
      receiverBookId: json['receiverBookId'] as String,
      status: TradeStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TradeStatus.pending,
      ),
      message: json['message'] as String?,
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      senderBook: json['senderBook'] != null
          ? BookDetails.fromJson(json['senderBook'] as Map<String, dynamic>)
          : null,
      receiverBook: json['receiverBook'] != null
          ? BookDetails.fromJson(json['receiverBook'] as Map<String, dynamic>)
          : null,
      senderProfile: json['senderProfile'] != null
          ? UserProfile.fromJson(json['senderProfile'] as Map<String, dynamic>)
          : null,
      receiverProfile: json['receiverProfile'] != null
          ? UserProfile.fromJson(json['receiverProfile'] as Map<String, dynamic>)
          : null,
    );
  }

  // Create an empty model
  factory TradeRequestModel.empty() {
    return TradeRequestModel(
      id: '',
      senderId: '',
      receiverId: '',
      senderBookId: '',
      receiverBookId: '',
      status: TradeStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Check if the model is empty
  bool get isEmpty => id.isEmpty;

  // Check if the model is not empty
  bool get isNotEmpty => !isEmpty;

  // Accept the trade request
  TradeRequestModel accept() {
    return copyWith(
      status: TradeStatus.accepted,
      acceptedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Reject the trade request
  TradeRequestModel reject() {
    return copyWith(
      status: TradeStatus.rejected,
      updatedAt: DateTime.now(),
    );
  }

  // Cancel the trade request
  TradeRequestModel cancel() {
    return copyWith(
      status: TradeStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  // Complete the trade request
  TradeRequestModel complete() {
    return copyWith(
      status: TradeStatus.completed,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'TradeRequestModel(id: $id, senderId: $senderId, receiverId: $receiverId, senderBookId: $senderBookId, receiverBookId: $receiverBookId, status: $status, message: $message, acceptedAt: $acceptedAt, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt, senderBook: $senderBook, receiverBook: $receiverBook, senderProfile: $senderProfile, receiverProfile: $receiverProfile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TradeRequestModel &&
        other.id == id &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.senderBookId == senderBookId &&
        other.receiverBookId == receiverBookId &&
        other.status == status &&
        other.message == message &&
        other.acceptedAt == acceptedAt &&
        other.completedAt == completedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.senderBook == senderBook &&
        other.receiverBook == receiverBook &&
        other.senderProfile == senderProfile &&
        other.receiverProfile == receiverProfile;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      senderId,
      receiverId,
      senderBookId,
      receiverBookId,
      status,
      message,
      acceptedAt,
      completedAt,
      createdAt,
      updatedAt,
      senderBook,
      receiverBook,
      senderProfile,
      receiverProfile,
    );
  }
}

class BookDetails {
  final String id;
  final String title;
  final String author;
  final String? coverImage;
  final String? description;
  final double rating;
  final List<String> genres;

  BookDetails({
    required this.id,
    required this.title,
    required this.author,
    this.coverImage,
    this.description,
    required this.rating,
    required this.genres,
  });

  // Create a copy of the book details with some fields updated
  BookDetails copyWith({
    String? id,
    String? title,
    String? author,
    String? coverImage,
    String? description,
    double? rating,
    List<String>? genres,
  }) {
    return BookDetails(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      genres: genres ?? this.genres,
    );
  }

  // Convert book details to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverImage': coverImage,
      'description': description,
      'rating': rating,
      'genres': genres,
    };
  }

  // Create book details from JSON
  factory BookDetails.fromJson(Map<String, dynamic> json) {
    return BookDetails(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverImage: json['coverImage'] as String?,
      description: json['description'] as String?,
      rating: (json['rating'] as num).toDouble(),
      genres: List<String>.from(json['genres'] as List),
    );
  }

  @override
  String toString() {
    return 'BookDetails(id: $id, title: $title, author: $author, coverImage: $coverImage, description: $description, rating: $rating, genres: $genres)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookDetails &&
        other.id == id &&
        other.title == title &&
        other.author == author &&
        other.coverImage == coverImage &&
        other.description == description &&
        other.rating == rating &&
        other.genres == genres;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      author,
      coverImage,
      description,
      rating,
      Object.hashAll(genres),
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String? handle;
  final String? profilePicture;
  final String? bio;
  final List<String> hobbies;

  UserProfile({
    required this.id,
    required this.name,
    this.handle,
    this.profilePicture,
    this.bio,
    required this.hobbies,
  });

  // Create a copy of the profile with some fields updated
  UserProfile copyWith({
    String? id,
    String? name,
    String? handle,
    String? profilePicture,
    String? bio,
    List<String>? hobbies,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      hobbies: hobbies ?? this.hobbies,
    );
  }

  // Convert profile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'handle': handle,
      'profilePicture': profilePicture,
      'bio': bio,
      'hobbies': hobbies,
    };
  }

  // Create profile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      handle: json['handle'] as String?,
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] as String?,
      hobbies: List<String>.from(json['hobbies'] as List),
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, handle: $handle, profilePicture: $profilePicture, bio: $bio, hobbies: $hobbies)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.handle == handle &&
        other.profilePicture == profilePicture &&
        other.bio == bio &&
        other.hobbies == hobbies;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      handle,
      profilePicture,
      bio,
      Object.hashAll(hobbies),
    );
  }
} 