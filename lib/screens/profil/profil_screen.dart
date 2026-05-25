import 'package:flutter/material.dart';
import 'package:igs_absensi/screens/auth/login_screen.dart';
import 'package:igs_absensi/screens/profil/edit_profil_screen.dart';
import 'package:provider/provider.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:igs_absensi/services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = user?.name ?? '-';
    final email = user?.email ?? '-';
    final isVerified = user?.emailVerifiedAt != null;

    // Inisial dari 2 kata pertama nama
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();

    return Scaffold(
      backgroundColor: const Color(0xFFABE4FF),
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(
              name: name,
              email: email,
              initials: initials,
              isVerified: isVerified,
              onEditTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ).then((_) {
                    // refresh profil setelah kembali dari edit
                    context.read<AuthProvider>().fetchProfile();
                  }),
            ),
          ),

          // ── Menu items ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'Akun'),
                  const SizedBox(height: 10),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Nama',
                        value: name,
                      ),
                      _MenuItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: email,
                      ),
                      _MenuItem(
                        icon: Icons.verified_outlined,
                        label: 'Status Email',
                        value: isVerified
                            ? 'Terverifikasi'
                            : 'Belum diverifikasi',
                        valueColor: isVerified
                            ? const Color(0xFF27500A)
                            : const Color(0xFF633806),
                        valueBg: isVerified
                            ? const Color(0xFFEAF3DE)
                            : const Color(0xFFFAEEDA),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _SectionLabel(label: 'Lainnya'),
                  const SizedBox(height: 10),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'Versi Aplikasi',
                        value: '1.0.0',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Logout button ─────────────────────────
                  _LogoutButton(name: name),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String initials;
  final bool isVerified;
  final VoidCallback onEditTap;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.initials,
    required this.isVerified,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 32,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C447C), Color(0xFF185FA5)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onEditTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          Text(
            email,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified
                  ? Colors.white.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isVerified
                    ? Colors.white.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  size: 13,
                  color: isVerified ? Colors.white : Colors.orange.shade200,
                ),
                const SizedBox(width: 5),
                Text(
                  isVerified
                      ? 'Email Terverifikasi'
                      : 'Email Belum Diverifikasi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isVerified ? Colors.white : Colors.orange.shade200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Menu card (grouped) ───────────────────────────────────
class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F1FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.icon,
                        size: 17,
                        color: const Color(0xFF0C447C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Value bisa berupa pill atau teks biasa
                          if (item.valueBg != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: item.valueBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.value,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: item.valueColor,
                                ),
                              ),
                            )
                          else
                            Text(
                              item.value,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 62,
                  color: Colors.grey.shade100,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? valueBg;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBg,
  });
}

// ── Logout button ─────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final String name;
  const _LogoutButton({required this.name});

  void _confirmLogout(BuildContext context) {
    final rootContext = context; // simpan context utama

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: Text('Yakin ingin keluar dari akun $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // tutup dialog

              await ApiService().logout();

              if (!rootContext.mounted) return;

              Navigator.pushAndRemoveUntil(
                rootContext,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Logout',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF5350),
          side: const BorderSide(color: Color(0xFFEF5350)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
