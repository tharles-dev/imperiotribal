import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imperio_tribal_app/data/models/user_model.dart';
import 'package:imperio_tribal_app/data/models/village_model.dart';
import 'package:imperio_tribal_app/data/repositories/user_repository.dart';
import 'package:imperio_tribal_app/data/repositories/village_repository.dart';
import 'package:imperio_tribal_app/shared/controllers/game_controller.dart';
import 'package:imperio_tribal_app/shared/widgets/game_map.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _villageRepository = VillageRepository();
  final _userRepository = UserRepository();
  final _gameController = GameController.to;
  late Future<List<VillageModel>> _villagesFuture;
  late Future<List<UserModel>> _usersFuture;
  VillageModel? _selectedVillage;

  @override
  void initState() {
    super.initState();
    _villagesFuture = _villageRepository.findAll();
    _usersFuture = _userRepository.findAll();
  }

  void _onVillageTap(VillageModel village) {
    setState(() {
      _selectedVillage = village;
    });

    final currentUser = _gameController.currentUser.value!;
    final isNpc = village.isNpc(currentUser);
    Get.snackbar(
      'Aldeia ${isNpc ? 'NPC' : 'do Jogador'}',
      'Posição: (${village.x}, ${village.y})',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Império Tribal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Implementar menu do usuário
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<VillageModel>>(
          future: _villagesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Erro: ${snapshot.error}');
            }

            final villages = snapshot.data!;
            final currentUser = _gameController.currentUser.value;

            if (currentUser == null) {
              return const Text('Erro: Usuário não encontrado');
            }

            return FutureBuilder<List<UserModel>>(
              future: _usersFuture,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (userSnapshot.hasError) {
                  return Text('Erro: ${userSnapshot.error}');
                }

                final users = userSnapshot.data!;
                final villageUsers =
                    villages.map((village) {
                      return users.firstWhere(
                        (user) => user.id == village.userId,
                      );
                    }).toList();

                return GameMap(
                  villages: villages,
                  villageUsers: villageUsers,
                  selectedVillage: _selectedVillage,
                  onVillageTap: _onVillageTap,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
