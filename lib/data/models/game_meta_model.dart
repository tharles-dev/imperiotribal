class GameMetaModel {
  final int? id;
  final DateTime lastOpenedAt;
  final DateTime lastSyncAt;

  GameMetaModel({
    this.id,
    required this.lastOpenedAt,
    required this.lastSyncAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'last_opened_at': lastOpenedAt.millisecondsSinceEpoch,
      'last_sync_at': lastSyncAt.millisecondsSinceEpoch,
    };
  }

  factory GameMetaModel.fromMap(Map<String, dynamic> map) {
    return GameMetaModel(
      id: map['id'],
      lastOpenedAt: DateTime.fromMillisecondsSinceEpoch(map['last_opened_at']),
      lastSyncAt: DateTime.fromMillisecondsSinceEpoch(map['last_sync_at']),
    );
  }

  GameMetaModel copyWith({
    int? id,
    DateTime? lastOpenedAt,
    DateTime? lastSyncAt,
  }) {
    return GameMetaModel(
      id: id ?? this.id,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}
