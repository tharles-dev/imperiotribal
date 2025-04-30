import 'package:imperio_tribal_app/data/models/user_model.dart';

class VillageModel {
  final int? id;
  final int userId;
  final String name;
  final int x;
  final int y;
  final DateTime createdAt;

  VillageModel({
    this.id,
    required this.userId,
    required this.name,
    required this.x,
    required this.y,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'x': x,
      'y': y,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory VillageModel.fromMap(Map<String, dynamic> map) {
    return VillageModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      x: map['x'],
      y: map['y'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  VillageModel copyWith({
    int? id,
    int? userId,
    String? name,
    int? x,
    int? y,
    DateTime? createdAt,
  }) {
    return VillageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool isNpc(UserModel user) {
    return user.isNpc;
  }

  bool get isCenter {
    return x == 3 && y == 3;
  }

  bool get isValidPosition {
    return x >= 0 && x <= 6 && y >= 0 && y <= 6;
  }

  @override
  String toString() {
    return 'VillageModel(id: $id, userId: $userId, name: $name, x: $x, y: $y, createdAt: $createdAt)';
  }
}
