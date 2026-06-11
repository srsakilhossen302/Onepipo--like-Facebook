import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'english.dart';
import 'french.dart';

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
  }
}
