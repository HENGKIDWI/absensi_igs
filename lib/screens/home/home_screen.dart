import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:igs_absensi/DTO/attendance_summary.dart';
import 'package:igs_absensi/DTO/schedule.dart';
import 'package:provider/provider.dart';
import 'package:igs_absensi/providers/auth_provider.dart';
import 'package:igs_absensi/services/api_service.dart';
import 'package:igs_absensi/model/schedule.dart';
import 'package:igs_absensi/screens/home/kalender_screen.dart';

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
const _primaryLight = Color(0xFF1565A0);
const _accent = Color(0xFFEEF6FF);
const _green = Color(0xFF34A853);
const _greenLight = Color(0xFFE6F4EA);
const _blue = Color(0xFF4285F4);
const _blueLight = Color(0xFFE8F0FE);
const _red = Color(0xFFEA4335);
const _redLight = Color(0xFFFCE8E6);
const _amber = Color(0xFFFB8C00);
const _amberLight = Color(0xFFFFF3E0);
const _surface = Color(0xFFFFFFFF);
const _bg = Color(0xFFF2F7FC);

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
  AttendanceSummaryResponse? _attendanceSummary;

  bool _isLoadingSchedule = true;
  bool _isLoadingAttendance = true;
  String? _scheduleError;
  String? _attendanceError;

  bool _akanDatangExpanded = false;

  late AnimationController _barAnimController;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _barAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _barAnim = CurvedAnimation(
      parent: _barAnimController,
      curve: Curves.easeOutCubic,
    );
    _fetchAll();
  }

  @override
  void dispose() {
    _barAnimController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    await Future.wait([_fetchSchedule(), _fetchAttendanceSummary()]);
  }

  Future<void> _fetchSchedule() async {
    if (!mounted) return;
    setState(() {
      _isLoadingSchedule = true;
      _scheduleError = null;
    });
    try {
      final result = await _apiService.getSchedule();
      if (!mounted) return;
      setState(() {
        _scheduleResponse = result;
        _isLoadingSchedule = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scheduleError = 'Tidak dapat memuat jadwal';
        _isLoadingSchedule = false;
      });
    }
  }

  Future<void> _fetchAttendanceSummary() async {
    if (!mounted) return;
    setState(() {
      _isLoadingAttendance = true;
      _attendanceError = null;
    });
    try {
      final result = await _apiService.getAttendanceSummary();
      if (!mounted) return;
      // Reset & replay animasi bar setiap data baru masuk
      _barAnimController.forward(from: 0);
      setState(() {
        _attendanceSummary = result;
        _isLoadingAttendance = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _attendanceError = 'Tidak dapat memuat data kehadiran';
        _isLoadingAttendance = false;
      });
    }
  }

  String _capitalizeFirst(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String get _todayLabel => _scheduleResponse != null
      ? _capitalizeFirst(_scheduleResponse!.today)
      : 'Hari Ini';

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
      backgroundColor: Color(0xFFABE4FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchAll,
          color: _primary,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(name: name, initials: initials),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Grafik kehadiran ──
                    _AttendanceChart(
                      animation: _barAnim,
                      isLoading: _isLoadingAttendance,
                      error: _attendanceError,
                      data: _attendanceSummary,
                      onRetry: _fetchAttendanceSummary,
                    ),
                    const SizedBox(height: 24),

                    // ── Jadwal Hari Ini ──
                    _SectionHeader(
                      label: _todayLabel,
                      icon: Icons.today_rounded,
                      isToday: true,
                    ),
                    const SizedBox(height: 10),
                    _buildScheduleSection(
                      items: _scheduleResponse?.todayCourses,
                      isLoading: _isLoadingSchedule,
                      error: _scheduleError,
                      isToday: true,
                    ),
                    const SizedBox(height: 20),

                    // ── Jadwal Besok ──
                    _SectionHeader(
                      label: _tomorrowLabel,
                      icon: Icons.calendar_today_rounded,
                      isToday: false,
                    ),
                    const SizedBox(height: 10),
                    _buildScheduleSection(
                      items: _scheduleResponse?.tomorrowCourses,
                      isLoading: _isLoadingSchedule,
                      error: _scheduleError,
                      isToday: false,
                    ),
                    const SizedBox(height: 20),

                    // // ── Akan Datang ──
                    // _AkanDatangHeader(
                    //   expanded: _akanDatangExpanded,
                    //   onTap: () => setState(
                    //     () => _akanDatangExpanded = !_akanDatangExpanded,
                    //   ),
                    // ),

                    // AnimatedCrossFade(
                    //   duration: const Duration(milliseconds: 250),
                    //   crossFadeState: _akanDatangExpanded
                    //       ? CrossFadeState.showFirst
                    //       : CrossFadeState.showSecond,
                    //   firstChild: Column(
                    //     children: [
                    //       _ScheduleCard(
                    //         name: 'Pemrograman Web',
                    //         room: 'Lab B2',
                    //         startTime: '08:00',
                    //         endTime: '09:40',
                    //         status: null,
                    //         isToday: false,
                    //       ),
                    //       _ScheduleCard(
                    //         name: 'Jaringan Komputer',
                    //         room: 'Lab C1',
                    //         startTime: '10:00',
                    //         endTime: '11:40',
                    //         status: 'selesai',
                    //         isToday: false,
                    //       ),
                    //     ],
                    //   ),
                    //   secondChild: const SizedBox.shrink(),
                    // ),
                    const SizedBox(height: 16),

                    _FullScheduleButton(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KalenderScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
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
    required bool isToday,
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
              isToday: isToday,
            ),
          )
          .toList(),
    );
  }
}

