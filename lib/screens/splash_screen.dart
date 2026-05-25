// import 'package:flutter/material.dart';
// import 'package:igs_absensi/config/auth_storage.dart';
// import 'package:igs_absensi/services/api_service.dart';
// import 'package:provider/provider.dart';
// import 'package:igs_absensi/providers/auth_provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   final _apiService = ApiService();

//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _opacityAnimation;

//   @override
//   void initState() {
//     super.initState();

//     /// ANIMATION SETUP
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _opacityAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

//     _controller.forward();

//     _checkAutoLogin();
//   }

//   Future<void> _checkAutoLogin() async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));

//       final hasSession = await AuthStorage.hasSession();

//       if (!hasSession) {
//         _goToLogin();
//         return;
//       }

//       final user = await _apiService.validateToken();

//       if (user != null) {
//         if (!mounted) return;

//         context.read<AuthProvider>().loadUser();
//         _goToHome();
//       } else {
//         await AuthStorage.clear();
//         _goToLogin();
//       }
//     } catch (e) {
//       await AuthStorage.clear();
//       _goToLogin();
//     }
//   }

//   void _goToHome() {
//     Navigator.pushReplacementNamed(context, '/home');
//   }

//   void _goToLogin() {
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: FadeTransition(
//           opacity: _opacityAnimation,
//           child: ScaleTransition(
//             scale: _scaleAnimation,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 FlutterLogo(size: 90),
//                 SizedBox(height: 20),
//                 Text(
//                   "IGS Absensi",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 20),
//                 CircularProgressIndicator(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
