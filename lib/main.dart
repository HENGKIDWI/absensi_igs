import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:igs_absensi/screens/navbar.dart';
import 'package:igs_absensi/screens/auth/login_screen.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:igs_absensi/screens/my_class/my_class.dart'
    show AppRouteObserver;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..tryAutoLogin(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      // ← tambahkan ini
      controller: EventController(),
      child: MaterialApp(
        navigatorObservers: [AppRouteObserver.instance],
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
      ),
    );
  }
}
