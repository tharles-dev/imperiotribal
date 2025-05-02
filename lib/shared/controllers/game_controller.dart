import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imperio_tribal_app/core/database/database_helper.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/core/game/game_resource_manager.dart';
import 'package:imperio_tribal_app/core/game/building_queue_manager.dart';
import 'package:imperio_tribal_app/data/models/user_model.dart';
import 'package:imperio_tribal_app/data/repositories/user_repository.dart';

class GameController extends GetxController with WidgetsBindingObserver {
  static GameController get to => Get.find();

  // Repositórios
  final _userRepository = UserRepository();
  final _resourceManager = GameResourceManager();
  final _buildingQueueManager = BuildingQueueManager();

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
    _startUpdateLoop();
  }

  @override
  void onClose() {
    _stopUpdateLoop();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.detached:
        _onAppHidden();
        break;
      case AppLifecycleState.inactive:
        _onAppHidden();
        break;
      default:
        break;
    }
  }

  void _onAppResumed() {
    isAppActive.value = true;
    _startUpdateLoop();
  }

  void _onAppHidden() {
    isAppActive.value = false;
    _stopUpdateLoop();
  }

  Future<void> _initializeGame() async {
    try {
      setLoading(true);
      clearError();

      // Inicializa o banco de dados
      await DatabaseHelper.instance.database;

      // Verifica se existe usuário
      final hasUser = await _userRepository.exists();

      if (hasUser) {
        // Carrega o primeiro usuário (não NPC) como usuário atual
        final users = await _userRepository.findAll();
        final mainUser = users.firstWhere((user) => !user.isNpc);
        currentUser.value = mainUser;

        // Atualiza recursos e construções para calcular tempo offline
        await Future.wait([
          _resourceManager.updateAllVillages(),
          _buildingQueueManager.processAllQueues(),
        ]);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao inicializar o jogo', e, stackTrace);
      setError('Erro ao inicializar o jogo: $e');
    } finally {
      setLoading(false);
    }
  }

  // Inicia o loop de atualização a cada 10 segundos
  void _startUpdateLoop() {
    if (_updateTimer?.isActive ?? false) {
      return;
    }

    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!isLoading.value && isAppActive.value && !isUpdating.value) {
        try {
          isUpdating.value = true;

          // Processa recursos e construções em paralelo
          await Future.wait([
            _resourceManager.updateAllVillages(),
            _buildingQueueManager.processAllQueues(),
          ]);
        } catch (e, stackTrace) {
          AppLogger.error('Erro ao atualizar jogo', e, stackTrace);
        } finally {
          isUpdating.value = false;
        }
      }
    });
  }

  // Para o loop de atualização
  void _stopUpdateLoop() {
    if (_updateTimer?.isActive ?? false) {
      _updateTimer?.cancel();
      _updateTimer = null;
    }
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
