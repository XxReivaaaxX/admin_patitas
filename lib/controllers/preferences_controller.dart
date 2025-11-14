import 'package:shared_preferences/shared_preferences.dart';

class PreferencesController {
  static late SharedPreferences preferences;
  static Future<void> iniciarPref() async {
    preferences = await SharedPreferences.getInstance();
  }
}
