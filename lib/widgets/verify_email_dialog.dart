import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:igs_absensi/providers/auth_provider.dart';

class VerifyEmailDialog extends StatefulWidget {
  final String email;
  final String password;
  final VoidCallback? onVerified;

  const VerifyEmailDialog({
    super.key,
    required this.email,
    required this.password,
    this.onVerified,
  });

  @override
  State<VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends State<VerifyEmailDialog> {
  bool isChecking = false;
  bool isResending = false;

  Future<void> _openEmailApp() async {
    final uris = [
      Uri.parse('googlegmail://'),
      Uri.parse('intent:#Intent;package=com.google.android.gm;end'),
      Uri(scheme: 'mailto'),
    ];

    for (final uri in uris) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada aplikasi email yang tersedia')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: const [
          Icon(Icons.mark_email_read, size: 72, color: Colors.blueAccent),
          SizedBox(height: 12),
          Text("Verifikasi Email", textAlign: TextAlign.center),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Kami telah mengirim email verifikasi ke:",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.email,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "Silakan buka email dan klik link verifikasi sebelum melanjutkan.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        OutlinedButton.icon(
          onPressed: _openEmailApp,
          icon: const Icon(Icons.email),
          label: const Text("Buka Email"),
        ),

        ElevatedButton(
          onPressed: isChecking
              ? null
              : () async {
                  setState(() => isChecking = true);

                  try {
                    await context.read<AuthProvider>().login(
                      email: widget.email,
                      password: widget.password,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      widget.onVerified?.call();
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Email belum diverifikasi")),
                    );
                  } finally {
                    setState(() => isChecking = false);
                  }
                },
          child: isChecking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text("Saya sudah verifikasi"),
        ),
      ],
    );
  }
}
