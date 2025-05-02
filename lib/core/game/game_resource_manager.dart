import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/data/repositories/resource_repository.dart';
import 'package:imperio_tribal_app/data/repositories/building_repository.dart';
import 'package:imperio_tribal_app/core/constants/production_rates.dart';
import 'package:imperio_tribal_app/core/constants/building_constants.dart';
import 'package:imperio_tribal_app/data/models/building_type.dart';

class GameResourceManager {
  final _resourceRepository = ResourceRepository();
  final _buildingRepository = BuildingRepository();

  // Calcula a produção de recursos baseada nos níveis dos edifícios
  Future<void> calculateProduction(int villageId) async {
    try {
      // Busca todos os edifícios da aldeia
      final buildings = await _buildingRepository.findByVillageId(villageId);

      // Encontra os níveis dos produtores
      final woodcutterLevel =
          buildings
              .firstWhere(
                (building) => building.type == BuildingType.woodcutter.name,
                orElse:
                    () => BuildingModel(
                      id: 0,
                      villageId: villageId,
                      type: BuildingType.woodcutter.name,
                      level: 1,
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                    ),
              )
              .level;

      final clayPitLevel =
          buildings
              .firstWhere(
                (building) => building.type == BuildingType.clayPit.name,
                orElse:
                    () => BuildingModel(
                      id: 0,
                      villageId: villageId,
                      type: BuildingType.clayPit.name,
                      level: 1,
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                    ),
              )
              .level;

      final ironMineLevel =
          buildings
              .firstWhere(
                (building) => building.type == BuildingType.ironMine.name,
                orElse:
                    () => BuildingModel(
                      id: 0,
                      villageId: villageId,
                      type: BuildingType.ironMine.name,
                      level: 1,
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                    ),
              )
              .level;

      // Calcula as taxas de produção
      final woodProduction = ProductionRates.calculateWoodProduction(
        woodcutterLevel,
      );
      final clayProduction = ProductionRates.calculateClayProduction(
        clayPitLevel,
      );
      final ironProduction = ProductionRates.calculateIronProduction(
        ironMineLevel,
      );

      // Atualiza as taxas de produção no banco
      await _resourceRepository.updateProduction(
        villageId,
        woodProduction: woodProduction,
        clayProduction: clayProduction,
        ironProduction: ironProduction,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao calcular produção', e, stackTrace);
      rethrow;
    }
  }

  // Atualiza os recursos de uma aldeia considerando o tempo passado
  Future<void> updateResources(int villageId, DateTime lastUpdatedAt) async {
    try {
      final now = DateTime.now();
      final secondsPassed = now.difference(lastUpdatedAt).inSeconds;

      if (secondsPassed <= 0) return;

      // Busca os recursos atuais
      final resources = await _resourceRepository.findByVillageId(villageId);
      if (resources == null) return;

      // Busca o nível do armazém
      final buildings = await _buildingRepository.findByVillageId(villageId);
      final storageLevel =
          buildings
              .firstWhere(
                (building) => building.type == BuildingType.warehouse.name,
                orElse:
                    () => BuildingModel(
                      id: 0,
                      villageId: villageId,
                      type: BuildingType.warehouse.name,
                      level: 1,
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                    ),
              )
              .level;

      // Calcula a capacidade máxima
      final maxCapacity = BuildingConstants.calculateStorageCapacity(
        storageLevel,
      );

      // Calcula os novos valores
      final newWood =
          resources.wood + (resources.woodProduction * secondsPassed);
      final newClay =
          resources.clay + (resources.clayProduction * secondsPassed);
      final newIron =
          resources.iron + (resources.ironProduction * secondsPassed);

      // Limita os recursos ao máximo permitido
      final limitedWood = newWood > maxCapacity ? maxCapacity : newWood;
      final limitedClay = newClay > maxCapacity ? maxCapacity : newClay;
      final limitedIron = newIron > maxCapacity ? maxCapacity : newIron;

      // Atualiza os recursos no banco
      await _resourceRepository.updateResources(
        villageId,
        wood: limitedWood,
        clay: limitedClay,
        iron: limitedIron,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar recursos', e, stackTrace);
      rethrow;
    }
  }

  // Atualiza os recursos de todas as aldeias
  Future<void> updateAllVillages() async {
    try {
      final resources = await _resourceRepository.findAll();

      for (final resource in resources) {
        await updateResources(resource.villageId, resource.lastUpdatedAt);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar todas as aldeias', e, stackTrace);
      rethrow;
    }
  }

  // Deduz recursos para uma construção
  Future<bool> deductResourcesForUpgrade(
    int villageId,
    Map<String, int> upgradeCost,
  ) async {
    try {
      // Busca os recursos atuais
      final resources = await _resourceRepository.findByVillageId(villageId);
      if (resources == null) {
        AppLogger.error('Recursos não encontrados para a vila $villageId');
        return false;
      }

      // Verifica se há recursos suficientes
      if (resources.wood < upgradeCost['wood']! ||
          resources.clay < upgradeCost['clay']! ||
          resources.iron < upgradeCost['iron']!) {
        return false;
      }

      // Deduz os recursos
      await _resourceRepository.updateResources(
        villageId,
        wood: resources.wood - upgradeCost['wood']!,
        clay: resources.clay - upgradeCost['clay']!,
        iron: resources.iron - upgradeCost['iron']!,
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao deduzir recursos para construção',
        e,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> hasEnoughResources(int villageId, Map<String, int> cost) async {
    try {
      final resources = await _resourceRepository.findByVillageId(villageId);
      if (resources == null) return false;

      return resources.wood >= (cost['wood'] ?? 0) &&
          resources.clay >= (cost['clay'] ?? 0) &&
          resources.iron >= (cost['iron'] ?? 0);
    } catch (e) {
      AppLogger.error('Erro ao verificar recursos', e);
      return false;
    }
  }
}
