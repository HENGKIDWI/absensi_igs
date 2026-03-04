import 'package:flutter/material.dart';
import 'package:igs_absensi/page/home.dart';
import 'package:igs_absensi/page/lupa_password.dart';
import 'package:igs_absensi/page/register.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:igs_absensi/widgets/auth_text_button.dart';
import 'package:igs_absensi/widgets/custom_text_field.dart';
import 'package:igs_absensi/widgets/primary_button.dart';
import 'package:igs_absensi/widgets/verify_email_dialog.dart';
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
                    forgotPasswordTextButton(context),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return auth.isLoading
                            ? const CircularProgressIndicator()
                            : loginButton(context);
                      },
                    ),
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
      onPressed: () async {
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

          // Berhasil → navigasi ke home
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          }
        } catch (e) {
          if (e.toString().contains('EMAIL_NOT_VERIFIED')) {
            // Tampilkan dialog verifikasi
            if (context.mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => VerifyEmailDialog(
                  email: emailController.text,
                  password: passwordController.text,
                  onVerified: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                ),
              );
            }
          } else {
            // Error lain (salah password, dll)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      },
    );
  }

  AuthTextButton forgotPasswordTextButton(BuildContext context) {
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
