import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/village_model.dart';

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Aldeia ${village.name}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Posição: (${village.x}, ${village.y})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            const Text('Em breve:'),
            const Text('- Recursos'),
            const Text('- Construções'),
            const Text('- Tropas'),
          ],
        ),
      ),
    );
  }
}
