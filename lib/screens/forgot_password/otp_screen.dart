import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:igs_absensi/screens/forgot_password/reset_password_screen.dart';
import 'package:igs_absensi/services/api_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final api = ApiService();
  String otpCode = '';
  bool isLoading = false;

  void verifyOtp() async {
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Masukkan 6 digit OTP")));
      return;
    }

    setState(() => isLoading = true);
    try {
      String resetToken = await api.checkOtp(otpCode);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(resetToken: resetToken),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("OTP tidak valid")));
    }
    setState(() => isLoading = false);
  }

  void resendOtp() async {
    try {
      await api.sendOtp(widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP berhasil dikirim ulang")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengirim ulang OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// ICON
                const Icon(
                  Icons.mark_email_read,
                  size: 80,
                  color: Colors.blueAccent,
                ),

                const SizedBox(height: 20),

                /// TITLE
                const Text(
                  "Masukkan Kode OTP",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                /// SUBTITLE
                Text(
                  "Kode dikirim ke\n${widget.email}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                /// OTP FIELD
                OtpTextField(
                  numberOfFields: 6,
                  borderColor: Colors.blueAccent,
                  showFieldAsBox: true,
                  fieldWidth: 45,
                  borderRadius: BorderRadius.circular(8),
                  onCodeChanged: (code) {
                    otpCode = code;
                  },
                  onSubmit: (code) {
                    otpCode = code;
                    verifyOtp();
                  },
                ),

                const SizedBox(height: 30),

                /// RESEND (SECONDARY)
                TextButton(
                  onPressed: resendOtp,
                  child: const Text("Kirim ulang OTP"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
