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
      AppLogger.info(
        'Total de construções pendentes: ${pendingUpgrades.length}',
      );

      final now = DateTime.now().millisecondsSinceEpoch;
      AppLogger.info(
        'Tempo atual: ${DateTime.fromMillisecondsSinceEpoch(now)}',
      );

      for (final upgrade in pendingUpgrades) {
        AppLogger.info(
          'Verificando upgrade: Building ID ${upgrade.buildingId}, '
          'Tempo final: ${DateTime.fromMillisecondsSinceEpoch(upgrade.endTime)}, '
          'Status: ${upgrade.status}',
        );

        if (now >= upgrade.endTime) {
          AppLogger.info(
            'Upgrade pronto para processamento: Building ID ${upgrade.buildingId}',
          );
          await _processCompletedUpgrade(upgrade);
        } else {
          AppLogger.info(
            'Upgrade ainda em andamento: Building ID ${upgrade.buildingId}, '
            'Tempo restante: ${(upgrade.endTime - now) / 1000} segundos',
          );
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
        'Nível alvo ${upgrade.targetLevel}, '
        'Tempo final: ${DateTime.fromMillisecondsSinceEpoch(upgrade.endTime)}',
      );

      // Atualiza o nível do edifício
      final building = await _buildingRepository.findById(upgrade.buildingId);
      if (building != null) {
        AppLogger.info(
          'Edifício encontrado: ${building.type} (ID: ${building.id})',
        );

        // Atualiza o nível
        await _buildingRepository.update(
          building.copyWith(level: upgrade.targetLevel),
        );
        AppLogger.info(
          'Nível do edifício atualizado para ${upgrade.targetLevel}',
        );

        // Marca como completed na fila
        if (upgrade.id != null) {
          await _upgradeQueueRepository.updateStatus(upgrade.id!, 'completed');
          AppLogger.info('Status do upgrade atualizado para completed');
        }

        // Recalcula produção se for um edifício produtor
        if (_isProductionBuilding(building.type)) {
          AppLogger.info(
            'Recalculando produção para edifício ${building.type}',
          );
          await _resourceManager.calculateProduction(upgrade.villageId);
        }

        AppLogger.info(
          'Upgrade concluído com sucesso: ${building.type} '
          'para nível ${upgrade.targetLevel}',
        );
      } else {
        AppLogger.error(
          'Edifício não encontrado para ID ${upgrade.buildingId}',
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
