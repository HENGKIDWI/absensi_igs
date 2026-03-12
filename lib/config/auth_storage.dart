import 'package:igs_absensi/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _userdata = 'auth_user';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveUser(String user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', user);
  }
}
