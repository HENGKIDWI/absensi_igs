import 'package:flutter/material.dart';
import 'package:igs_absensi/config/auth_storage.dart';
import 'package:igs_absensi/model/user_model.dart';
import 'package:igs_absensi/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  User? user;

  // login
  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      final token = result['token'];

      if (token == null) throw Exception("Token tidak ditemukan");

      final isVerified = await _apiService.verifiEmail(token);

      if (!isVerified) {
        await AuthStorage.saveToken(token);
        throw Exception('EMAIL_NOT_VERIFIED');
      }

      await AuthStorage.saveToken(token);
      user = await _apiService.getUser(token);
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // register
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _apiService.register(name, email, password, confirmPassword);
      // await login(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // cek verifikasi
  Future<bool> checkEmailVerified() async {
    final token = await AuthStorage.getToken();
    if (token == null) return false;

    try {
      final response = await _apiService.verifiEmail(token);
      return response;
    } catch (e) {
      return false;
    }
  }

  //load user
  Future<void> loadUser() async {
    final token = await AuthStorage.getToken();
    if (token == null) return;

    try {
      user = await _apiService.getUser(token);
      notifyListeners();
    } catch (e) {
      debugPrint("LOAD USER ERROR: $e");
    }
  }

  // logout
  Future<void> logout() async {
    await AuthStorage.clear();
    user = null;
    notifyListeners();
  }
}
