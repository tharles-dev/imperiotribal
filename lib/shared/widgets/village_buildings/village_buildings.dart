import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';
import 'package:imperio_tribal_app/data/repositories/building_repository.dart';
import 'available_buildings.dart';
import 'locked_buildings.dart';
import 'building_upgrade_queue.dart';

class VillageBuildings extends StatefulWidget {
  final int villageId;

  const VillageBuildings({super.key, required this.villageId});

  @override
  State<VillageBuildings> createState() => _VillageBuildingsState();
}

class _VillageBuildingsState extends State<VillageBuildings> {
  final _buildingRepository = BuildingRepository();
  List<BuildingModel> _buildings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  Future<void> _loadBuildings() async {
    try {
      setState(() => _isLoading = true);
      final buildings = await _buildingRepository.findByVillageId(
        widget.villageId,
      );
      setState(() {
        _buildings = buildings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar edifícios'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadBuildings,
      child: SingleChildScrollView(
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
            BuildingUpgradeQueue(villageId: widget.villageId),
            const SizedBox(height: 24),

            // Edifícios disponíveis
            const Text(
              'Edifícios Disponíveis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AvailableBuildings(
              villageId: widget.villageId,
              buildings: _buildings,
              onUpgrade: _loadBuildings,
            ),
            const SizedBox(height: 4),
            LockedBuildings(buildings: _buildings),
          ],
        ),
      ),
    );
  }
}
