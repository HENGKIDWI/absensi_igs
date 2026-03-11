import 'package:flutter/material.dart';
import 'package:igs_absensi/config/auth_storage.dart';
import 'package:igs_absensi/model/user_model.dart';
import 'package:igs_absensi/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  bool isVerified = false;

  User? user;

  String? pendingEmail;

  // LOGIN
  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.login(email, password);

      if (!success) {
        throw Exception("LOGIN_FAILED");
      }

      final token = await AuthStorage.getToken();

      user = await _apiService.getUser(token!);

      if (user!.emailVerifiedAt != null) {
        isVerified = true;
      } else {
        isVerified = false;
        pendingEmail = email;
        throw Exception("EMAIL_NOT_VERIFIED");
      }
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // REGISTER
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

      pendingEmail = email;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // VERIFY OTP
  Future<void> verifyOtp({required String email, required String otp}) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.verifyEmail(email, otp);

      final token = result['token'];

      await AuthStorage.saveToken(token);

      user = result['user'];

      isVerified = true;
    } catch (e) {
      debugPrint("VERIFY OTP ERROR: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // RESEND OTP
  Future<void> resendOtp(String email) async {
    try {
      await _apiService.resendOtp(email);
    } catch (e) {
      debugPrint("RESEND OTP ERROR: $e");
    }
  }

  // LOAD USER
  Future<void> loadUser() async {
    final token = await AuthStorage.getToken();

    if (token == null) {
      debugPrint("User belum login");
      return;
    }

    try {
      final userData = await _apiService.getUser(token);

      user = userData;

      if (user!.emailVerifiedAt != null) {
        isVerified = true;
        debugPrint("Email sudah diverifikasi");
      } else {
        isVerified = false;
        debugPrint("Email belum diverifikasi");
      }

      notifyListeners();
    } catch (e) {
      debugPrint("LOAD USER ERROR: $e");
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await AuthStorage.clear();

    user = null;

    notifyListeners();
  }
}
