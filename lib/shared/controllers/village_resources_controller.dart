import 'package:get/get.dart';
import 'package:imperio_tribal_app/data/models/resource_model.dart';
import 'package:imperio_tribal_app/data/repositories/resource_repository.dart';
import 'package:imperio_tribal_app/data/repositories/building_repository.dart';
import 'package:imperio_tribal_app/core/constants/building_constants.dart';
import 'package:imperio_tribal_app/data/models/building_type.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'dart:async';

class VillageResourcesController extends GetxController {
  final int villageId;
  final _resourceRepository = ResourceRepository();
  final _buildingRepository = BuildingRepository();
  Timer? _updateTimer;

  // Observáveis
  final resources = Rxn<ResourceModel>();
  final maxCapacity = 0.obs;
  final storageLevel = 0.obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  VillageResourcesController(this.villageId);

  @override
  void onInit() {
    super.onInit();
    loadResources();
    _startUpdateTimer();
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    super.onClose();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      loadResources();
    });
  }

  Future<void> loadResources() async {
    try {
      // Só mostra loading se não tiver recursos ainda
      if (resources.value == null) {
        isLoading.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      await _updateResources();
    } catch (e, stackTrace) {
      hasError.value = true;
      errorMessage.value = 'Erro ao carregar recursos: $e';
      AppLogger.error('Erro ao carregar recursos', e, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAfterDeduction() async {
    try {
      // Não mostra loading para atualizações rápidas
      hasError.value = false;
      errorMessage.value = '';

      await _updateResources();

      AppLogger.info(
        'Recursos atualizados após dedução: '
        'wood=${resources.value?.wood}, '
        'clay=${resources.value?.clay}, '
        'iron=${resources.value?.iron}',
      );
    } catch (e, stackTrace) {
      hasError.value = true;
      errorMessage.value = 'Erro ao atualizar recursos: $e';
      AppLogger.error('Erro ao atualizar recursos após dedução', e, stackTrace);
    }
  }

  Future<void> _updateResources() async {
    // Carrega recursos
    final resourceData = await _resourceRepository.findByVillageId(villageId);
    if (resourceData == null) {
      throw Exception('Recursos não encontrados');
    }

    // Só atualiza se os valores realmente mudaram
    if (resources.value?.wood != resourceData.wood ||
        resources.value?.clay != resourceData.clay ||
        resources.value?.iron != resourceData.iron) {
      resources.value = resourceData;
    }

    // Carrega edifícios
    final buildings = await _buildingRepository.findByVillageId(villageId);
    final storage = buildings.firstWhere(
      (building) => building.type == BuildingType.warehouse.name,
    );

    // Só atualiza storage se o nível mudou
    if (storageLevel.value != storage.level) {
      storageLevel.value = storage.level;
      maxCapacity.value = BuildingConstants.calculateStorageCapacity(
        storage.level,
      );
    }
  }

  bool isAtCapacity(int amount) {
    return amount >= maxCapacity.value;
  }
}
