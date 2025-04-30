import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imperio_tribal_app/core/routes/app_pages.dart';
import 'package:imperio_tribal_app/core/theme/app_theme.dart';
import 'package:imperio_tribal_app/shared/controllers/game_controller.dart';

void main() {
  // Inicializa o GameController globalmente
  Get.put(GameController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Império Tribal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
