import 'package:flutter/material.dart';
import 'package:igs_absensi/page/home.dart';
import 'package:igs_absensi/page/lupa_password.dart';
import 'package:igs_absensi/page/register.dart';
import 'package:igs_absensi/page/verify_email.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:igs_absensi/widgets/auth_text_button.dart';
import 'package:igs_absensi/widgets/custom_text_field.dart';
import 'package:igs_absensi/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('EMAIL_NOT_VERIFIED')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerifyPage(email: emailController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _handleNavigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void _handleNavigateToForgotPassword() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LupaPassword()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              const Text("ABSENSI DIGITAL"),
              const SizedBox(height: 45),
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Password',
                      controller: passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    AuthTextButton(
                      text: "Lupa Password?",
                      warnaText: Colors.redAccent,
                      alignment: Alignment.bottomRight,
                      onPressed: _handleNavigateToForgotPassword,
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return auth.isLoading
                            ? const CircularProgressIndicator()
                            : PrimaryButton(
                                text: 'Login',
                                onPressed: _handleLogin,
                              );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum memiliki akun?"),
                        AuthTextButton(
                          text: 'Register',
                          warnaText: Colors.blueAccent,
                          alignment: Alignment.center,
                          onPressed: _handleNavigateToRegister,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
