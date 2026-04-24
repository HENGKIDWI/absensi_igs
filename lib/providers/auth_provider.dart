import 'package:flutter/material.dart';
import 'package:igs_absensi/config/auth_storage.dart';
import 'package:igs_absensi/model/user.dart';
import 'package:igs_absensi/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  bool isVerified = false;
  bool isInitialized = false;

  User? user;
  String? pendingEmail;

  Future<void> tryAutoLogin() async {
    final token = await AuthStorage.getToken();
    // while (true) {
    //   if (isInitialized) break;
    //   await Future.delayed(const Duration(seconds: 1));
    // }
    if (token == null) {
      isInitialized = true;
      notifyListeners();
      return;
    }

    try {
      final userData = await _apiService.getUser(token);
      user = userData;
      isVerified = user!.emailVerifiedAt != null;
    } catch (e) {
      await AuthStorage.clear();
      user = null;
      debugPrint("AUTO LOGIN FAILED: $e");
    } finally {
      isInitialized = true;
      notifyListeners();
    }
  }

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
    required int facultyId,
    required int studyProgramId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.register(
        name,
        email,
        password,
        confirmPassword,
        facultyId,
        studyProgramId,
      );

      final token = result['token'];
      await AuthStorage.saveToken(token);

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
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
