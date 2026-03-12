import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
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
  String otpCode = '';

  // ignore: unused_element
  Future<void> _handleVerifyOtp(AuthProvider auth) async {
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan kode OTP 6 digit")),
      );
      return;
    }

    try {
      await auth.verifyOtp(email: widget.email, otp: otpCode);

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
            OtpTextField(
              numberOfFields: 6,
              borderColor: Colors.blueAccent,
              showFieldAsBox: true,
              fieldWidth: 43,
              onCodeChanged: (String code) {
                otpCode = code;
              },
              onSubmit: (String code) {
                otpCode = code;
                _handleVerifyOtp(context.read<AuthProvider>());
              },
            ),
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
}
