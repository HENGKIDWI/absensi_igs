import 'package:flutter/material.dart';
import 'package:igs_absensi/screens/forgot_password/otp_screen.dart';
import 'package:igs_absensi/services/api_service.dart';
import 'package:igs_absensi/widgets/custom_text_field.dart';
import 'package:igs_absensi/widgets/primary_button.dart';

class LupaPassword extends StatefulWidget {
  const LupaPassword({super.key});

  @override
  State<LupaPassword> createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  final emailController = TextEditingController();
  final api = ApiService();
  bool isLoading = false;

  void sendOtp() async {
    if (emailController.text.isEmpty) return;

    setState(() => isLoading = true);
    try {
      await api.sendOtp(emailController.text);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(email: emailController.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// ICON (diperkecil biar tidak dominan)
                Icon(Icons.lock_reset, size: 80, color: Colors.blueAccent),

                const SizedBox(height: 20),

                /// TITLE
                const Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                /// SUBTITLE
                const Text(
                  "Masukkan email untuk menerima kode OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                /// INPUT (FOKUS UTAMA)
                CustomTextField(
                  label: "Email",
                  hint: "Masukkan email",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                ),

                const SizedBox(height: 25),

                /// BUTTON FULL WIDTH
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: PrimaryButton(
                    text: "Kirim OTP",
                    isLoading: isLoading,
                    onPressed: sendOtp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
