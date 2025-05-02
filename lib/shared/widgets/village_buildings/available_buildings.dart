import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/core/constants/building_constants.dart';
import 'package:imperio_tribal_app/core/constants/building_mappings.dart';
import 'package:imperio_tribal_app/data/models/building_type.dart';
import 'package:imperio_tribal_app/data/repositories/resource_repository.dart';
import 'package:imperio_tribal_app/data/models/resource_model.dart';
import 'package:imperio_tribal_app/core/game/game_resource_manager.dart';
import 'package:imperio_tribal_app/shared/controllers/village_buildings_controller.dart';
import 'building_item.dart';

class AvailableBuildings extends StatelessWidget {
  final int villageId;
  final VoidCallback onUpgrade;
  final _resourceRepository = ResourceRepository();
  final _resourceManager = GameResourceManager();
  final _buildingsController = Get.find<VillageBuildingsController>();

  AvailableBuildings({
    super.key,
    required this.villageId,
    required this.onUpgrade,
  });

  Future<(ResourceModel, List<BuildingModel>, bool)> _loadResources() async {
    final resources = await _resourceRepository.findByVillageId(villageId);
    if (resources == null) {
      throw Exception('Recursos não encontrados para a vila $villageId');
    }
    return (resources, _buildingsController.buildings, true);
  }

  bool _isAvailableForUpgrade(
    BuildingModel building,
    List<BuildingModel> allBuildings,
  ) {
    try {
      final type = BuildingMappings.getBuildingType(building.type);

      if (type == null) {
        throw Exception('Tipo de edifício inválido: ${building.type}');
      }

      final nextLevel = building.level + 1;

      // Verifica se o próximo nível é válido
      if (!BuildingConstants.isValidLevel(type, nextLevel)) {
        return false;
      }

      // Para Quartel e Estábulo, verifica os requisitos especiais
      if (type == BuildingType.barracks) {
        final townHall = allBuildings.firstWhere((b) => b.type == 'townHall');
        return townHall.level >= 3;
      }

      if (type == BuildingType.stable) {
        final townHall = allBuildings.firstWhere((b) => b.type == 'townHall');
        final barracks = allBuildings.firstWhere((b) => b.type == 'barracks');
        return townHall.level >= 5 && barracks.level >= 3;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_buildingsController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return FutureBuilder<(ResourceModel, List<BuildingModel>, bool)>(
        future: _loadResources(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final (resources, allBuildings, _) = snapshot.data!;

          // Filtra edifícios disponíveis para upgrade
          final availableBuildings =
              allBuildings.where((building) {
                return _isAvailableForUpgrade(building, allBuildings);
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
              final type = BuildingMappings.getBuildingType(building.type);
              if (type == null) {
                return const SizedBox.shrink();
              }

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
                isLocked:
                    !canAfford ||
                    _buildingsController.isBuildingCurrentlyInQueue(
                      building.id!,
                    ),
                lockReason:
                    !canAfford
                        ? 'Recursos insuficientes'
                        : _buildingsController.isBuildingCurrentlyInQueue(
                          building.id!,
                        )
                        ? 'Edifício em construção'
                        : null,
                onUpgrade:
                    canAfford &&
                            !_buildingsController.isBuildingCurrentlyInQueue(
                              building.id!,
                            )
                        ? () async {
                          try {
                            // Tenta deduzir os recursos
                            final success = await _resourceManager
                                .deductResourcesForUpgrade(
                                  villageId,
                                  upgradeCost,
                                );

                            if (!success) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erro ao deduzir recursos'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }

                            // Inicia o upgrade
                            final now = DateTime.now().millisecondsSinceEpoch;
                            final endTime = now + (buildTime * 1000);

                            final successUpgrade = await _buildingsController
                                .startUpgrade(
                                  building.id!,
                                  villageId,
                                  nextLevel,
                                  now,
                                  endTime,
                                );

                            if (successUpgrade) {
                              onUpgrade();
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erro ao iniciar upgrade'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro: $e'),
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
    });
  }
}
