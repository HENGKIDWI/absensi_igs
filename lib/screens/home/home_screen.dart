import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:igs_absensi/DTO/schedule.dart';
import 'package:provider/provider.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:igs_absensi/services/api_service.dart';
import 'package:igs_absensi/model/schedule.dart';
import 'package:igs_absensi/screens/home/kalender_screen.dart';

// ── Attendance dummy (ganti dengan API jika sudah ada endpoint) ──
class _AttendanceData {
  final String day;
  final int hadir;
  final int izin;
  final int alfa;
  final int total;

  const _AttendanceData({
    required this.day,
    required this.hadir,
    required this.izin,
    required this.alfa,
    required this.total,
  });
}

const _weeklyAttendance = [
  _AttendanceData(day: 'Sen', hadir: 3, izin: 0, alfa: 0, total: 3),
  _AttendanceData(day: 'Sel', hadir: 2, izin: 1, alfa: 0, total: 3),
  _AttendanceData(day: 'Rab', hadir: 2, izin: 1, alfa: 1, total: 4),
  _AttendanceData(day: 'Kam', hadir: 1, izin: 0, alfa: 1, total: 2),
  _AttendanceData(day: 'Jum', hadir: 2, izin: 1, alfa: 0, total: 3),
  _AttendanceData(day: 'Sab', hadir: 0, izin: 0, alfa: 1, total: 1),
];

// Hari ini dalam format singkat (sesuai _weeklyAttendance)
String get _todayShort {
  const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  return days[(DateTime.now().weekday - 1) % 7];
}

// ── Enum status kehadiran ────────────────────────────────
enum _AttendanceStatus { belumMulai, hadir, tidakHadir, selesai }

_AttendanceStatus _parseStatus(String? raw) {
  switch (raw) {
    case 'hadir':
      return _AttendanceStatus.hadir;
    case 'tidak_hadir':
    case 'tidakHadir':
      return _AttendanceStatus.tidakHadir;
    case 'selesai':
      return _AttendanceStatus.selesai;
    default:
      return _AttendanceStatus.belumMulai;
  }
}

// ── Warna tema ───────────────────────────────────────────
const _primary = Color(0xFF0C447C);
const _accent = Color(0xFFABE4FF);
const _green = Color(0xFF4CAF82);
const _blue = Color(0xFF4A7BD4);
const _red = Color(0xFFEF5350);

