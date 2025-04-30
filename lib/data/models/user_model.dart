class UserModel {
  final int? id;
  final String name;
  final String tribe;
  final bool isNpc;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.tribe,
    required this.isNpc,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tribe': tribe,
      'is_npc': isNpc ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      tribe: map['tribe'],
      isNpc: map['is_npc'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? tribe,
    bool? isNpc,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tribe: tribe ?? this.tribe,
      isNpc: isNpc ?? this.isNpc,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, tribe: $tribe, isNpc: $isNpc, createdAt: $createdAt)';
  }
}
