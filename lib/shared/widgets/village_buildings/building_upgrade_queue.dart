import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/upgrade_queue_model.dart';
import 'package:imperio_tribal_app/data/repositories/upgrade_queue_repository.dart';
import 'package:imperio_tribal_app/data/repositories/building_repository.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'building_item.dart';

class BuildingUpgradeQueue extends StatefulWidget {
  final int villageId;

  const BuildingUpgradeQueue({super.key, required this.villageId});

  @override
  State<BuildingUpgradeQueue> createState() => _BuildingUpgradeQueueState();
}

class _BuildingUpgradeQueueState extends State<BuildingUpgradeQueue> {
  final _upgradeQueueRepository = UpgradeQueueRepository();
  final _buildingRepository = BuildingRepository();
  List<UpgradeQueueModel> _upgrades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpgrades();
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
    } catch (e) {
      setState(() => _isLoading = false);
    }
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

            return BuildingItem(
              building: building,
              upgradeCost:
                  const {}, // Não mostramos custos para construções em andamento
              buildTime: remainingTime ~/ 1000,
              isUpgrading: true,
            );
          },
        );
      },
    );
  }
}
