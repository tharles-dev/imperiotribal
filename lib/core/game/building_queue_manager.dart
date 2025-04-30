import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/data/repositories/building_repository.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/core/game/game_resource_manager.dart';
import 'package:imperio_tribal_app/data/repositories/upgrade_queue_repository.dart';
import 'package:imperio_tribal_app/data/models/upgrade_queue_model.dart';

class BuildingQueueManager {
  final _buildingRepository = BuildingRepository();
  final _upgradeQueueRepository = UpgradeQueueRepository();
  final _resourceManager = GameResourceManager();

  // Verifica se é um edifício de produção para recalcular recursos
  bool _isProductionBuilding(String type) {
    return type == BuildingModel.woodcutter ||
        type == BuildingModel.clayPit ||
        type == BuildingModel.ironMine;
  }

  // Processa todas as filas de construção pendentes
  Future<void> processAllQueues() async {
    try {
      AppLogger.info('Processando filas de construção...');

      // Busca todas as construções pendentes
      final pendingUpgrades = await _upgradeQueueRepository.findAllPending();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final upgrade in pendingUpgrades) {
        if (now >= upgrade.endTime) {
          await _processCompletedUpgrade(upgrade);
        }
      }

      AppLogger.info('Filas de construção processadas com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao processar filas de construção', e, stackTrace);
      rethrow;
    }
  }

  // Processa um upgrade específico que foi completado
  Future<void> _processCompletedUpgrade(UpgradeQueueModel upgrade) async {
    try {
      AppLogger.info(
        'Processando upgrade completo: Building ID ${upgrade.buildingId}, '
        'Nível alvo ${upgrade.targetLevel}',
      );

      // Atualiza o nível do edifício
      final building = await _buildingRepository.findById(upgrade.buildingId);
      if (building != null) {
        // Atualiza o nível
        await _buildingRepository.update(
          building.copyWith(level: upgrade.targetLevel),
        );

        // Marca como completed na fila
        if (upgrade.id != null) {
          await _upgradeQueueRepository.updateStatus(upgrade.id!, 'completed');
        }

        // Recalcula produção se for um edifício produtor
        if (_isProductionBuilding(building.type)) {
          await _resourceManager.calculateProduction(upgrade.villageId);
        }

        AppLogger.info(
          'Upgrade concluído com sucesso: ${building.type} '
          'para nível ${upgrade.targetLevel}',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao processar upgrade completo: ${upgrade.id}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  // Adiciona um novo upgrade à fila
  Future<void> addToQueue(
    int buildingId,
    int villageId,
    int targetLevel,
    int startTime,
    int endTime,
  ) async {
    try {
      AppLogger.info(
        'Adicionando novo upgrade à fila: Building ID $buildingId, '
        'Nível alvo $targetLevel',
      );

      final upgrade = UpgradeQueueModel(
        buildingId: buildingId,
        villageId: villageId,
        targetLevel: targetLevel,
        startTime: startTime,
        endTime: endTime,
        status: 'pending',
      );

      await _upgradeQueueRepository.create(upgrade);

      AppLogger.info('Upgrade adicionado à fila com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao adicionar upgrade à fila', e, stackTrace);
      rethrow;
    }
  }

  // Verifica se existe upgrade em andamento para um edifício
  Future<bool> hasActiveUpgrade(int buildingId) async {
    try {
      return await _upgradeQueueRepository.hasActiveUpgrade(buildingId);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao verificar upgrade ativo para building $buildingId',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  // Busca o upgrade ativo de um edifício
  Future<UpgradeQueueModel?> getActiveUpgrade(int buildingId) async {
    try {
      return await _upgradeQueueRepository.findActiveByBuildingId(buildingId);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao buscar upgrade ativo para building $buildingId',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
