import 'package:get/get.dart';

class GameController extends GetxController {
  static GameController get to => Get.find();

  // Variáveis reativas
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

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
}
