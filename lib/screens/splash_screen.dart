import 'package:flutter/material.dart';
import 'package:igs_absensi/config/auth_storage.dart';
import 'package:igs_absensi/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    await Future.delayed(const Duration(seconds: 1));

    // Cek ada token tersimpan?
    final hasSession = await AuthStorage.hasSession();

    if (!hasSession) {
      _goToLogin();
      return;
    }

    // Validasi token ke server pakai endpoint /user
    final user = await _apiService.validateToken();

    if (user != null) {
      _goToHome();
    } else {
      // Token expired / tidak valid → hapus & ke login
      await AuthStorage.clear();
      _goToLogin();
    }
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ganti dengan logo app kamu
            FlutterLogo(size: 80),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
