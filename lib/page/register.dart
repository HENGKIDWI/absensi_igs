import 'package:flutter/material.dart';
import 'package:igs_absensi/page/verify_email.dart';
import 'package:provider/provider.dart';
import 'package:igs_absensi/page/login.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:igs_absensi/widgets/auth_text_button.dart';
import 'package:igs_absensi/widgets/custom_text_field.dart';
import 'package:igs_absensi/widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(AuthProvider auth) async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password tidak sama")));
      return;
    }

    try {
      await auth.register(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerifyPage(email: emailController.text),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _handleToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 320,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', width: 200, height: 100),
                const SizedBox(height: 40),
                const Text("ABSENSI DIGITAL"),
                const SizedBox(height: 45),

                CustomTextField(
                  label: "Nama Lengkap",
                  controller: nameController,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: "Email",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: "Password",
                  controller: passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: "Konfirmasi Password",
                  controller: confirmPasswordController,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 24),

                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return auth.isLoading
                        ? const CircularProgressIndicator()
                        : PrimaryButton(
                            text: "Daftar",
                            onPressed: () => _handleRegister(auth),
                          );
                  },
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah memiliki akun?"),
                    AuthTextButton(
                      text: 'Login',
                      warnaText: Colors.blueAccent,
                      alignment: Alignment.center,
                      onPressed: _handleToLogin,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
