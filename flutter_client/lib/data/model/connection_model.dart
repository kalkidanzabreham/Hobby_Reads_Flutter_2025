import 'package:hobby_reads_flutter/data/model/auth_model.dart';

class ConnectionModel {
  final String id;
  final String userId;
  final String? connectedUserId;
  final String status;
  final String name;
  final String username;
  final String bio;
  final List<String> hobbies;
  final int matchPercentage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ConnectionModel({
    required this.id,
    required this.userId,
    this.connectedUserId,
    required this.status,
    required this.name,
    required this.username,
    required this.bio,
    required this.hobbies,
    required this.matchPercentage,
    required this.createdAt,
    this.updatedAt,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    try {
      return ConnectionModel(
        id: json['id'].toString(),
        userId: json['userId'].toString(),
        connectedUserId: json['connectedUserId']?.toString(),
        status: json['status'] as String? ?? 'pending',
        name: json['name'] as String? ?? '',
        username: json['username'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        hobbies: (json['hobbies'] as List<dynamic>?)?.cast<String>() ?? [],
        matchPercentage: json['matchPercentage'] as int? ?? 0,
        createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
        updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      );
    } catch (e) {
      throw FormatException('Failed to parse ConnectionModel from JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'userId': userId,
        'connectedUserId': connectedUserId,
        'status': status,
        'name': name,
        'username': username,
        'bio': bio,
        'hobbies': hobbies,
        'matchPercentage': matchPercentage,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
    } catch (e) {
      throw FormatException('Failed to convert ConnectionModel to JSON: $e');
    }
  }

  ConnectionModel copyWith({
    String? id,
    String? userId,
    String? connectedUserId,
    String? status,
    String? name,
    String? username,
    String? bio,
    List<String>? hobbies,
    int? matchPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    try {
      return ConnectionModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        connectedUserId: connectedUserId ?? this.connectedUserId,
        status: status ?? this.status,
        name: name ?? this.name,
        username: username ?? this.username,
        bio: bio ?? this.bio,
        hobbies: hobbies ?? this.hobbies,
        matchPercentage: matchPercentage ?? this.matchPercentage,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
    } catch (e) {
      throw FormatException('Failed to create copy of ConnectionModel: $e');
    }
  }

  // Helper getters
  String get displayName => name.isEmpty ? username : name;
  String get initial => displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  List<String> get interests => hobbies;

  @override
  String toString() {
    return 'ConnectionModel(id: $id, userId: $userId, connectedUserId: $connectedUserId, status: $status, name: $name, username: $username, bio: $bio, hobbies: $hobbies, matchPercentage: $matchPercentage, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectionModel &&
        other.id == id &&
        other.userId == userId &&
        other.connectedUserId == connectedUserId &&
        other.status == status &&
        other.name == name &&
        other.username == username &&
        other.bio == bio &&
        other.hobbies == hobbies &&
        other.matchPercentage == matchPercentage &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      connectedUserId,
      status,
      name,
      username,
      bio,
      hobbies,
      matchPercentage,
      createdAt,
      updatedAt,
    );
  }
}