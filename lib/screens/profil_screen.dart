import 'package:flutter/material.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfilTab extends StatelessWidget {
  const ProfilTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Center(child: Text("Profil"));
  }
}
