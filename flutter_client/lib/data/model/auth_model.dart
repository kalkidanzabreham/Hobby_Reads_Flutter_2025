class AuthModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final String? profilePicture;
  final String? bio;
  final List<HobbyModel> hobbies;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;

  AuthModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.profilePicture,
    this.bio,
    required this.hobbies,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a copy of the model with some fields updated
  AuthModel copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? profilePicture,
    String? bio,
    List<HobbyModel>? hobbies,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      hobbies: hobbies ?? this.hobbies,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'bio': bio,
      'hobbies': hobbies.map((hobby) => hobby.toJson()).toList(),
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create model from JSON
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'].toString(),
      username: json['username'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] as String?,
      hobbies: (json['hobbies'] as List<dynamic>?)
          ?.map((hobby) => HobbyModel.fromJson(hobby as Map<String, dynamic>))
          .toList() ?? [],
      isAdmin: _parseBool(json['isAdmin']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.parse(json['createdAt'] as String), // Use createdAt as fallback
    );
  }

  // Helper method to parse boolean values that might come as int or bool
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  // Create an empty model
  factory AuthModel.empty() {
    return AuthModel(
      id: '',
      username: '',
      name: '',
      email: '',
      hobbies: [],
      isAdmin: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Check if the model is empty
  bool get isEmpty => id.isEmpty;

  // Check if the model is not empty
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return 'AuthModel(id: $id, username: $username, name: $name, email: $email, profilePicture: $profilePicture, bio: $bio, hobbies: $hobbies, isAdmin: $isAdmin, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthModel &&
        other.id == id &&
        other.username == username &&
        other.name == name &&
        other.email == email &&
        other.profilePicture == profilePicture &&
        other.bio == bio &&
        other.hobbies == hobbies &&
        other.isAdmin == isAdmin &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      username,
      name,
      email,
      profilePicture,
      bio,
      Object.hashAll(hobbies),
      isAdmin,
      createdAt,
      updatedAt,
    );
  }
}

class HobbyModel {
  final String id;
  final String name;

  HobbyModel({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory HobbyModel.fromJson(Map<String, dynamic> json) {
    return HobbyModel(
      id: json['id'].toString(),
      name: json['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HobbyModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode {
    return Object.hash(id, name);
  }

  @override
  String toString() {
    return 'HobbyModel(id: $id, name: $name)';
  }
} 