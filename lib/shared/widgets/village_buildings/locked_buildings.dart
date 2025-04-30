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
    // Mapeamento direto entre os nomes do enum e do banco
    final typeMap = {
      BuildingType.townHall: 'town_hall',
      BuildingType.warehouse: 'warehouse',
      BuildingType.farm: 'farm',
      BuildingType.ironMine: 'iron_mine',
      BuildingType.clayPit: 'clay_pit',
      BuildingType.woodcutter: 'woodcutter',
      BuildingType.barracks: 'barracks',
      BuildingType.stable: 'stable',
    };

    final lockedBuildings =
        BuildingType.values.where((type) {
          final dbType = typeMap[type];
          if (dbType == null) {
            return false;
          }

          final isLocked = !buildings.any((b) => b.type == dbType);

          return isLocked;
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Edifícios Bloqueados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (lockedBuildings.isEmpty)
          const Text('Nenhum edifício bloqueado')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                lockedBuildings.map((type) {
                  final building = BuildingModel(
                    id: 0,
                    type: typeMap[type]!,
                    level: 0,
                    villageId: 0,
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                  );

                  String lockReason;
                  if (type == BuildingType.barracks) {
                    lockReason = 'Requer Centro da Vila nível 3';
                  } else if (type == BuildingType.stable) {
                    lockReason =
                        'Requer Centro da Vila nível 5 e Quartel nível 3';
                  } else {
                    lockReason = 'Edifício ainda não disponível';
                  }

                  final upgradeCost = BuildingConstants.calculateUpgradeCost(
                    type,
                    1,
                  );
                  final buildTime = BuildingConstants.calculateBuildTime(
                    type,
                    1,
                  );

                  return BuildingItem(
                    building: building,
                    upgradeCost: upgradeCost,
                    buildTime: buildTime,
                    isLocked: true,
                    lockReason: lockReason,
                    onUpgrade: null,
                  );
                }).toList(),
          ),
      ],
    );
  }
}
