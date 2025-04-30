import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imperio_tribal_app/core/routes/app_pages.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedTribe = 'Romanos';

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

  void _createUser() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar criação de usuário
      Get.offAllNamed(Routes.game);
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
                onPressed: _createUser,
                child: const Text('Criar Jogador'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
