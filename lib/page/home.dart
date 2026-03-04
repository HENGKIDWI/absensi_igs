import 'package:flutter/material.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Center(
        child: user == null
            ? const Text("Tidak ada user login", style: TextStyle(fontSize: 16))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    "Selamat datang 👋",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ],
              ),
      ),
    );
  }
}
