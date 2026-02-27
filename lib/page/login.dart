import 'package:flutter/material.dart';
import 'package:igs_absensi/page/home.dart';
import 'package:igs_absensi/page/lupa_password.dart';
import 'package:igs_absensi/page/register.dart';
import 'package:igs_absensi/widgets/auth_text_button.dart';
import 'package:igs_absensi/widgets/custom_text_field.dart';
import 'package:igs_absensi/widgets/primary_button.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              //  FORM
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Email',
                      controller: emailController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Password',
                      controller: passwordController,
                      obscureText: true,
                    ),
                    lupaPassword(context),
                    loginButton(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Belum memiliki akun?"),
                        registerTextButton(context),
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

  AuthTextButton registerTextButton(BuildContext context) {
    return AuthTextButton(
      text: 'Register',
      warnaText: Colors.blueAccent,
      alignment: Alignment.center,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
    );
  }

  PrimaryButton loginButton(BuildContext context) {
    return PrimaryButton(
      text: 'Login',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      },
    );
  }

  AuthTextButton lupaPassword(BuildContext context) {
    return AuthTextButton(
      text: "Lupa Password?",
      warnaText: Colors.redAccent,
      alignment: Alignment.bottomRight,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LupaPassword()),
        );
      },
    );
  }
}
