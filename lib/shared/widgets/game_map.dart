import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/user_model.dart';
import 'package:imperio_tribal_app/data/models/village_model.dart';
import 'package:imperio_tribal_app/shared/widgets/village_marker.dart';

class GameMap extends StatelessWidget {
  final List<VillageModel> villages;
  final List<UserModel> villageUsers;
  final VillageModel? selectedVillage;
  final Function(VillageModel) onVillageTap;

  const GameMap({
    super.key,
    required this.villages,
    required this.villageUsers,
    this.selectedVillage,
    required this.onVillageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
        ),
        itemCount: 49, // 7x7 grid
        itemBuilder: (context, index) {
          final x = index % 7;
          final y = index ~/ 7;

          // Encontra a aldeia nesta posição
          final village = villages.firstWhere(
            (v) => v.x == x && v.y == y,
            orElse:
                () => VillageModel(
                  id: 0,
                  userId: 0,
                  name: '',
                  x: x,
                  y: y,
                  createdAt: DateTime.now(),
                ),
          );

          // Encontra o usuário dono desta aldeia
          final villageUser =
              village.id != 0
                  ? villageUsers.firstWhere((u) => u.id == village.userId)
                  : UserModel(
                    id: 0,
                    name: '',
                    tribe: '',
                    isNpc: true,
                    createdAt: DateTime.now(),
                  );

          return Container(
            decoration: BoxDecoration(
              color: (x + y) % 2 == 0 ? Colors.grey[300] : Colors.grey[200],
              border: Border.all(color: Colors.grey[400]!),
            ),
            child:
                village.id != 0
                    ? VillageMarker(
                      village: village,
                      user: villageUser,
                      isSelected: selectedVillage?.id == village.id,
                      onTap: () => onVillageTap(village),
                    )
                    : null,
          );
        },
      ),
    );
  }
}
