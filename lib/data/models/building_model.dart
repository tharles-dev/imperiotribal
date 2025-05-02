import 'package:imperio_tribal_app/core/utils/logger.dart';

class BuildingModel {
  final int? id;
  final int villageId;
  final String type;
  final int level;
  final int createdAt;

  BuildingModel({
    this.id,
    required this.villageId,
    required this.type,
    required this.level,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'village_id': villageId,
      'type': type,
      'level': level,
      'created_at': createdAt,
    };
  }

  factory BuildingModel.fromMap(Map<String, dynamic> map) {
    try {
      return BuildingModel(
        id: map['id'],
        villageId: map['village_id'],
        type: map['type'],
        level: map['level'],
        createdAt: map['created_at'],
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao criar BuildingModel a partir do mapa',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  BuildingModel copyWith({
    int? id,
    int? villageId,
    String? type,
    int? level,
    int? createdAt,
  }) {
    return BuildingModel(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      type: type ?? this.type,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Tipos de edifícios disponíveis
  static const String townHall = 'townHall';
  static const String warehouse = 'warehouse';
  static const String farm = 'farm';
  static const String ironMine = 'ironMine';
  static const String clayPit = 'clayPit';
  static const String woodcutter = 'woodcutter';
  static const String barracks = 'barracks';
  static const String stable = 'stable';

  // Lista de edifícios iniciais (sem quartel e estábulo)
  static const List<String> initialBuildings = [
    townHall,
    warehouse,
    farm,
    ironMine,
    clayPit,
    woodcutter,
  ];

  // Método para criar um edifício inicial
  static BuildingModel createInitialBuilding({
    required int villageId,
    required String type,
    required int createdAt,
  }) {
    return BuildingModel(
      villageId: villageId,
      type: type,
      level: 1,
      createdAt: createdAt,
    );
  }
}
