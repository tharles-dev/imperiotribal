import 'dart:math' as math;
import 'package:imperio_tribal_app/data/models/building_type.dart';

class BuildingConstants {
  // Níveis máximos
  static const int maxStorageLevel = 20;
  static const int maxWoodcutterLevel = 20;
  static const int maxClayPitLevel = 20;
  static const int maxIronMineLevel = 20;
  static const int maxTownHallLevel = 20;
  static const int maxFarmLevel = 20;
  static const int maxBarracksLevel = 20;
  static const int maxStableLevel = 20;

  // Capacidade base do armazém (por recurso)
  static const int baseStorageCapacity = 1000;

  // Custo base de construção/upgrade
  static const Map<BuildingType, Map<String, int>> baseCosts = {
    BuildingType.warehouse: {'wood': 100, 'clay': 100, 'iron': 100},
    BuildingType.woodcutter: {'wood': 50, 'clay': 30, 'iron': 20},
    BuildingType.clayPit: {'wood': 30, 'clay': 50, 'iron': 20},
    BuildingType.ironMine: {'wood': 20, 'clay': 30, 'iron': 50},
    BuildingType.townHall: {'wood': 200, 'clay': 200, 'iron': 200},
    BuildingType.farm: {'wood': 80, 'clay': 60, 'iron': 40},
    BuildingType.barracks: {'wood': 150, 'clay': 120, 'iron': 100},
    BuildingType.stable: {'wood': 180, 'clay': 150, 'iron': 120},
  };

  // Multiplicador de custo por nível
  static const double costMultiplier = 1.5;

  // Tempo base de construção/upgrade (em segundos)
  static const Map<BuildingType, int> baseBuildTime = {
    BuildingType.warehouse: 60,
    BuildingType.woodcutter: 30,
    BuildingType.clayPit: 30,
    BuildingType.ironMine: 30,
    BuildingType.townHall: 120,
    BuildingType.farm: 45,
    BuildingType.barracks: 90,
    BuildingType.stable: 90,
  };

  // Multiplicador de tempo por nível
  static const double timeMultiplier = 1.2;

  // Requisitos de nível para construção/upgrade
  static const Map<BuildingType, Map<String, int>> levelRequirements = {
    BuildingType.warehouse: {},
    BuildingType.woodcutter: {},
    BuildingType.clayPit: {},
    BuildingType.ironMine: {},
    BuildingType.townHall: {},
    BuildingType.farm: {},
    BuildingType.barracks: {'townHall': 3},
    BuildingType.stable: {'townHall': 5, 'barracks': 3},
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
      case BuildingType.warehouse:
        return level <= maxStorageLevel;
      case BuildingType.woodcutter:
        return level <= maxWoodcutterLevel;
      case BuildingType.clayPit:
        return level <= maxClayPitLevel;
      case BuildingType.ironMine:
        return level <= maxIronMineLevel;
      case BuildingType.townHall:
        return level <= maxTownHallLevel;
      case BuildingType.farm:
        return level <= maxFarmLevel;
      case BuildingType.barracks:
        return level <= maxBarracksLevel;
      case BuildingType.stable:
        return level <= maxStableLevel;
    }
  }

  static int getLevelRequirement(BuildingType type) {
    switch (type) {
      case BuildingType.townHall:
        return 0;
      case BuildingType.woodcutter:
        return 1;
      case BuildingType.clayPit:
        return 2;
      case BuildingType.ironMine:
        return 3;
      case BuildingType.farm:
        return 4;
      case BuildingType.barracks:
        return 5;
      case BuildingType.warehouse:
        return 6;
      case BuildingType.stable:
        return 7;
    }
  }

  // Nomes dos edifícios
  static String getBuildingName(BuildingType type) {
    switch (type) {
      case BuildingType.townHall:
        return 'Centro da Vila';
      case BuildingType.warehouse:
        return 'Armazém';
      case BuildingType.farm:
        return 'Fazenda';
      case BuildingType.woodcutter:
        return 'Lenhador';
      case BuildingType.clayPit:
        return 'Poço de Argila';
      case BuildingType.ironMine:
        return 'Mina de Ferro';
      case BuildingType.barracks:
        return 'Quartel';
      case BuildingType.stable:
        return 'Estábulo';
    }
  }
}
