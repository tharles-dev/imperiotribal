import 'package:get/get.dart';
import 'package:imperio_tribal_app/modules/auth/create_user/create_user_screen.dart';
import 'package:imperio_tribal_app/modules/auth/error/error_screen.dart';
import 'package:imperio_tribal_app/modules/auth/onboarding/onboarding_screen.dart';
import 'package:imperio_tribal_app/modules/auth/splash/splash_screen.dart';
import 'package:imperio_tribal_app/modules/game/game_screen.dart';
import 'package:imperio_tribal_app/modules/village/village_screen.dart';
import 'package:imperio_tribal_app/data/models/village_model.dart';
import 'package:imperio_tribal_app/shared/controllers/village_buildings_controller.dart';
import 'package:imperio_tribal_app/shared/controllers/village_resources_controller.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(name: Routes.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: Routes.createUser, page: () => const CreateUserScreen()),
    GetPage(name: Routes.game, page: () => const GameScreen()),
    GetPage(
      name: Routes.village,
      page: () {
        final village = Get.arguments as VillageModel;
        return VillageScreen(village: village);
      },
      binding: BindingsBuilder(() {
        Get.lazyPut<VillageBuildingsController>(
          () => VillageBuildingsController(),
        );
        Get.lazyPut<VillageResourcesController>(
          () => VillageResourcesController((Get.arguments as VillageModel).id!),
          tag: 'village_${(Get.arguments as VillageModel).id}',
        );
      }),
    ),
    GetPage(name: Routes.error, page: () => const ErrorScreen()),
  ];
}
