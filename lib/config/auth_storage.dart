import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUser(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userJson);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> hasSession() async {
    final token = await getToken();
    return token != null;
  }
}
