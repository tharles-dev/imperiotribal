import 'package:imperio_tribal_app/data/models/building_type.dart';

class BuildingMappings {
  static const Map<String, BuildingType> typeMap = {
    'town_hall': BuildingType.townHall,
    'warehouse': BuildingType.warehouse,
    'farm': BuildingType.farm,
    'iron_mine': BuildingType.ironMine,
    'clay_pit': BuildingType.clayPit,
    'woodcutter': BuildingType.woodcutter,
    'barracks': BuildingType.barracks,
    'stable': BuildingType.stable,
  };

  static BuildingType? getBuildingType(String type) => typeMap[type];

  static bool isValidBuildingType(String type) => typeMap.containsKey(type);
}
