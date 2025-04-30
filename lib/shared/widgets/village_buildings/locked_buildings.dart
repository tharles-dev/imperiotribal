import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/core/constants/building_constants.dart';
import 'package:imperio_tribal_app/data/models/building_type.dart';
import 'building_item.dart';

class LockedBuildings extends StatelessWidget {
  final List<BuildingModel> buildings;

  const LockedBuildings({super.key, required this.buildings});

  @override
  Widget build(BuildContext context) {
    final lockedBuildings =
        BuildingType.values.where((type) {
          return !buildings.any(
            (building) => building.type == type.toString().split('.').last,
          );
        }).toList();

    if (lockedBuildings.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Todos os edifícios já estão construídos'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lockedBuildings.length,
      itemBuilder: (context, index) {
        final type = lockedBuildings[index];
        final upgradeCost = BuildingConstants.calculateUpgradeCost(type, 1);
        final buildTime = BuildingConstants.calculateBuildTime(type, 1);
        final levelRequirement = BuildingConstants.getLevelRequirement(type);

        final building = BuildingModel(
          id: 0,
          type: type.name,
          level: 0,
          villageId: 0,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );

        return BuildingItem(
          building: building,
          upgradeCost: upgradeCost,
          buildTime: buildTime,
          isLocked: true,
          lockReason:
              levelRequirement > 0
                  ? 'Requer Centro da Vila nível $levelRequirement'
                  : 'Edifício ainda não disponível',
          onUpgrade: null,
        );
      },
    );
  }
}
