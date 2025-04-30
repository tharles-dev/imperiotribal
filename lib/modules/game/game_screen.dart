import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Império Tribal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Implementar perfil do jogador
            },
          ),
        ],
      ),
      body: const Center(child: Text('Tela do Jogo')),
    );
  }
}
