import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/data/repositories/resource_repository.dart';
import 'package:imperio_tribal_app/data/repositories/building_repository.dart';
import 'package:imperio_tribal_app/core/game/production_rates.dart';

class GameResourceManager {
  final _resourceRepository = ResourceRepository();
  final _buildingRepository = BuildingRepository();

  // Mapa para controlar quais aldeias estão sendo atualizadas
  final _updatingVillages = <int>{};

  // Calcula a produção atual de recursos baseada nos níveis dos edifícios
  Future<({int wood, int clay, int iron})> calculateProduction(
    int villageId,
  ) async {
    try {
      final buildings = await _buildingRepository.findByVillageId(villageId);

      int woodProduction = 0;
      int clayProduction = 0;
      int ironProduction = 0;

      for (final building in buildings) {
        switch (building.type) {
          case BuildingModel.woodcutter:
            woodProduction +=
                ProductionRates.woodcutterBaseRate * building.level;
            break;
          case BuildingModel.clayPit:
            clayProduction += ProductionRates.clayPitBaseRate * building.level;
            break;
          case BuildingModel.ironMine:
            ironProduction += ProductionRates.ironMineBaseRate * building.level;
            break;
        }
      }

      AppLogger.info(
        'Produção calculada para aldeia $villageId: '
        'Madeira: $woodProduction, Argila: $clayProduction, Ferro: $ironProduction',
      );

      return (wood: woodProduction, clay: clayProduction, iron: ironProduction);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao calcular produção', e, stackTrace);
      rethrow;
    }
  }

  // Atualiza os recursos de uma aldeia considerando o tempo desde a última atualização
  Future<void> updateResources(int villageId, DateTime lastUpdatedAt) async {
    // Verifica se a aldeia já está sendo atualizada
    if (_updatingVillages.contains(villageId)) {
      AppLogger.warning('Aldeia $villageId já está sendo atualizada');
      return;
    }

    try {
      _updatingVillages.add(villageId);

      final now = DateTime.now();
      final secondsPassed = now.difference(lastUpdatedAt).inSeconds;

      if (secondsPassed <= 0) return;

      final production = await calculateProduction(villageId);
      final resource = await _resourceRepository.findByVillageId(villageId);

      if (resource == null) {
        AppLogger.warning('Recursos não encontrados para aldeia $villageId');
        return;
      }

      // Calcula os novos valores de recursos
      final newWood = resource.wood + (production.wood * secondsPassed);
      final newClay = resource.clay + (production.clay * secondsPassed);
      final newIron = resource.iron + (production.iron * secondsPassed);

      // Atualiza os recursos no banco com o novo timestamp
      final updatedResource = resource.copyWith(
        wood: newWood,
        clay: newClay,
        iron: newIron,
        lastUpdatedAt: now,
      );

      await _resourceRepository.update(updatedResource);

      AppLogger.info(
        'Recursos atualizados para aldeia $villageId: '
        'Madeira: $newWood, Argila: $newClay, Ferro: $newIron, '
        'Última atualização: ${now.toIso8601String()}',
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar recursos', e, stackTrace);
      rethrow;
    } finally {
      _updatingVillages.remove(villageId);
    }
  }

  // Atualiza os recursos de todas as aldeias
  Future<void> updateAllVillages() async {
    try {
      final resources = await _resourceRepository.findAll();

      for (final resource in resources) {
        await updateResources(resource.villageId, resource.lastUpdatedAt);
      }

      AppLogger.info('Recursos de todas as aldeias atualizados com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao atualizar recursos de todas as aldeias',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
