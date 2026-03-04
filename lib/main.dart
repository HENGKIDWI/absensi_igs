import 'package:flutter/material.dart';
import 'package:igs_absensi/page/home.dart';
import 'package:igs_absensi/page/login.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent, // ganti warna utama
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.user != null) {
            return const HomePage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
