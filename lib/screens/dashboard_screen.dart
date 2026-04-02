import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// ignore: unused_element
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  // TODO: ganti dengan data dari API
  static const _rekapData = {
    'hadir': 18,
    'tidak_hadir': 2,
    'terlambat': 3,
    'izin_sakit': 1,
    'total': 24,
  };

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Selamat Pagi'
        : now.hour < 15
        ? 'Selamat Siang'
        : now.hour < 18
        ? 'Selamat Sore'
        : 'Selamat Malam';

    return Center(child: Text("dashboard"));
  }
}
