class HobbyModel {
  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HobbyModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory HobbyModel.fromJson(Map<String, dynamic> json) {
    return HobbyModel(
      id: json['id'].toString(),
      name: json['name'] is String ? json['name'] as String : '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HobbyModel &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);

  @override
  String toString() {
    return 'HobbyModel(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
