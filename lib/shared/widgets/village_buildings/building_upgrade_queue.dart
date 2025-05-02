import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/upgrade_queue_model.dart';
import 'package:imperio_tribal_app/data/repositories/upgrade_queue_repository.dart';
import 'package:imperio_tribal_app/data/repositories/building_repository.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/shared/controllers/village_buildings_controller.dart';
import 'package:get/get.dart';
import 'building_item.dart';

class BuildingUpgradeQueue extends StatefulWidget {
  final int villageId;
  final VoidCallback onUpgradeComplete;

  const BuildingUpgradeQueue({
    super.key,
    required this.villageId,
    required this.onUpgradeComplete,
  });

  @override
  State<BuildingUpgradeQueue> createState() => _BuildingUpgradeQueueState();
}

class _BuildingUpgradeQueueState extends State<BuildingUpgradeQueue> {
  final _upgradeQueueRepository = UpgradeQueueRepository();
  final _buildingRepository = BuildingRepository();
  final _buildingsController = Get.find<VillageBuildingsController>();
  List<UpgradeQueueModel> _upgrades = [];
  bool _isLoading = true;
  Timer? _timer;
  final Map<int, bool> _updatingBuildings = {};
  final Map<int, Timer> _completionTimers = {};

  @override
  void initState() {
    super.initState();
    _loadUpgrades();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final timer in _completionTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadUpgrades() async {
    try {
      setState(() => _isLoading = true);
      final upgrades = await _upgradeQueueRepository.findByVillageId(
        widget.villageId,
      );
      setState(() {
        _upgrades = upgrades;
        _isLoading = false;
      });
      AppLogger.info('Upgrades carregados: ${_upgrades.length} itens');
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _scheduleUpgradeCompletion(int buildingId) {
    if (_updatingBuildings[buildingId] == true ||
        _completionTimers.containsKey(buildingId)) {
      return;
    }

    setState(() {
      _updatingBuildings[buildingId] = true;
    });

    final timer = Timer(const Duration(seconds: 11), () async {
      if (!mounted) return;

      try {
        await _buildingsController.onUpgradeCompleted(buildingId);
        await _buildingsController.loadBuildings(widget.villageId);
        widget.onUpgradeComplete();
      } catch (e) {
        AppLogger.error('Erro ao completar upgrade', e);
      } finally {
        if (mounted) {
          setState(() {
            _updatingBuildings.remove(buildingId);
            _completionTimers.remove(buildingId);
          });
        }
      }
    });

    _completionTimers[buildingId] = timer;
  }

  Widget _buildUpdatingCard(BuildingModel building) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${building.type} (Nível ${building.level})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Atualizando edifício...'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_upgrades.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nenhuma construção em andamento'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _upgrades.length,
      itemBuilder: (context, index) {
        return FutureBuilder<BuildingModel?>(
          future: _buildingRepository.findById(_upgrades[index].buildingId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final building = snapshot.data!;
            final upgrade = _upgrades[index];
            final now = DateTime.now().millisecondsSinceEpoch;
            final remainingTime = upgrade.endTime - now;

            // Se a construção terminou, inicia o processo de atualização
            if (remainingTime <= 0) {
              if (!_updatingBuildings.containsKey(building.id)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scheduleUpgradeCompletion(building.id!);
                });
              }
              return _buildUpdatingCard(building);
            }

            return BuildingItem(
              building: building,
              upgradeCost: const {},
              buildTime: remainingTime ~/ 1000,
              isUpgrading: true,
              progress:
                  1 - (remainingTime / (upgrade.endTime - upgrade.startTime)),
            );
          },
        );
      },
    );
  }
}
