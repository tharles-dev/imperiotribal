import 'package:get/get.dart';
import 'package:imperio_tribal_app/core/game/building_queue_manager.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/data/repositories/building_repository.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'dart:async';

class VillageBuildingsController extends GetxController {
  final _buildingRepository = BuildingRepository();
  final _buildingQueueManager = BuildingQueueManager();
  Timer? _monitorTimer;

  final RxList<BuildingModel> buildings = <BuildingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<int, bool> buildingInQueue = <int, bool>{}.obs;
  final RxMap<int, int?> remainingTimes = <int, int?>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _startMonitorTimer();
  }

  @override
  void onClose() {
    _monitorTimer?.cancel();
    super.onClose();
  }

  void _startMonitorTimer() {
    _monitorTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _monitorBuildings();
    });
  }

  Future<void> _monitorBuildings() async {
    try {
      // Recarrega todos os edifícios
      if (buildings.isNotEmpty) {
        final loadedBuildings = await _buildingRepository.findByVillageId(
          buildings.first.villageId,
        );

        // Atualiza a lista mantendo os estados de construção
        for (final building in loadedBuildings) {
          if (building.id != null) {
            final index = buildings.indexWhere((b) => b.id == building.id);
            if (index != -1) {
              // Mantém o estado de construção se existir
              final wasInQueue = buildingInQueue[building.id!] ?? false;
              final remainingTime = remainingTimes[building.id!];

              buildings[index] = building;

              if (wasInQueue) {
                buildingInQueue[building.id!] = true;
                if (remainingTime != null) {
                  remainingTimes[building.id!] = remainingTime;
                }
              }
            }
          }
        }
      }

      // Verifica estado de cada edifício
      for (final building in buildings) {
        if (building.id != null) {
          // Verifica se está em fila
          final inQueue = await isBuildingInQueue(building.id!);
          buildingInQueue[building.id!] = inQueue;

          // Se estiver em fila, atualiza tempo restante
          if (inQueue) {
            final time = await getRemainingTime(building.id!);
            remainingTimes[building.id!] = time;
          } else {
            remainingTimes.remove(building.id!);
          }
        }
      }
    } catch (e) {
      AppLogger.error('Erro ao monitorar edifícios', e);
    }
  }

  // Carrega todos os edifícios da vila
  Future<void> loadBuildings(int villageId) async {
    try {
      isLoading.value = true;
      final loadedBuildings = await _buildingRepository.findByVillageId(
        villageId,
      );
      buildings.value = loadedBuildings;

      // Inicia monitoramento após carregar
      await _monitorBuildings();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao carregar edifícios', e, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Verifica se um edifício está em construção
  Future<bool> isBuildingInQueue(int buildingId) async {
    try {
      return await _buildingQueueManager.hasActiveUpgrade(buildingId);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao verificar fila de construção', e, stackTrace);
      return false;
    }
  }

  // Atualiza o estado dos edifícios
  Future<void> updateBuildingsState(int villageId) async {
    try {
      await loadBuildings(villageId);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar estado dos edifícios', e, stackTrace);
    }
  }

  // Inicia um upgrade de edifício
  Future<bool> startUpgrade(
    int buildingId,
    int villageId,
    int nextLevel,
    int startTime,
    int endTime,
  ) async {
    try {
      await _buildingQueueManager.addToQueue(
        buildingId,
        villageId,
        nextLevel,
        startTime,
        endTime,
      );

      // Atualiza estado local
      buildingInQueue[buildingId] = true;
      remainingTimes[buildingId] = endTime - startTime;

      // Atualiza o edifício na lista
      final index = buildings.indexWhere((b) => b.id == buildingId);
      if (index != -1) {
        final building = buildings[index];
        buildings[index] = building.copyWith(
          level: nextLevel - 1, // Nível atual (antes do upgrade)
        );
      }

      // Notifica que um upgrade foi iniciado
      update();
      return true;
    } catch (e) {
      AppLogger.error('Erro ao iniciar upgrade', e);
      return false;
    }
  }

  // Obtém o tempo restante de uma construção
  Future<int?> getRemainingTime(int buildingId) async {
    try {
      final upgrade = await _buildingQueueManager.getActiveUpgrade(buildingId);
      if (upgrade == null) return null;

      final now = DateTime.now().millisecondsSinceEpoch;
      return upgrade.endTime - now;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao obter tempo restante', e, stackTrace);
      return null;
    }
  }

  // Atualiza um edifício específico na lista
  void updateBuilding(BuildingModel updatedBuilding) {
    final index = buildings.indexWhere((b) => b.id == updatedBuilding.id);
    if (index != -1) {
      buildings[index] = updatedBuilding;
      update();
    }
  }

  // Verifica se um edifício específico está em construção
  bool isBuildingCurrentlyInQueue(int buildingId) {
    return buildingInQueue[buildingId] ?? false;
  }

  // Obtém o tempo restante de um edifício específico
  int? getBuildingRemainingTime(int buildingId) {
    return remainingTimes[buildingId];
  }

  // Obtém um edifício específico
  BuildingModel? getBuilding(int buildingId) {
    return buildings.firstWhereOrNull((b) => b.id == buildingId);
  }

  Future<void> onUpgradeCompleted(int buildingId) async {
    try {
      AppLogger.info('onUpgradeCompleted chamado para edifício $buildingId');

      // Atualiza o nível do edifício
      final building = await _buildingRepository.findById(buildingId);
      if (building != null) {
        AppLogger.info('Edifício encontrado: ${building.type}');

        // Atualiza na lista local
        final index = buildings.indexWhere((b) => b.id == buildingId);
        if (index != -1) {
          AppLogger.info('Atualizando edifício na lista local');
          buildings[index] = building;

          // Remove da fila e tempos
          buildingInQueue.remove(buildingId);
          remainingTimes.remove(buildingId);

          // Notifica que um upgrade foi concluído
          buildings.refresh();
          buildingInQueue.refresh();
          remainingTimes.refresh();
          update();
          AppLogger.info('Lista de edifícios atualizada com sucesso');
        } else {
          AppLogger.warning('Edifício não encontrado na lista local');
        }
      } else {
        AppLogger.warning('Edifício não encontrado no banco');
      }
    } catch (e) {
      AppLogger.error('Erro ao concluir upgrade', e);
    }
  }
}
