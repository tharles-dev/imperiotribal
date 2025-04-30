import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imperio_tribal_app/core/routes/app_pages.dart';
import 'package:imperio_tribal_app/core/game/game_initializer.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/shared/controllers/game_controller.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gameController = Get.find<GameController>();
  final _gameInitializer = GameInitializer();
  String _selectedTribe = 'Romanos';
  bool _isLoading = false;

  final List<String> _tribes = [
    'Romanos',
    'Bárbaros',
    'Gauleses',
    'Teutões',
    'Egípcios',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      AppLogger.info('Criando usuário: ${_nameController.text}');

      // Inicializa o jogo com o usuário
      final user = await _gameInitializer.initializeGame(
        name: _nameController.text,
        tribe: _selectedTribe,
        createdAt: DateTime.now(),
      );

      // Atualiza o usuário atual no GameController
      _gameController.currentUser.value = user;

      AppLogger.info('Usuário criado com sucesso');
      Get.offAllNamed(Routes.game);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar usuário', e, stackTrace);
      _gameController.setError('Erro ao criar usuário: $e');
      Get.offAllNamed(Routes.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Jogador')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crie seu jogador',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Jogador',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedTribe,
                decoration: const InputDecoration(
                  labelText: 'Selecione sua Tribo',
                  border: OutlineInputBorder(),
                ),
                items:
                    _tribes.map((tribe) {
                      return DropdownMenuItem(value: tribe, child: Text(tribe));
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTribe = value!;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _createUser,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Criar Jogador'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
