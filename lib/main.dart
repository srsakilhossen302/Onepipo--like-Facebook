import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Core/AppRoute/app_route.dart';
import 'Core/Dependency/dependency.dart';
import 'Language/translator.dart';
import 'Utils/AppColors/app_colors.dart';

void main() async {
  // Ensure Flutter engine is initialized before calling runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize synchronous global dependencies (like SharedPreferences)
  await DependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Onepipo',
      debugShowCheckedModeBanner: false,
      
      // Routing & Navigation setup
      initialRoute: AppRoute.getSplashScreen(),
      getPages: AppRoute.routes,
      initialBinding: DependencyInjection(),
      defaultTransition: Transition.cupertino,

      // Localization config
      translations: AppTranslator(),
      locale: AppTranslator.defaultLocale,
      fallbackLocale: AppTranslator.fallbackLocale,

      // Visual styling & theme configurations
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
    );
  }
}
