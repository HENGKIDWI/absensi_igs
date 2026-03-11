import 'package:flutter/material.dart';
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

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Kode OTP",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return auth.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          try {
                            await auth.verifyOtp(
                              email: widget.email,
                              otp: otpController.text,
                            );

                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomePage(),
                                ),
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },

                        child: const Text("Verifikasi"),
                      );
              },
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                context.read<AuthProvider>().resendOtp(widget.email);
              },
              child: const Text("Kirim ulang OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
