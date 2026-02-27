import 'package:flutter/material.dart';
import 'package:igs_absensi/page/home.dart';
import 'package:igs_absensi/page/login.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 320,
            child: Column(
              children: [
                //  LOGO
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 100,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),
                Text("ABSENSI DIGITAL"),
                const SizedBox(height: 45),
                // FORM
                CustomTextField(
                  label: "Nama Lengkap",
                  controller: nameController,
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
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: "Konfirmasi Password",
                  controller: confirmPasswordController,
                  obscureText: true,
                ),

                const SizedBox(height: 24),

                PrimaryButton(
                  text: "Daftar",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Sudah memiliki akun?"),
                    registerTextButton(context),
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

AuthTextButton registerTextButton(BuildContext context) {
  return AuthTextButton(
    text: 'Login',
    warnaText: Colors.blueAccent,
    alignment: Alignment.center,
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    },
  );
}
