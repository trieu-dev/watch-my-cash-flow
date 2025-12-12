import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DateElement {
  day, month, year
}

class LocalizationService extends GetxService {
  static const _key = 'app_locale';

  final fallbackLocale = const Locale('en', 'US');
  final supportedLocales = [
    const Locale('en', 'US'),
    const Locale('vi', 'VN'),
    const Locale('zh', 'CN'),
  ];

  Future<LocalizationService> init() async {
    final saved = await _loadSavedLocale();
    if (saved != null) {
      Get.updateLocale(saved);
    }
    return this;
  }

  String get currentLanguageCode =>
      Get.locale?.languageCode ?? fallbackLocale.languageCode;

  String get currentCountryCode =>
      Get.locale?.countryCode ?? fallbackLocale.countryCode ?? '';

  Locale get currentLocale =>
      Get.locale ?? fallbackLocale;

  List<DateElement> getDateOrder() {
    switch (currentLanguageCode) {
      case 'en':
        return [DateElement.month, DateElement.day, DateElement.year];
      case 'th':
      case 'vi':
        return [DateElement.day, DateElement.month, DateElement.year];
      case 'ja':
      case 'ko':
      case 'zh':
        return [DateElement.year, DateElement.month, DateElement.day];
      default:
        return [DateElement.month, DateElement.day, DateElement.year];
    }
  }

  /// Save locale to SharedPreferences
  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, '${locale.languageCode}_${locale.countryCode}');
  }

  /// Read locale from SharedPreferences
  Future<Locale?> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == null) return null;

    final parts = value.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : '');
  }

  /// Change language
  Future<void> changeLocale(Locale locale) async {
    await saveLocale(locale);
    Get.updateLocale(locale);
  }
}
