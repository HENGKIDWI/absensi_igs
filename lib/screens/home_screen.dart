import 'package:flutter/material.dart';
import 'package:igs_absensi/screens/qr_scanner_screen.dart';
import 'package:igs_absensi/screens/dashboard_screen.dart';
import 'package:igs_absensi/screens/profil_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<CustomNavBarScreen> _buildScreens() {
    return [
      CustomNavBarScreen(screen: const DashboardTab()),
      CustomNavBarScreen(screen: const QrScannerPage()),
      CustomNavBarScreen(screen: const ProfilTab()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView.custom(
      context,
      controller: _controller,
      screens: _buildScreens(),
      itemCount: 3,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      customWidget: _BottomNav(
        selectedIndex: _controller.index,
        onItemSelected: (index) {
          setState(() => _controller.index = index); // WAJIB ada ini
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BOTTOM NAV
// ─────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _BottomNav({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bar background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Tab 0 - Dashboard
                  Expanded(
                    child: _buildItem(0, Icons.dashboard_rounded, 'Dashboard'),
                  ),
                  // Spacer ruang FAB tengah
                  const SizedBox(width: 72),
                  // Tab 2 - Profil
                  Expanded(
                    child: _buildItem(2, Icons.person_rounded, 'Profil'),
                  ),
                ],
              ),
            ),
          ),

          // FAB tengah - Tab 1 (Absensi)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onItemSelected(1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedIndex == 1
                        ? Colors.blueAccent
                        : Colors.blueAccent.withOpacity(0.85),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: selectedIndex == 1 ? 30 : 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index, IconData icon, String label) {
    final selected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? Colors.blueAccent : Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? Colors.blueAccent : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
