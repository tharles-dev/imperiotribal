import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imperio_tribal_app/core/routes/app_pages.dart';
import 'package:imperio_tribal_app/shared/controllers/game_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GameController _gameController = Get.find<GameController>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Aguarda a inicialização do GameController
      await Future.delayed(const Duration(seconds: 2));

      if (_gameController.hasError.value) {
        Get.offAllNamed(Routes.error);
        return;
      }

      if (_gameController.hasCurrentUser) {
        Get.offAllNamed(Routes.game);
      } else {
        Get.offAllNamed(Routes.onboarding);
      }
    } catch (e) {
      _gameController.setError('Erro ao inicializar o jogo');
      Get.offAllNamed(Routes.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B4513), Color(0xFF654321)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Império Tribal',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
