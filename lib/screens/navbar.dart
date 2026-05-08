import 'package:flutter/material.dart';
import 'package:igs_absensi/screens/my_class/my_class.dart';
import 'package:igs_absensi/screens/qr_scanner_screen.dart';
import 'package:igs_absensi/screens/home/home_screen.dart';
import 'package:igs_absensi/screens/profil_screen.dart';
import 'package:igs_absensi/screens/class_list/class_list.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class navbar extends StatefulWidget {
  const navbar({super.key});

  @override
  State<navbar> createState() => _navbarState();
}

class _navbarState extends State<navbar> {
  late final PersistentTabController _controller;
  final GlobalKey<MyClassScreenState> _myClassKey = GlobalKey();
  late final List<CustomNavBarScreen> _screens;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _controller.addListener(_onTabChanged);
    _screens = [
      CustomNavBarScreen(screen: const HomeScreen()),
      CustomNavBarScreen(
        screen: SearchScreen(onEnrollSuccess: _onEnrollSuccess),
      ),
      CustomNavBarScreen(screen: const QrScannerPage()),
      CustomNavBarScreen(screen: MyClassScreen(key: _myClassKey)),
      CustomNavBarScreen(screen: const ProfileScreen()),
    ];
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_controller.index == 3) {
      _myClassKey.currentState?.loadData();
    }
  }

  void _onEnrollSuccess() {
    _myClassKey.currentState?.refreshData();
  }

  List<CustomNavBarScreen> _buildScreens() {
    return [
      CustomNavBarScreen(screen: const HomeScreen()),
      CustomNavBarScreen(
        screen: SearchScreen(onEnrollSuccess: _onEnrollSuccess),
      ),
      CustomNavBarScreen(screen: const QrScannerPage()),
      CustomNavBarScreen(screen: MyClassScreen(key: _myClassKey)),
      CustomNavBarScreen(screen: const ProfileScreen()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView.custom(
      context,
      controller: _controller,
      screens: _screens,
      itemCount: 5,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      stateManagement: false,
      hideNavigationBarWhenKeyboardAppears: true,
      customWidget: _BottomNav(
        selectedIndex: _controller.index,
        // di navbar.dart
        onItemSelected: (index) {
          setState(() => _controller.index = index);

          if (index == 3) {
            // ✅ tunggu frame selesai render dulu
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print(
                'MY CLASS KEY STATE (post frame): ${_myClassKey.currentState}',
              );
              _myClassKey.currentState?.loadData();
            });
          }
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
            child: ClipPath(
              clipper: BottomNavClipper(),
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
                    Expanded(child: _buildItem(0, Icons.home, 'Home')),
                    // index 1 - Pencarian
                    Expanded(child: _buildItem(1, Icons.list, 'Daftar Kelas')),
                    // Spacer untuk FAB QR (index 2) di tengah
                    const SizedBox(width: 72),
                    // index 3 - My Course
                    Expanded(child: _buildItem(3, Icons.class_, 'Kelas Saya')),
                    // index 4 - Profil
                    Expanded(
                      child: _buildItem(4, Icons.person_rounded, 'Profil'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // FAB tengah - index 2 (QR Scanner)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 60,
                height: 60,
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
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index, IconData icon, String label) {
    final selected = index == selectedIndex;
    return GestureDetector(
      onTap: () {
        print('_buildItem TAP: $index');
        onItemSelected(index);
      },
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

class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    final fabRadius = 36.0;
    final centerX = size.width / 2;

    path.lineTo(centerX - fabRadius - 10, 0);

    path.quadraticBezierTo(
      centerX - fabRadius,
      0,
      centerX - fabRadius + 10,
      10,
    );

    path.arcToPoint(
      Offset(centerX + fabRadius - 10, 10),
      radius: Radius.circular(fabRadius),
      clockwise: false,
    );

    path.quadraticBezierTo(centerX + fabRadius, 0, centerX + fabRadius + 10, 0);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
