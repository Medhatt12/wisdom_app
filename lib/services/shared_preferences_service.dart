import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String partnerCodeKey = 'partner_code';

  Future<void> savePartnerCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(partnerCodeKey, code);
  }

  Future<String?> getPartnerCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(partnerCodeKey);
  }
}
