class UserModel {
  final String id;
  final String email;
  final String name;
  final String username;
  final String? displayName;
  final String? bio;
  final String? profilePicture;
  final List<HobbyModel>? hobbies;
  final Map<String, dynamic>? preferences;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final Map<String, bool>? notificationSettings;
  final Map<String, bool>? privacySettings;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.username,
    this.displayName,
    this.bio,
    this.profilePicture,
    this.hobbies,
    this.preferences,
    required this.isEmailVerified,
    this.createdAt,
    this.updatedAt,
    required this.isActive,
    this.notificationSettings,
    this.privacySettings,
    required this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String id = '';
    String email = '';
    String name = '';
    String username = '';
    String? displayName;
    String? bio;
    String? profilePicture;
    List<HobbyModel>? hobbies;
    Map<String, dynamic>? preferences;
    bool isEmailVerified = false;
    DateTime? createdAt;
    DateTime? updatedAt;
    bool isActive = false;
    Map<String, bool>? notificationSettings;
    Map<String, bool>? privacySettings;
    bool isAdmin = false;

    try {
      id = json['id']?.toString() ?? '';
    } catch (e) {
      print(
          "Error parsing id: $e, Value: ${json['id']}, Type: ${json['id'].runtimeType}");
    }
    try {
      email = json['email'] is String ? json['email'] as String : '';
    } catch (e) {
      print(
          "Error parsing email: $e, Value: ${json['email']}, Type: ${json['email'].runtimeType}");
    }
    try {
      name = json['name'] is String ? json['name'] as String : '';
    } catch (e) {
      print(
          "Error parsing name: $e, Value: ${json['name']}, Type: ${json['name'].runtimeType}");
    }
    try {
      username = json['username'] is String ? json['username'] as String : '';
    } catch (e) {
      print(
          "Error parsing username: $e, Value: ${json['username']}, Type: ${json['username'].runtimeType}");
    }
    try {
      displayName =
      json['displayName'] is String ? json['displayName'] as String : null;
    } catch (e) {
      print(
          "Error parsing displayName: $e, Value: ${json['displayName']}, Type: ${json['displayName'].runtimeType}");
    }
    try {
      bio = json['bio'] is String ? json['bio'] as String : null;
    } catch (e) {
      print(
          "Error parsing bio: $e, Value: ${json['bio']}, Type: ${json['bio'].runtimeType}");
    }
    try {
      profilePicture = json['profilePicture'] is String
          ? json['profilePicture'] as String
          : null;
    } catch (e) {
      print(
          "Error parsing profilePicture: $e, Value: ${json['profilePicture']}, Type: ${json['profilePicture'].runtimeType}");
    }
    try {
      hobbies = (json['hobbies'] as List<dynamic>?)
          ?.map((e) => HobbyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(
          "Error parsing hobbies: $e, Value: ${json['hobbies']}, Type: ${json['hobbies'].runtimeType}");
    }
    try {
      preferences = json['preferences'] as Map<String, dynamic>?;
    } catch (e) {
      print(
          "Error parsing preferences: $e, Value: ${json['preferences']}, Type: ${json['preferences'].runtimeType}");
    }
    try {
      isEmailVerified = json['isEmailVerified'] == true;
    } catch (e) {
      print(
          "Error parsing isEmailVerified: $e, Value: ${json['isEmailVerified']}, Type: ${json['isEmailVerified'].runtimeType}");
    }
    try {
      createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    } catch (e) {
      print(
          "Error parsing createdAt: $e, Value: ${json['createdAt']}, Type: ${json['createdAt'].runtimeType}");
    }
    try {
      updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');
    } catch (e) {
      print(
          "Error parsing updatedAt: $e, Value: ${json['updatedAt']}, Type: ${json['updatedAt'].runtimeType}");
    }
    try {
      isActive = json['isActive'] == true;
    } catch (e) {
      print(
          "Error parsing isActive: $e, Value: ${json['isActive']}, Type: ${json['isActive'].runtimeType}");
    }
    try {
      notificationSettings =
          (json['notificationSettings'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, value == true),
          );
    } catch (e) {
      print(
          "Error parsing notificationSettings: $e, Value: ${json['notificationSettings']}, Type: ${json['notificationSettings'].runtimeType}");
    }
    try {
      privacySettings = (json['privacySettings'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value == true),
      );
    } catch (e) {
      print(
          "Error parsing privacySettings: $e, Value: ${json['privacySettings']}, Type: ${json['privacySettings'].runtimeType}");
    }
    try {
      isAdmin = json['isAdmin'] == true;
    } catch (e) {
      print(
          "Error parsing isAdmin: $e, Value: ${json['isAdmin']}, Type: ${json['isAdmin'].runtimeType}");
    }

    return UserModel(
      id: id,
      email: email,
      name: name,
      username: username,
      displayName: displayName,
      bio: bio,
      profilePicture: profilePicture,
      hobbies: hobbies,
      preferences: preferences,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      notificationSettings: notificationSettings,
      privacySettings: privacySettings,
      isAdmin: isAdmin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'profilePicture': profilePicture,
      'hobbies': hobbies?.map((h) => h.toJson()).toList(),
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'notificationSettings': notificationSettings,
      'privacySettings': privacySettings,
      'isAdmin': isAdmin,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? username,
    String? displayName,
    String? bio,
    String? profilePicture,
    List<HobbyModel>? hobbies,
    Map<String, dynamic>? preferences,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, bool>? notificationSettings,
    Map<String, bool>? privacySettings,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      hobbies: hobbies ?? this.hobbies,
      preferences: preferences ?? this.preferences,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      privacySettings: privacySettings ?? this.privacySettings,
      isAdmin: isAdmin ?? this.isAdmin,
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

  factory HobbyModel.fromJson(Map<String, dynamic> json) {
    return HobbyModel(
      id: json['id'].toString(),
      name: json['name'] is String ? json['name'] as String : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HobbyModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() {
    return 'HobbyModel(id: $id, name: $name)';
  }
}
