import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'english.dart';
import 'french.dart';
import '../helper/shared_prefe/shared_prefe.dart';

class AppTranslator extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': EnglishTranslations.english,
        'fr_FR': FrenchTranslations.french,
      };

  static const Locale defaultLocale = Locale('en', 'US');
  static const Locale fallbackLocale = Locale('en', 'US');

  static void changeLanguage(String languageCode, String countryCode) {
    Locale locale = Locale(languageCode, countryCode);
    Get.updateLocale(locale);

    try {
      if (Get.isRegistered<SharedPreferenceHelper>()) {
        final prefHelper = Get.find<SharedPreferenceHelper>();
        prefHelper.setString('language_code', languageCode);
        prefHelper.setString('country_code', countryCode);
      }
    } catch (_) {}
  }
}
