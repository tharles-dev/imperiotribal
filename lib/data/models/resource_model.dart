class ResourceModel {
  final int? id;
  final int villageId;
  final int wood;
  final int clay;
  final int iron;
  final int woodProduction;
  final int clayProduction;
  final int ironProduction;
  final DateTime lastUpdatedAt;

  ResourceModel({
    this.id,
    required this.villageId,
    required this.wood,
    required this.clay,
    required this.iron,
    required this.woodProduction,
    required this.clayProduction,
    required this.ironProduction,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'village_id': villageId,
      'wood': wood,
      'clay': clay,
      'iron': iron,
      'wood_production': woodProduction,
      'clay_production': clayProduction,
      'iron_production': ironProduction,
      'last_updated_at': lastUpdatedAt.millisecondsSinceEpoch,
    };
  }

  factory ResourceModel.fromMap(Map<String, dynamic> map) {
    return ResourceModel(
      id: map['id'],
      villageId: map['village_id'],
      wood: map['wood'],
      clay: map['clay'],
      iron: map['iron'],
      woodProduction: map['wood_production'],
      clayProduction: map['clay_production'],
      ironProduction: map['iron_production'],
      lastUpdatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['last_updated_at'],
      ),
    );
  }

  ResourceModel copyWith({
    int? id,
    int? villageId,
    int? wood,
    int? clay,
    int? iron,
    int? woodProduction,
    int? clayProduction,
    int? ironProduction,
    DateTime? lastUpdatedAt,
  }) {
    return ResourceModel(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      wood: wood ?? this.wood,
      clay: clay ?? this.clay,
      iron: iron ?? this.iron,
      woodProduction: woodProduction ?? this.woodProduction,
      clayProduction: clayProduction ?? this.clayProduction,
      ironProduction: ironProduction ?? this.ironProduction,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  String toString() {
    return 'ResourceModel(id: $id, villageId: $villageId, wood: $wood, clay: $clay, iron: $iron, woodProduction: $woodProduction, clayProduction: $clayProduction, ironProduction: $ironProduction, lastUpdatedAt: $lastUpdatedAt)';
  }
}
