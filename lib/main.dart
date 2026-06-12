import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Core/AppRoute/app_route.dart';
import 'Core/Dependency/dependency.dart';
import 'Language/translator.dart';
import 'Utils/AppColors/app_colors.dart';
import 'helper/shared_prefe/shared_prefe.dart';

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
    Locale initialLocale = AppTranslator.defaultLocale;
    try {
      if (Get.isRegistered<SharedPreferenceHelper>()) {
        final prefHelper = Get.find<SharedPreferenceHelper>();
        final langCode = prefHelper.getString('language_code', defaultValue: 'en');
        final countryCode = prefHelper.getString('country_code', defaultValue: 'US');
        initialLocale = Locale(langCode, countryCode);
      }
    } catch (_) {}

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
      locale: initialLocale,
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
