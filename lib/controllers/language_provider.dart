import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en', 'US');

  Locale get locale => _locale;

  void toggleLanguage() {
    _locale =
        _locale.languageCode == 'en' ? const Locale('de', 'DE') : const Locale('en', 'US');
    notifyListeners();
  }

  String get languageCode => _locale.languageCode;
}
