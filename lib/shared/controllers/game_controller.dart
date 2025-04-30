import 'package:get/get.dart';
import 'package:imperio_tribal_app/core/database/database_helper.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/data/models/user_model.dart';
import 'package:imperio_tribal_app/data/repositories/user_repository.dart';

class GameController extends GetxController {
  static GameController get to => Get.find();

  // Repositórios
  final _userRepository = UserRepository();

  // Variáveis reativas
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    _initializeGame();
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
        // TODO: Carregar usuário atual
        // currentUser.value = await _userRepository.findById(1);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao inicializar o jogo', e, stackTrace);
      setError('Erro ao inicializar o jogo: $e');
    } finally {
      setLoading(false);
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
