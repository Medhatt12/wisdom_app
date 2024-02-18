import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = Locale('en', 'US');

  Locale get locale => _locale;

  void toggleLanguage() {
    _locale =
        _locale.languageCode == 'en' ? Locale('de', 'DE') : Locale('en', 'US');
    notifyListeners();
  }

  String get languageCode => _locale.languageCode;
}
