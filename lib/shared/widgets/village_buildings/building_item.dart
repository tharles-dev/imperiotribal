import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/core/constants/building_mappings.dart';
import 'package:imperio_tribal_app/core/constants/building_constants.dart';

import '../../../core/utils/logger.dart';

class BuildingItem extends StatelessWidget {
  final BuildingModel building;
  final Map<String, int> upgradeCost;
  final int buildTime;
  final bool isUpgrading;
  final bool isLocked;
  final String? lockReason;
  final VoidCallback? onUpgrade;
  final double? progress;

  const BuildingItem({
    super.key,
    required this.building,
    required this.upgradeCost,
    required this.buildTime,
    this.isUpgrading = false,
    this.isLocked = false,
    this.lockReason,
    this.onUpgrade,
    this.progress,
  });

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = BuildingMappings.getBuildingType(building.type);

    AppLogger.info('type ITEM: $type');

    if (type == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${BuildingConstants.getBuildingName(type)} (Nível ${building.level})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isUpgrading)
                  Text(
                    ' ${_formatTime(buildTime)}',
                    style: const TextStyle(color: Colors.blue),
                  ),
              ],
            ),
            if (isUpgrading && progress != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            if (!isUpgrading) ...[
              const SizedBox(height: 8),
              const Text('Custo de upgrade:'),
              Text('Madeira: ${upgradeCost['wood']}'),
              Text('Argila: ${upgradeCost['clay']}'),
              Text('Ferro: ${upgradeCost['iron']}'),
              Text('Tempo: ${_formatTime(buildTime)}'),
              if (isLocked && lockReason != null)
                Text(lockReason!, style: const TextStyle(color: Colors.red)),
              if (!isLocked && onUpgrade != null)
                ElevatedButton(
                  onPressed: onUpgrade,
                  child: const Text('Melhorar'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
