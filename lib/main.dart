import 'package:flutter/material.dart';
import 'package:igs_absensi/screens/home_screen.dart';
import 'package:igs_absensi/screens/login_screen.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();

  runApp(
    ChangeNotifierProvider.value(value: authProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isInitialized) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (auth.user != null && auth.isVerified) {
            return const HomePage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}
