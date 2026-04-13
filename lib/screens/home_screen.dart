import 'package:flutter/material.dart';
import 'package:igs_absensi/screens/my_course_screen.dart';
import 'package:igs_absensi/screens/qr_scanner_screen.dart';
import 'package:igs_absensi/screens/dashboard_screen.dart';
import 'package:igs_absensi/screens/profil_screen.dart';
import 'package:igs_absensi/screens/search_screen.dart';
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
      CustomNavBarScreen(screen: const DashboardTab()), // index 0 - Dashboard
      CustomNavBarScreen(screen: const SearchScreen()), // index 1 - Pencarian
      CustomNavBarScreen(
        screen: const QrScannerPage(),
      ), // index 2 - QR (FAB tengah)
      CustomNavBarScreen(screen: const MyCourseScreen()), // index 3 - My Course
      CustomNavBarScreen(screen: const ProfileScreen()), // index 4 - Profil
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView.custom(
      context,
      controller: _controller,
      screens: _buildScreens(),
      itemCount: 5,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      customWidget: _BottomNav(
        selectedIndex: _controller.index,
        onItemSelected: (index) {
          setState(() => _controller.index = index);
        },
      ),
    );
  }
}

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
                  // index 0 - Dashboard
                  Expanded(
                    child: _buildItem(0, Icons.dashboard_rounded, 'Home'),
                  ),
                  // index 1 - Pencarian
                  Expanded(child: _buildItem(1, Icons.search, 'Pencarian')),
                  // Spacer untuk FAB QR (index 2) di tengah
                  const SizedBox(width: 72),
                  // index 3 - My Course
                  Expanded(child: _buildItem(3, Icons.book, 'Kelas Saya')),
                  // index 4 - Profil
                  Expanded(
                    child: _buildItem(4, Icons.person_rounded, 'Profil'),
                  ),
                ],
              ),
            ),
          ),

          // FAB tengah - index 2 (QR Scanner)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onItemSelected(2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedIndex == 2
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
                    size: selectedIndex == 2 ? 30 : 26,
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
