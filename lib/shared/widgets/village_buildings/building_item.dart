import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';

class BuildingItem extends StatelessWidget {
  final BuildingModel building;
  final Map<String, int> upgradeCost;
  final int buildTime;
  final bool isLocked;
  final bool isUpgrading;
  final VoidCallback? onUpgrade;
  final String? lockReason;

  const BuildingItem({
    super.key,
    required this.building,
    required this.upgradeCost,
    required this.buildTime,
    this.isLocked = false,
    this.isUpgrading = false,
    this.onUpgrade,
    this.lockReason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey[200] : Colors.brown[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLocked ? Colors.grey[400]! : Colors.brown[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com nome e nível
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/${building.type}.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.home, size: 24);
                      },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _getBuildingName(building.type),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              isLocked ? Colors.grey[600] : Colors.brown[900],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey[300] : Colors.brown[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Nível ${building.level}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.grey[600] : Colors.brown[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Custos de upgrade
          if (!isLocked && !isUpgrading && upgradeCost.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResourceCost('wood', upgradeCost['wood'] ?? 0),
                _buildResourceCost('clay', upgradeCost['clay'] ?? 0),
                _buildResourceCost('iron', upgradeCost['iron'] ?? 0),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.brown),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(buildTime),
                  style: const TextStyle(color: Colors.brown),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Botão de upgrade ou motivo do bloqueio
          if (isLocked)
            Text(
              lockReason ?? 'Bloqueado',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            )
          else if (isUpgrading)
            Column(
              children: [
                LinearProgressIndicator(
                  value: 1 - (buildTime / (buildTime + 1)), // Simples progresso
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(buildTime),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Melhorar'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResourceCost(String resource, int amount) {
    return Row(
      children: [
        Image.asset('assets/images/$resource.png', width: 16, height: 16),
        const SizedBox(width: 4),
        Text(
          amount.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getBuildingName(String type) {
    switch (type) {
      case BuildingModel.townHall:
        return 'Centro da Vila';
      case BuildingModel.warehouse:
        return 'Armazém';
      case BuildingModel.farm:
        return 'Fazenda';
      case BuildingModel.woodcutter:
        return 'Lenhador';
      case BuildingModel.clayPit:
        return 'Poço de Argila';
      case BuildingModel.ironMine:
        return 'Mina de Ferro';
      case BuildingModel.barracks:
        return 'Quartel';
      case BuildingModel.stable:
        return 'Estábulo';
      default:
        return type;
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
