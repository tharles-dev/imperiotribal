import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imperio_tribal_app/shared/controllers/village_buildings_controller.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'building_upgrade_queue.dart';
import 'available_buildings.dart';
import 'locked_buildings.dart';

class VillageBuildings extends StatefulWidget {
  final int villageId;

  const VillageBuildings({super.key, required this.villageId});

  @override
  State<VillageBuildings> createState() => _VillageBuildingsState();
}

class _VillageBuildingsState extends State<VillageBuildings> {
  late final VillageBuildingsController _buildingsController;

  @override
  void initState() {
    super.initState();
    AppLogger.info(
      'VillageBuildings - initState - villageId: ${widget.villageId}',
    );
    _buildingsController = Get.put(
      VillageBuildingsController(),
      tag: 'village_${widget.villageId}',
    );
    _buildingsController.loadBuildings(widget.villageId);
  }

  @override
  void dispose() {
    AppLogger.info(
      'VillageBuildings - dispose - villageId: ${widget.villageId}',
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.info('VillageBuildings - build - villageId: ${widget.villageId}');
    return Obx(() {
      AppLogger.info(
        'VillageBuildings - Obx rebuild - villageId: ${widget.villageId} - isLoading: ${_buildingsController.isLoading.value}',
      );

      if (_buildingsController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(), // Evita efeito de overscroll
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila de construções
            const Text(
              'Construções em Andamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BuildingUpgradeQueue(
              villageId: widget.villageId,
              onUpgradeComplete: () {
                AppLogger.info(
                  'VillageBuildings - onUpgradeComplete - villageId: ${widget.villageId}',
                );
                _buildingsController.loadBuildings(widget.villageId);
              },
            ),
            const SizedBox(height: 24),

            // Edifícios disponíveis
            const Text(
              'Edifícios Disponíveis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AvailableBuildings(
              villageId: widget.villageId,
              onUpgrade: () {
                AppLogger.info(
                  'VillageBuildings - onUpgrade - villageId: ${widget.villageId}',
                );
                _buildingsController.loadBuildings(widget.villageId);
              },
            ),
            const SizedBox(height: 24),

            // Edifícios bloqueados
            LockedBuildings(
              buildings: _buildingsController.buildings,
              villageId: widget.villageId,
              onBuildingCreated: () {
                AppLogger.info(
                  'VillageBuildings - onBuildingCreated - villageId: ${widget.villageId}',
                );
                _buildingsController.loadBuildings(widget.villageId);
              },
            ),
          ],
        ),
      );
    });
  }
}
