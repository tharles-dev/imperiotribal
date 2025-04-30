import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/core/constants/building_constants.dart';
import 'package:imperio_tribal_app/data/models/building_type.dart';
import 'package:imperio_tribal_app/data/repositories/upgrade_queue_repository.dart';
import 'package:imperio_tribal_app/data/repositories/resource_repository.dart';
import 'package:imperio_tribal_app/data/models/resource_model.dart';
import 'package:imperio_tribal_app/data/models/upgrade_queue_model.dart';
import 'building_item.dart';

class AvailableBuildings extends StatelessWidget {
  final int villageId;
  final List<BuildingModel> buildings;
  final VoidCallback onUpgrade;
  final _resourceRepository = ResourceRepository();

  AvailableBuildings({
    super.key,
    required this.villageId,
    required this.buildings,
    required this.onUpgrade,
  });

  Future<ResourceModel> _loadResources() async {
    final resources = await _resourceRepository.findByVillageId(villageId);
    if (resources == null) {
      throw Exception('Recursos não encontrados para a vila $villageId');
    }
    return resources;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResourceModel>(
      future: _loadResources(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erro ao carregar recursos: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final resources = snapshot.data!;
        final availableBuildings =
            buildings.where((building) {
              try {
                final type = BuildingType.values.firstWhere(
                  (e) => e.toString().split('.').last == building.type,
                );
                final nextLevel = building.level + 1;
                return BuildingConstants.isValidLevel(type, nextLevel);
              } catch (e) {
                return false;
              }
            }).toList();

        if (availableBuildings.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhum edifício disponível para upgrade'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availableBuildings.length,
          itemBuilder: (context, index) {
            final building = availableBuildings[index];
            final type = BuildingType.values.firstWhere(
              (e) => e.toString().split('.').last == building.type,
            );
            final nextLevel = building.level + 1;
            final upgradeCost = BuildingConstants.calculateUpgradeCost(
              type,
              nextLevel,
            );
            final buildTime = BuildingConstants.calculateBuildTime(
              type,
              nextLevel,
            );

            final canAfford =
                resources.wood >= upgradeCost['wood']! &&
                resources.clay >= upgradeCost['clay']! &&
                resources.iron >= upgradeCost['iron']!;

            return BuildingItem(
              building: building,
              upgradeCost: upgradeCost,
              buildTime: buildTime,
              isLocked: !canAfford,
              lockReason: !canAfford ? 'Recursos insuficientes' : null,
              onUpgrade:
                  canAfford
                      ? () async {
                        try {
                          final upgrade = UpgradeQueueModel(
                            buildingId: building.id!,
                            villageId: villageId,
                            targetLevel: nextLevel,
                            startTime: DateTime.now().millisecondsSinceEpoch,
                            endTime:
                                DateTime.now()
                                    .add(Duration(seconds: buildTime))
                                    .millisecondsSinceEpoch,
                            status: 'pending',
                          );
                          await UpgradeQueueRepository().create(upgrade);
                          onUpgrade();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Erro ao iniciar construção'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                      : null,
            );
          },
        );
      },
    );
  }
}
