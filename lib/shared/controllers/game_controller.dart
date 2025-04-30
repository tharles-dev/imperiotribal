import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imperio_tribal_app/core/database/database_helper.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/core/game/game_resource_manager.dart';
import 'package:imperio_tribal_app/data/models/user_model.dart';
import 'package:imperio_tribal_app/data/repositories/user_repository.dart';

class GameController extends GetxController with WidgetsBindingObserver {
  static GameController get to => Get.find();

  // Repositórios
  final _userRepository = UserRepository();
  final _resourceManager = GameResourceManager();

  // Variáveis reativas
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final currentUser = Rxn<UserModel>();
  final isAppActive = true.obs;
  final isUpdating = false.obs;

  // Timer para o loop de atualização
  Timer? _updateTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeGame();
    _startResourceUpdateLoop();
  }

  @override
  void onClose() {
    _stopResourceUpdateLoop();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      default:
        _onAppHidden();
        break;
    }
  }

  void _onAppResumed() {
    isAppActive.value = true;
    AppLogger.info('App retomado - Iniciando loop de atualização...');
    _startResourceUpdateLoop();
  }

  void _onAppHidden() {
    isAppActive.value = false;
    AppLogger.info('App ocultado - Parando loop de atualização...');
    _stopResourceUpdateLoop();
  }

  Future<void> _initializeGame() async {
    try {
      setLoading(true);
      clearError();

      AppLogger.info('Inicializando o jogo...');

      // Inicializa o banco de dados
      await DatabaseHelper.instance.database;
      AppLogger.info('Banco de dados inicializado com sucesso');

      // Verifica se existe usuário
      final hasUser = await _userRepository.exists();
      AppLogger.info('Verificando existência de usuário: $hasUser');

      if (hasUser) {
        // Carrega o primeiro usuário (não NPC) como usuário atual
        final users = await _userRepository.findAll();
        final mainUser = users.firstWhere((user) => !user.isNpc);
        currentUser.value = mainUser;
        AppLogger.info('Usuário atual carregado: ${mainUser.name}');

        // Atualiza recursos para calcular tempo offline
        await _resourceManager.updateAllVillages();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao inicializar o jogo', e, stackTrace);
      setError('Erro ao inicializar o jogo: $e');
    } finally {
      setLoading(false);
    }
  }

  // Inicia o loop de atualização de recursos a cada 10 segundos
  void _startResourceUpdateLoop() {
    _stopResourceUpdateLoop(); // Garante que não há outro timer rodando

    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!isLoading.value && isAppActive.value && !isUpdating.value) {
        try {
          isUpdating.value = true;
          await _resourceManager.updateAllVillages();
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao atualizar recursos', e, stackTrace);
        } finally {
          isUpdating.value = false;
        }
      }
    });
  }

  // Para o loop de atualização
  void _stopResourceUpdateLoop() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  // Métodos
  void setLoading(bool value) => isLoading.value = value;

  void setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
  }

  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  bool get hasCurrentUser => currentUser.value != null;
}
