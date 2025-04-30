import 'dart:math' as math;
import 'package:imperio_tribal_app/data/models/building_type.dart';

class BuildingConstants {
  // Níveis máximos
  static const int maxStorageLevel = 20;
  static const int maxWoodcutterLevel = 20;
  static const int maxClayPitLevel = 20;
  static const int maxIronMineLevel = 20;

  // Capacidade base do armazém (por recurso)
  static const int baseStorageCapacity = 1000;

  // Custo base de construção/upgrade
  static const Map<BuildingType, Map<String, int>> baseCosts = {
    BuildingType.storage: {'wood': 100, 'clay': 100, 'iron': 100},
    BuildingType.woodcutter: {'wood': 50, 'clay': 30, 'iron': 20},
    BuildingType.clayPit: {'wood': 30, 'clay': 50, 'iron': 20},
    BuildingType.ironMine: {'wood': 20, 'clay': 30, 'iron': 50},
  };

  // Multiplicador de custo por nível
  static const double costMultiplier = 1.5;

  // Tempo base de construção/upgrade (em segundos)
  static const Map<BuildingType, int> baseBuildTime = {
    BuildingType.storage: 60,
    BuildingType.woodcutter: 30,
    BuildingType.clayPit: 30,
    BuildingType.ironMine: 30,
  };

  // Multiplicador de tempo por nível
  static const double timeMultiplier = 1.2;

  // Requisitos de nível para construção/upgrade
  static const Map<BuildingType, Map<String, int>> levelRequirements = {
    BuildingType.storage: {'woodcutter': 1, 'clayPit': 1, 'ironMine': 1},
    BuildingType.woodcutter: {'storage': 1},
    BuildingType.clayPit: {'storage': 1},
    BuildingType.ironMine: {'storage': 1},
  };

  static int calculateStorageCapacity(int level) {
    return (baseStorageCapacity * math.pow(1.347, level - 1)).round();
  }

  // Calcula o custo de upgrade baseado no nível
  static Map<String, int> calculateUpgradeCost(
    BuildingType type,
    int currentLevel,
  ) {
    final baseCost = baseCosts[type]!;
    final multiplier = currentLevel * costMultiplier;

    return {
      'wood': (baseCost['wood']! * multiplier).toInt(),
      'clay': (baseCost['clay']! * multiplier).toInt(),
      'iron': (baseCost['iron']! * multiplier).toInt(),
    };
  }

  // Calcula o tempo de construção/upgrade baseado no nível
  static int calculateBuildTime(BuildingType type, int currentLevel) {
    final baseTime = baseBuildTime[type]!;
    return (baseTime * (currentLevel * timeMultiplier)).toInt();
  }

  // Verifica se o nível é válido para o tipo de edifício
  static bool isValidLevel(BuildingType type, int level) {
    switch (type) {
      case BuildingType.storage:
        return level <= maxStorageLevel;
      case BuildingType.woodcutter:
        return level <= maxWoodcutterLevel;
      case BuildingType.clayPit:
        return level <= maxClayPitLevel;
      case BuildingType.ironMine:
        return level <= maxIronMineLevel;
    }
  }
}
