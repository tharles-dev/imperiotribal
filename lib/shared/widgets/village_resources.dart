import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/resource_model.dart';
import 'package:imperio_tribal_app/data/repositories/resource_repository.dart';
import 'package:imperio_tribal_app/core/constants/building_constants.dart';
import 'package:imperio_tribal_app/data/repositories/building_repository.dart';
import 'package:imperio_tribal_app/data/models/building_type.dart';

class VillageResources extends StatelessWidget {
  final int villageId;
  final _resourceRepository = ResourceRepository();
  final _buildingRepository = BuildingRepository();

  VillageResources({super.key, required this.villageId});

  Future<(ResourceModel, int, int)> _loadResourcesAndCapacity() async {
    final resources = await _resourceRepository.findByVillageId(villageId);
    if (resources == null) throw Exception('Recursos não encontrados');

    final buildings = await _buildingRepository.findByVillageId(villageId);

    // Procura o armazém ou cria um novo
    final storage = buildings.firstWhere(
      (building) => building.type == BuildingType.warehouse.name,
    );

    final maxCapacity = BuildingConstants.calculateStorageCapacity(
      storage.level,
    );

    return (resources, maxCapacity, storage.level);
  }

  Widget _buildResourceItem(String icon, int amount, int maxCapacity) {
    final isAtCapacity = amount >= maxCapacity;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.brown[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAtCapacity ? Colors.red[200]! : Colors.brown[200]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/$icon.png', width: 20, height: 20),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                amount.toString(),
                style: TextStyle(
                  color: isAtCapacity ? Colors.red : Colors.brown[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageItem(int maxCapacity) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.brown[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/warehouse.png', width: 20, height: 20),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                maxCapacity.toString(),
                style: TextStyle(
                  color: Colors.brown[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return const SizedBox(width: 4);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(ResourceModel, int, int)>(
      future: _loadResourcesAndCapacity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Erro ao carregar recursos: ${snapshot.error}');
        }

        final (resources, maxCapacity, _) = snapshot.data!;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.brown[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.brown[200]!),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.brown[200]!.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildResourceItem('wood', resources.wood, maxCapacity),
              _buildVerticalDivider(),
              _buildResourceItem('clay', resources.clay, maxCapacity),
              _buildVerticalDivider(),
              _buildResourceItem('iron', resources.iron, maxCapacity),
              _buildVerticalDivider(),
              _buildStorageItem(maxCapacity),
            ],
          ),
        );
      },
    );
  }
}
