import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/core/constants/building_constants.dart';
import 'package:imperio_tribal_app/core/constants/building_mappings.dart';
import 'package:imperio_tribal_app/data/models/building_type.dart';
import 'package:imperio_tribal_app/data/repositories/upgrade_queue_repository.dart';
import 'package:imperio_tribal_app/data/repositories/resource_repository.dart';
import 'package:imperio_tribal_app/data/models/resource_model.dart';
import 'package:imperio_tribal_app/data/models/upgrade_queue_model.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/core/game/game_resource_manager.dart';
import 'building_item.dart';

class AvailableBuildings extends StatelessWidget {
  final int villageId;
  final List<BuildingModel> buildings;
  final VoidCallback onUpgrade;
  final _resourceRepository = ResourceRepository();
  final _upgradeQueueRepository = UpgradeQueueRepository();
  final _resourceManager = GameResourceManager();

  AvailableBuildings({
    super.key,
    required this.villageId,
    required this.buildings,
    required this.onUpgrade,
  });

  Future<(ResourceModel, List<BuildingModel>, List<UpgradeQueueModel>)>
  _loadResources() async {
    final resources = await _resourceRepository.findByVillageId(villageId);
    if (resources == null) {
      throw Exception('Recursos não encontrados para a vila $villageId');
    }
    final upgrades = await _upgradeQueueRepository.findByVillageId(villageId);
    return (resources, buildings, upgrades);
  }

  bool _isAvailableForUpgrade(
    BuildingModel building,
    List<BuildingModel> allBuildings,
    List<UpgradeQueueModel> upgrades,
  ) {
    try {
      // Verifica se o edifício já está em construção
      if (upgrades.any((upgrade) => upgrade.buildingId == building.id)) {
        AppLogger.info('Edifício ${building.type} está em construção');
        return false;
      }

      AppLogger.info('Verificando disponibilidade para: ${building.type}');
      AppLogger.info('Nível atual: ${building.level}');

      final type = BuildingMappings.getBuildingType(building.type);
      if (type == null) {
        throw Exception('Tipo de edifício inválido: ${building.type}');
      }

      AppLogger.info('Tipo encontrado: $type');

      final nextLevel = building.level + 1;
      AppLogger.info('Próximo nível: $nextLevel');

      // Verifica se o próximo nível é válido
      if (!BuildingConstants.isValidLevel(type, nextLevel)) {
        AppLogger.info('Nível inválido para $type: $nextLevel');
        return false;
      }

      // Para Quartel e Estábulo, verifica os requisitos especiais
      if (type == BuildingType.barracks) {
        final townHall = allBuildings.firstWhere((b) => b.type == 'town_hall');
        AppLogger.info('Nível do Centro da Vila: ${townHall.level}');
        final isAvailable = townHall.level >= 3;
        AppLogger.info('Quartel disponível: $isAvailable');
        return isAvailable;
      }

      if (type == BuildingType.stable) {
        final townHall = allBuildings.firstWhere((b) => b.type == 'town_hall');
        final barracks = allBuildings.firstWhere((b) => b.type == 'barracks');
        AppLogger.info('Nível do Centro da Vila: ${townHall.level}');
        AppLogger.info('Nível do Quartel: ${barracks.level}');
        final isAvailable = townHall.level >= 5 && barracks.level >= 3;
        AppLogger.info('Estábulo disponível: $isAvailable');
        return isAvailable;
      }

      // Para os demais edifícios, se está na tabela, está disponível
      AppLogger.info('Edifício disponível por padrão: $type');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao verificar disponibilidade', e, stackTrace);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      (ResourceModel, List<BuildingModel>, List<UpgradeQueueModel>)
    >(
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

        final (resources, allBuildings, upgrades) = snapshot.data!;
        AppLogger.info('Total de edifícios recebidos: ${buildings.length}');
        AppLogger.info(
          'Lista de edifícios: ${buildings.map((b) => '${b.type} (${b.level})').join(', ')}',
        );

        final availableBuildings =
            buildings
                .where(
                  (building) =>
                      _isAvailableForUpgrade(building, allBuildings, upgrades),
                )
                .toList();

        AppLogger.info(
          'Total de edifícios disponíveis: ${availableBuildings.length}',
        );
        AppLogger.info(
          'Edifícios disponíveis: ${availableBuildings.map((b) => '${b.type} (${b.level})').join(', ')}',
        );

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
              AppLogger.error('Tipo de edifício inválido: ${building.type}');
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
              isLocked: !canAfford,
              lockReason: !canAfford ? 'Recursos insuficientes' : null,
              onUpgrade:
                  canAfford
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

                          // Cria o upgrade na fila
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
                          await _upgradeQueueRepository.create(upgrade);
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
