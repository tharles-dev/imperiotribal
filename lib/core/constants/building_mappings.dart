import 'package:imperio_tribal_app/data/models/building_type.dart';

class BuildingMappings {
  static const Map<String, BuildingType> typeMap = {
    'townHall': BuildingType.townHall,
    'warehouse': BuildingType.warehouse,
    'farm': BuildingType.farm,
    'ironMine': BuildingType.ironMine,
    'clayPit': BuildingType.clayPit,
    'woodcutter': BuildingType.woodcutter,
    'barracks': BuildingType.barracks,
    'stable': BuildingType.stable,
  };

  static BuildingType? getBuildingType(String type) => typeMap[type];

  static bool isValidBuildingType(String type) => typeMap.containsKey(type);
}
