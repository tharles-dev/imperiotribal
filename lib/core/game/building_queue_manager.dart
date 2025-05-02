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
  bool _isProcessing = false;
  final _processingLocks = <int, bool>{};

  // Verifica se é um edifício de produção para recalcular recursos
  bool _isProductionBuilding(String type) {
    return type == BuildingModel.woodcutter ||
        type == BuildingModel.clayPit ||
        type == BuildingModel.ironMine;
  }

  // Processa todas as filas de construção pendentes
  Future<void> processAllQueues() async {
    if (_isProcessing) return;

    try {
      _isProcessing = true;

      // Busca todas as construções pendentes
      final pendingUpgrades = await _upgradeQueueRepository.findAllPending();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final upgrade in pendingUpgrades) {
        if (now >= upgrade.endTime) {
          await _processCompletedUpgrade(upgrade);
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      _isProcessing = false;
    }
  }

  // Processa um upgrade específico que foi completado
  Future<void> _processCompletedUpgrade(UpgradeQueueModel upgrade) async {
    // Verifica se já está processando este upgrade
    if (_processingLocks[upgrade.buildingId] == true) {
      AppLogger.info(
        'Upgrade já está sendo processado para o edifício ${upgrade.buildingId}',
      );
      return;
    }

    try {
      _processingLocks[upgrade.buildingId] = true;
      AppLogger.info(
        'Processando upgrade concluído para edifício ${upgrade.buildingId}',
      );

      // Atualiza o nível do edifício
      final building = await _buildingRepository.findById(upgrade.buildingId);
      if (building != null) {
        AppLogger.info('Edifício encontrado: ${building.type}');

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

        // Notifica o VillageBuildingsController
        final controllerTag = 'village_${upgrade.villageId}';
        AppLogger.info(
          'Tentando notificar VillageBuildingsController com tag: $controllerTag',
        );
      } else {
        AppLogger.warning(
          'Edifício não encontrado com ID: ${upgrade.buildingId}',
        );
      }
    } catch (e) {
      AppLogger.error('Erro ao processar upgrade concluído', e);
      rethrow;
    } finally {
      _processingLocks[upgrade.buildingId] = false;
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
      final upgrade = UpgradeQueueModel(
        buildingId: buildingId,
        villageId: villageId,
        targetLevel: targetLevel,
        startTime: startTime,
        endTime: endTime,
        status: 'pending',
      );

      await _upgradeQueueRepository.create(upgrade);
    } catch (e) {
      rethrow;
    }
  }

  // Verifica se existe upgrade em andamento para um edifício
  Future<bool> hasActiveUpgrade(int buildingId) async {
    try {
      return await _upgradeQueueRepository.hasActiveUpgrade(buildingId);
    } catch (e) {
      rethrow;
    }
  }

  // Busca o upgrade ativo de um edifício
  Future<UpgradeQueueModel?> getActiveUpgrade(int buildingId) async {
    try {
      return await _upgradeQueueRepository.findActiveByBuildingId(buildingId);
    } catch (e) {
      rethrow;
    }
  }
}
