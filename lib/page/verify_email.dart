import 'package:flutter/material.dart';
import 'package:igs_absensi/widgets/custom_text_field.dart';
import 'package:igs_absensi/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:igs_absensi/page/home.dart';

class EmailVerifyPage extends StatefulWidget {
  final String email;

  const EmailVerifyPage({super.key, required this.email});

  @override
  State<EmailVerifyPage> createState() => _EmailVerifyPageState();
}

class _EmailVerifyPageState extends State<EmailVerifyPage> {
  final otpController = TextEditingController();

  // ignore: unused_element
  Future<void> _handleVerifyOtp(AuthProvider auth) async {
    try {
      await auth.verifyOtp(email: widget.email, otp: otpController.text);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // ignore: unused_element
  void _handleResendOtp(AuthProvider auth) {
    auth.resendOtp(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi Email")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.mark_email_read, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              "Kode OTP telah dikirim ke\n${widget.email}",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            otpTextField(context),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return auth.isLoading
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              text: "Kirim ulang OTP",
              onPressed: () => _handleResendOtp(context.read<AuthProvider>()),
            ),
          ],
        ),
      ),
    );
  }

  CustomTextField otpTextField(BuildContext context) {
    return CustomTextField(
      controller: otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        labelText: "Kode OTP",
        border: OutlineInputBorder(),
        counterText: "",
      ),
      onChanged: (value) {
        if (value.length == 6) {
          _handleVerifyOtp(context.read<AuthProvider>());
        }
      },
      label: '',
    );
  }
}
