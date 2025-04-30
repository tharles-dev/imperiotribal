import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/village_model.dart';
import 'package:imperio_tribal_app/shared/widgets/village_resources.dart';
import 'package:imperio_tribal_app/shared/widgets/village_buildings/village_buildings.dart';

class VillageScreen extends StatelessWidget {
  final VillageModel village;

  const VillageScreen({super.key, required this.village});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(village.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recursos
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: VillageResources(villageId: village.id!),
            ),

            VillageBuildings(villageId: village.id!),
          ],
        ),
      ),
    );
  }
}
