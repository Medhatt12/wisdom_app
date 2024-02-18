import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static Future<Map<String, dynamic>> loadLocalizedJson(
      String languageCode) async {
    String jsonString =
        await rootBundle.loadString('locales/$languageCode.json');
    return json.decode(jsonString);
  }
}
