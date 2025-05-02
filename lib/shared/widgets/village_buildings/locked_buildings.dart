import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/core/constants/building_constants.dart';
import 'package:imperio_tribal_app/core/constants/building_mappings.dart';
import 'package:imperio_tribal_app/data/models/building_type.dart';
import 'package:imperio_tribal_app/data/repositories/building_repository.dart';
import 'package:imperio_tribal_app/core/game/game_resource_manager.dart';
import 'building_item.dart';

class LockedBuildings extends StatelessWidget {
  final List<BuildingModel> buildings;
  final int villageId;
  final VoidCallback onBuildingCreated;

  const LockedBuildings({
    super.key,
    required this.buildings,
    required this.villageId,
    required this.onBuildingCreated,
  });

  bool _areRequirementsMet(
    BuildingType type,
    List<BuildingModel> allBuildings,
  ) {
    switch (type) {
      case BuildingType.barracks:
        final townHall = allBuildings.firstWhere(
          (b) => b.type == 'townHall',
          orElse:
              () => BuildingModel(
                id: 0,
                villageId: 0,
                type: 'townHall',
                level: 0,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
        );
        return townHall.level >= 3;

      case BuildingType.stable:
        final townHall = allBuildings.firstWhere(
          (b) => b.type == 'townHall',
          orElse:
              () => BuildingModel(
                id: 0,
                villageId: 0,
                type: 'townHall',
                level: 0,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
        );
        final barracks = allBuildings.firstWhere(
          (b) => b.type == 'barracks',
          orElse:
              () => BuildingModel(
                id: 0,
                villageId: 0,
                type: 'barracks',
                level: 0,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
        );
        return townHall.level >= 5 && barracks.level >= 3;

      default:
        return true;
    }
  }

  String _getLockReason(BuildingType type, List<BuildingModel> allBuildings) {
    switch (type) {
      case BuildingType.barracks:
        final townHall = allBuildings.firstWhere(
          (b) => b.type == 'townHall',
          orElse:
              () => BuildingModel(
                id: 0,
                villageId: 0,
                type: 'townHall',
                level: 0,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
        );
        if (townHall.level < 3) {
          return 'Requer Centro da Vila nível 3';
        }
        break;

      case BuildingType.stable:
        final townHall = allBuildings.firstWhere(
          (b) => b.type == 'townHall',
          orElse:
              () => BuildingModel(
                id: 0,
                villageId: 0,
                type: 'townHall',
                level: 0,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
        );
        final barracks = allBuildings.firstWhere(
          (b) => b.type == 'barracks',
          orElse:
              () => BuildingModel(
                id: 0,
                villageId: 0,
                type: 'barracks',
                level: 0,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
        );
        if (townHall.level < 5) {
          return 'Requer Centro da Vila nível 5';
        }
        if (barracks.level < 3) {
          return 'Requer Quartel nível 3';
        }
        break;

      case BuildingType.warehouse:
      case BuildingType.woodcutter:
      case BuildingType.clayPit:
      case BuildingType.ironMine:
      case BuildingType.farm:
      case BuildingType.townHall:
        return 'Edifício bloqueado';
    }
    return 'Edifício bloqueado';
  }

  Future<void> _createBuilding(BuildContext context, BuildingType type) async {
    try {
      final buildingRepository = BuildingRepository();
      final resourceManager = GameResourceManager();

      // Verifica se tem recursos suficientes
      final upgradeCost = BuildingConstants.calculateUpgradeCost(type, 1);
      final hasResources = await resourceManager.hasEnoughResources(
        villageId,
        upgradeCost,
      );

      if (!hasResources) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Recursos insuficientes para construir este edifício',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Cria o edifício
      final building = BuildingModel(
        villageId: villageId,
        type: type.name,
        level: 1,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await buildingRepository.create(building);

      // Deduz os recursos
      await resourceManager.deductResourcesForUpgrade(villageId, upgradeCost);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edifício construído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      onBuildingCreated();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao construir edifício: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lista de todos os tipos de edifícios possíveis
    final allTypes = BuildingType.values.map((type) => type.name).toList();

    // Filtra edifícios que não estão construídos
    final lockedBuildings =
        allTypes.where((type) {
          return !buildings.any((building) => building.type == type);
        }).toList();

    if (lockedBuildings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Edifícios Bloqueados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lockedBuildings.length,
          itemBuilder: (context, index) {
            final type = BuildingMappings.getBuildingType(
              lockedBuildings[index],
            );

            if (type == null) return const SizedBox.shrink();

            final upgradeCost = BuildingConstants.calculateUpgradeCost(type, 1);
            final buildTime = BuildingConstants.calculateBuildTime(type, 1);
            final requirementsMet = _areRequirementsMet(type, buildings);

            return BuildingItem(
              building: BuildingModel(
                id: 0,
                villageId: villageId,
                type: type.name,
                level: 0,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
              upgradeCost: upgradeCost,
              buildTime: buildTime,
              isLocked: !requirementsMet,
              lockReason:
                  requirementsMet ? null : _getLockReason(type, buildings),
              onUpgrade:
                  requirementsMet ? () => _createBuilding(context, type) : null,
            );
          },
        ),
      ],
    );
  }
}