// ════════════════════════════════════════════════════════
// _Header
// ════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final String name;
  final String initials;
  const _Header({required this.name, required this.initials});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat Pagi 🌤';
    if (h < 15) return 'Selamat Siang ☀️';
    if (h < 18) return 'Selamat Sore 🌇';
    return 'Selamat Malam 🌙';
  }

  String _fullDate() {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final n = DateTime.now();
    return '${days[n.weekday - 1]}, ${n.day} ${months[n.month - 1]} ${n.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fullDate(),
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// _AttendanceChart  — sekarang terima data dari API
// ════════════════════════════════════════════════════════
class _AttendanceChart extends StatelessWidget {
  final Animation<double> animation;
  final bool isLoading;
  final String? error;
  final AttendanceSummaryResponse? data;
  final VoidCallback onRetry;

  const _AttendanceChart({
    required this.animation,
    required this.isLoading,
    required this.error,
    required this.data,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isLoading
          ? const _ChartSkeleton()
          : error != null
          ? _ChartError(message: error!, onRetry: onRetry)
          : _ChartContent(animation: animation, data: data!),
    );
  }
}

// ── Skeleton saat loading ────────────────────────────────
class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(width: 140, height: 14),
                  const SizedBox(height: 6),
                  _Shimmer(width: 100, height: 11),
                ],
              ),
              _Shimmer(width: 56, height: 56, radius: 28),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _Shimmer(height: 56, radius: 12)),
              const SizedBox(width: 8),
              Expanded(child: _Shimmer(height: 56, radius: 12)),
              const SizedBox(width: 8),
              Expanded(child: _Shimmer(height: 56, radius: 12)),
            ],
          ),
          const SizedBox(height: 16),
          _Shimmer(width: double.infinity, height: 100, radius: 8),
          const SizedBox(height: 10),
          Center(child: _Shimmer(width: 120, height: 10)),
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const _Shimmer({this.width, required this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error state ──────────────────────────────────────────
class _ChartError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ChartError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              backgroundColor: _accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            ),
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

// ── Konten utama grafik ──────────────────────────────────
class _ChartContent extends StatelessWidget {
  final Animation<double> animation;
  final AttendanceSummaryResponse data;
  const _ChartContent({required this.animation, required this.data});

  @override
  Widget build(BuildContext context) {
    final s = data.summary;
    final pct = s.total == 0 ? 0 : ((s.hadir / s.total) * 100).round();

    final pctColor = pct >= 80
        ? _green
        : pct >= 60
        ? _amber
        : _red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kehadiran Minggu Ini',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${s.hadir} dari ${s.total} sesi kelas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              _MiniDonut(pct: pct, color: pctColor),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Chips ringkasan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _SummaryChip(
                label: 'Hadir',
                value: s.hadir,
                bgColor: _greenLight,
                textColor: const Color(0xFF1B5E20),
                iconColor: _green,
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'Izin',
                value: s.izin,
                bgColor: _blueLight,
                textColor: const Color(0xFF0D47A1),
                iconColor: _blue,
                icon: Icons.info_rounded,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'Alpha',
                value: s.alpha,
                bgColor: _redLight,
                textColor: const Color(0xFFB71C1C),
                iconColor: _red,
                icon: Icons.cancel_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Bar chart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, __) => SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.days
                    .map((d) => _Bar(data: d, animValue: animation.value))
                    .toList(),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Legend
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: _green, label: 'Hadir'),
              SizedBox(width: 16),
              _LegendDot(color: _blue, label: 'Izin'),
              SizedBox(width: 16),
              _LegendDot(color: _red, label: 'Alpha'),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Donut mini ───────────────────────────────────────────
class _MiniDonut extends StatelessWidget {
  final int pct;
  final Color color;
  const _MiniDonut({required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(56, 56),
            painter: _DonutPainter(pct: pct, color: color),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$pct',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: '%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
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

class _DonutPainter extends CustomPainter {
  final int pct;
  final Color color;
  const _DonutPainter({required this.pct, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 4;
    const sw = 5.5;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * (pct / 100),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.pct != pct || old.color != color;
}

// ── Bar chart item ───────────────────────────────────────
String get _todayShort {
  const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  return days[(DateTime.now().weekday - 1) % 7];
}

class _Bar extends StatelessWidget {
  final AttendanceDayData data;
  final double animValue;
  const _Bar({required this.data, required this.animValue});

  @override
  Widget build(BuildContext context) {
    const maxH = 80.0;
    const minH = 6.0;
    final isToday = data.day == _todayShort;

    double frac(int v) => data.total == 0 ? 0 : (v / data.total) * animValue;

    final hadirH = maxH * frac(data.hadir);
    final izinH = maxH * frac(data.izin);
    final alphaH = maxH * frac(data.alpha);
    final totalH = (hadirH + izinH + alphaH).clamp(minH, maxH);
    final isEmpty = data.hadir == 0 && data.izin == 0 && data.alpha == 0;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!isEmpty)
              Text(
                '${data.hadir}/${data.total}',
                style: TextStyle(
                  fontSize: 9,
                  color: isToday ? _primary : Colors.grey.shade400,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: totalH,
                child: isEmpty
                    ? Container(color: Colors.grey.shade100)
                    : Column(
                        children: [
                          if (data.hadir > 0)
                            Flexible(
                              flex: data.hadir,
                              child: Container(
                                color: isToday
                                    ? _green
                                    : _green.withOpacity(0.35),
                              ),
                            ),
                          if (data.izin > 0)
                            Flexible(
                              flex: data.izin,
                              child: Container(
                                color: isToday
                                    ? _blue
                                    : _blue.withOpacity(0.35),
                              ),
                            ),
                          if (data.alpha > 0)
                            Flexible(
                              flex: data.alpha,
                              child: Container(
                                color: isToday ? _red : _red.withOpacity(0.35),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: isToday ? _primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data.day,
                style: TextStyle(
                  fontSize: 10,
                  color: isToday ? Colors.white : Colors.grey.shade500,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// Section / Schedule widgets (tidak berubah dari versi sebelumnya)
// ════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isToday;
  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isToday ? _primary.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: isToday ? _primary : Colors.grey.shade500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isToday ? _primary : Colors.grey.shade600,
            letterSpacing: 0.6,
          ),
        ),
        if (isToday) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
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
  final bool isToday;

  const _ScheduleCard({
    required this.name,
    this.room,
    required this.startTime,
    this.endTime,
    this.status,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final st = _parseStatus(status);
    final cfg = _statusConfig(st);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: cfg.stripColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
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
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (room != null && room!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  room!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: cfg.bgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cfg.icon, size: 11, color: cfg.textColor),
                                const SizedBox(width: 4),
                                Text(
                                  cfg.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: cfg.textColor,
                                  ),
                                ),
                              ],
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
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        if (endTime != null && endTime!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            endTime!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({
    String label,
    Color bgColor,
    Color textColor,
    Color stripColor,
    IconData icon,
  })
  _statusConfig(_AttendanceStatus s) {
    switch (s) {
      case _AttendanceStatus.hadir:
        return (
          label: 'Hadir',
          bgColor: _greenLight,
          textColor: const Color(0xFF1B5E20),
          stripColor: _green,
          icon: Icons.check_circle_rounded,
        );
      case _AttendanceStatus.tidakHadir:
        return (
          label: 'Tidak Hadir',
          bgColor: _redLight,
          textColor: const Color(0xFFB71C1C),
          stripColor: _red,
          icon: Icons.cancel_rounded,
        );
      case _AttendanceStatus.selesai:
        return (
          label: 'Selesai',
          bgColor: const Color(0xFFF0F0F0),
          textColor: const Color(0xFF616161),
          stripColor: Colors.grey.shade300,
          icon: Icons.done_all_rounded,
        );
      case _AttendanceStatus.belumMulai:
        return (
          label: 'Belum Mulai',
          bgColor: _amberLight,
          textColor: const Color(0xFFE65100),
          stripColor: _amber,
          icon: Icons.schedule_rounded,
        );
    }
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: textColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
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
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: _primary),
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
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 28, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            'Tidak ada kelas',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
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
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: _red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: _accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.event_rounded,
                size: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AKAN DATANG',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
                letterSpacing: 0.6,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
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
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.calendar_month_rounded, size: 16),
        label: const Text('Lihat Jadwal Selengkapnya'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: _primary.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: _surface,
          foregroundColor: _primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