// ════════════════════════════════════════════════════════
// HomeScreen
// ════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  ScheduleResponse? _scheduleResponse;
  bool _isLoading = true;
  String? _error;

  bool _akanDatangExpanded = false;

  late AnimationController _barAnimController;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _barAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _barAnim = CurvedAnimation(
      parent: _barAnimController,
      curve: Curves.easeOutCubic,
    );
    _barAnimController.forward();
    _fetchSchedule();
  }

  @override
  void dispose() {
    _barAnimController.dispose();
    super.dispose();
  }

  Future<void> _fetchSchedule() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _apiService.getSchedule();
      if (!mounted) return;
      setState(() {
        _scheduleResponse = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Tidak dapat memuat jadwal';
        _isLoading = false;
      });
    }
  }

  String _capitalizeFirst(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String get _todayLabel => _scheduleResponse != null
      ? _capitalizeFirst(_scheduleResponse!.today)
      : 'Hari ini';

  String get _tomorrowLabel => _scheduleResponse != null
      ? _capitalizeFirst(_scheduleResponse!.tomorrow)
      : 'Besok';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = user?.name ?? 'Mahasiswa';
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();

    return Scaffold(
      backgroundColor: _accent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchSchedule,
          color: _primary,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // ── Top bar ──
              _TopBar(name: name, initials: initials),
              const SizedBox(height: 20),

              // ── Grafik kehadiran ──
              _AttendanceChart(animation: _barAnim),
              const SizedBox(height: 20),

              // ── Jadwal Hari Ini ──
              _SectionLabel(label: _todayLabel),
              const SizedBox(height: 10),
              _buildScheduleSection(
                items: _scheduleResponse?.todayCourses,
                isLoading: _isLoading,
                error: _error,
              ),
              const SizedBox(height: 4),

              // ── Jadwal Besok ──
              _SectionLabel(label: _tomorrowLabel),
              const SizedBox(height: 10),
              _buildScheduleSection(
                items: _scheduleResponse?.tomorrowCourses,
                isLoading: _isLoading,
                error: _error,
              ),
              const SizedBox(height: 4),

              // ── Akan Datang (dummy sementara) ──
              _AkanDatangHeader(
                expanded: _akanDatangExpanded,
                onTap: () =>
                    setState(() => _akanDatangExpanded = !_akanDatangExpanded),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _akanDatangExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Column(
                  children: [
                    _ScheduleCard(
                      name: 'Pemrograman Web',
                      room: 'Lab B2',
                      startTime: '08:00',
                      endTime: '09:40',
                      status: null,
                    ),
                    _ScheduleCard(
                      name: 'Jaringan Komputer',
                      room: 'Lab C1',
                      startTime: '10:00',
                      endTime: '11:40',
                      status: 'selesai',
                    ),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
              ),

              const SizedBox(height: 12),

              // ── Tombol lihat jadwal lengkap ──
              _FullScheduleButton(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KalenderScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection({
    required List<ScheduleModel>? items,
    required bool isLoading,
    required String? error,
  }) {
    if (isLoading) return const _LoadingCard();
    if (error != null)
      return _ErrorCard(message: error, onRetry: _fetchSchedule);
    if (items == null || items.isEmpty) return const _EmptyCard();

    return Column(
      children: items
          .map(
            (e) => _ScheduleCard(
              name: e.name,
              room: e.room,
              startTime: e.formattedStartTime,
              endTime: e.formattedEndTime,
              status: e.status,
            ),
          )
          .toList(),
    );
  }
}

// ════════════════════════════════════════════════════════
// _TopBar
// ════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String name;
  final String initials;

  const _TopBar({required this.name, required this.initials});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Text(
              name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        // CircleAvatar(
        //   radius: 20,
        //   backgroundColor: const Color(0xFFE6F1FB),
        //   child: Text(
        //     initials,
        //     style: const TextStyle(
        //       fontSize: 13,
        //       fontWeight: FontWeight.w600,
        //       color: _primary,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// _AttendanceChart
// ════════════════════════════════════════════════════════
class _AttendanceChart extends StatelessWidget {
  final Animation<double> animation;
  const _AttendanceChart({required this.animation});

  int get _totalHadir => _weeklyAttendance.fold(0, (s, e) => s + e.hadir);
  int get _totalIzin => _weeklyAttendance.fold(0, (s, e) => s + e.izin);
  int get _totalAlfa => _weeklyAttendance.fold(0, (s, e) => s + e.alfa);
  int get _totalKelas => _weeklyAttendance.fold(0, (s, e) => s + e.total);

  @override
  Widget build(BuildContext context) {
    final pct = _totalKelas == 0
        ? 0
        : ((_totalHadir / _totalKelas) * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kehadiran Minggu Ini',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_totalHadir dari $_totalKelas kelas',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$pct',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                    const TextSpan(
                      text: '%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Summary chips
          Row(
            children: [
              _SummaryChip(
                label: 'Hadir',
                value: _totalHadir,
                bgColor: const Color(0xFFEAF3DE),
                textColor: const Color(0xFF27500A),
                iconColor: _green,
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'Izin',
                value: _totalIzin,
                bgColor: const Color(0xFFE8F0FB),
                textColor: const Color(0xFF1A3A6B),
                iconColor: _blue,
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'Alfa',
                value: _totalAlfa,
                bgColor: const Color(0xFFFCEBEB),
                textColor: const Color(0xFF791F1F),
                iconColor: _red,
                icon: Icons.cancel_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar chart
          AnimatedBuilder(
            animation: animation,
            builder: (_, __) => SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _weeklyAttendance
                    .map((d) => _Bar(data: d, animValue: animation.value))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendDot(color: _green, label: 'Hadir'),
              SizedBox(width: 14),
              _LegendDot(color: _blue, label: 'Izin'),
              SizedBox(width: 14),
              _LegendDot(color: _red, label: 'Alfa'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final _AttendanceData data;
  final double animValue;
  const _Bar({required this.data, required this.animValue});

  @override
  Widget build(BuildContext context) {
    const maxH = 72.0;
    final isToday = data.day == _todayShort;

    double frac(int v) => data.total == 0 ? 0 : (v / data.total) * animValue;

    final hadirH = (maxH * frac(data.hadir)).clamp(0.0, maxH);
    final izinH = (maxH * frac(data.izin)).clamp(0.0, maxH);
    final alfaH = (maxH * frac(data.alfa)).clamp(0.0, maxH);
    final totalH = (hadirH + izinH + alfaH).clamp(4.0, maxH);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${data.hadir}/${data.total}',
              style: TextStyle(
                fontSize: 9,
                color: isToday ? _primary : Colors.grey.shade400,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 3),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: double.infinity,
                height: totalH,
                child: data.hadir == 0 && data.izin == 0 && data.alfa == 0
                    ? Container(color: Colors.grey.shade200)
                    : Column(
                        children: [
                          if (data.hadir > 0)
                            Flexible(
                              flex: data.hadir,
                              child: Container(
                                color: isToday
                                    ? _green
                                    : _green.withOpacity(0.45),
                              ),
                            ),
                          if (data.izin > 0)
                            Flexible(
                              flex: data.izin,
                              child: Container(
                                color: isToday
                                    ? _blue
                                    : _blue.withOpacity(0.45),
                              ),
                            ),
                          if (data.alfa > 0)
                            Flexible(
                              flex: data.alfa,
                              child: Container(
                                color: isToday ? _red : _red.withOpacity(0.45),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data.day,
              style: TextStyle(
                fontSize: 11,
                color: isToday ? _primary : Colors.grey.shade500,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// Reusable widgets
// ════════════════════════════════════════════════════════

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
        color: Colors.black87,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int value;
  final Color bgColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.bgColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String name;
  final String? room;
  final String startTime;
  final String? endTime;
  final String? status;

  const _ScheduleCard({
    required this.name,
    this.room,
    required this.startTime,
    this.endTime,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final st = _parseStatus(status);
    final cfg = _statusConfig(st);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (room != null && room!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    room!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cfg.bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cfg.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: cfg.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                startTime,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (endTime != null && endTime!.isNotEmpty)
                Text(
                  endTime!,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
            ],
          ),
        ],
      ),
    );
  }

  ({String label, Color bgColor, Color textColor}) _statusConfig(
    _AttendanceStatus s,
  ) {
    switch (s) {
      case _AttendanceStatus.hadir:
        return (
          label: 'Hadir',
          bgColor: const Color(0xFFEAF3DE),
          textColor: const Color(0xFF27500A),
        );
      case _AttendanceStatus.tidakHadir:
        return (
          label: 'Tidak Hadir',
          bgColor: const Color(0xFFFCEBEB),
          textColor: const Color(0xFF791F1F),
        );
      case _AttendanceStatus.selesai:
        return (
          label: 'Selesai',
          bgColor: const Color(0xFFF1EFE8),
          textColor: const Color(0xFF444441),
        );
      case _AttendanceStatus.belumMulai:
        return (
          label: 'Belum Mulai',
          bgColor: const Color(0xFFFAEEDA),
          textColor: const Color(0xFF633806),
        );
    }
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Text(
          'Tidak ada kelas',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red.shade300),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Coba lagi',
              style: TextStyle(fontSize: 12, color: _primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _AkanDatangHeader extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  const _AkanDatangHeader({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionLabel(label: 'Akan Datang'),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScheduleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FullScheduleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      child: const Text(
        'Lihat Jadwal Selengkapnya',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
    );
  }
}
