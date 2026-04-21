import 'package:flutter/material.dart';
import 'package:igs_absensi/screens/kalender_screen.dart';

// ── Model dummy ──────────────────────────────────────────
enum AttendanceStatus { belumMulai, hadir, tidakHadir, selesai }

class ScheduleItem {
  final String name;
  final String room;
  final String time;
  final AttendanceStatus status;

  const ScheduleItem({
    required this.name,
    required this.room,
    required this.time,
    required this.status,
  });
}

// Model data grafik kehadiran
class AttendanceData {
  final String day;
  final int hadir;
  final int izin;
  final int alfa;
  final int total;

  const AttendanceData({
    required this.day,
    required this.hadir,
    required this.izin,
    required this.alfa,
    required this.total,
  });

  double get percentage => total == 0 ? 0 : hadir / total;
}

// Data dummy grafik — nanti ganti dengan call API
const _weeklyAttendance = [
  AttendanceData(day: 'Sen', hadir: 3, izin: 0, alfa: 0, total: 3),
  AttendanceData(day: 'Sel', hadir: 2, izin: 1, alfa: 0, total: 3),
  AttendanceData(day: 'Rab', hadir: 2, izin: 1, alfa: 1, total: 4),
  AttendanceData(day: 'Kam', hadir: 1, izin: 0, alfa: 1, total: 2),
  AttendanceData(day: 'Jum', hadir: 2, izin: 1, alfa: 0, total: 3),
  AttendanceData(day: 'Sab', hadir: 0, izin: 0, alfa: 1, total: 1),
];

const _today = [
  ScheduleItem(
    name: 'Matematika Diskrit E',
    room: 'Ruang 301',
    time: '09:00',
    status: AttendanceStatus.belumMulai,
  ),
  ScheduleItem(
    name: 'Web Dev A',
    room: 'Lab A1',
    time: '07:00',
    status: AttendanceStatus.tidakHadir,
  ),
  ScheduleItem(
    name: 'Basis Data B',
    room: 'Ruang 204',
    time: '13:00',
    status: AttendanceStatus.hadir,
  ),
];

const _tomorrow = <ScheduleItem>[
  ScheduleItem(
    name: 'Basis Data 1',
    room: 'Ruang 205',
    time: '09:00',
    status: AttendanceStatus.belumMulai,
  ),
];

const _nextWeek = [
  ScheduleItem(
    name: 'Pemrograman Web',
    room: 'Lab B2',
    time: '08:00',
    status: AttendanceStatus.belumMulai,
  ),
  ScheduleItem(
    name: 'Jaringan Komputer',
    room: 'Lab C1',
    time: '10:00',
    status: AttendanceStatus.selesai,
  ),
];

// ── Screen ───────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _nextWeekExpanded = false;
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
  }

  @override
  void dispose() {
    _barAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFABE4FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _buildTopBar(),
            const SizedBox(height: 20),

            // ── Grafik Kehadiran ──
            _AttendanceChart(animation: _barAnim),
            const SizedBox(height: 20),

            _sectionLabel('Hari ini'),
            const SizedBox(height: 10),
            ..._today.map((e) => _ScheduleCard(item: e)),

            const SizedBox(height: 4),
            _sectionLabel('Besok'),
            const SizedBox(height: 10),
            if (_tomorrow.isEmpty)
              _emptyCard()
            else
              ..._tomorrow.map((e) => _ScheduleCard(item: e)),

            const SizedBox(height: 4),
            _buildNextWeekHeader(),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _nextWeekExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: _nextWeek.map((e) => _ScheduleCard(item: e)).toList(),
              ),
              secondChild: const SizedBox.shrink(),
            ),

            const SizedBox(height: 12),
            _buildFullScheduleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat pagi,',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            const Text(
              'Hengki',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFE6F1FB),
          child: const Text(
            'AF',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0C447C),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
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

  Widget _emptyCard() {
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

  Widget _buildNextWeekHeader() {
    return GestureDetector(
      onTap: () => setState(() => _nextWeekExpanded = !_nextWeekExpanded),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('Next Week'),
            AnimatedRotation(
              turns: _nextWeekExpanded ? 0.5 : 0,
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

  Widget _buildFullScheduleButton() {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KalenderScreen()),
        );
      },
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

// ── Widget Grafik Kehadiran ───────────────────────────────
class _AttendanceChart extends StatelessWidget {
  final Animation<double> animation;

  const _AttendanceChart({required this.animation});

  int get _totalHadir => _weeklyAttendance.fold(0, (sum, e) => sum + e.hadir);
  int get _totalIzin => _weeklyAttendance.fold(0, (sum, e) => sum + e.izin);
  int get _totalAlfa => _weeklyAttendance.fold(0, (sum, e) => sum + e.alfa);
  int get _totalKelas => _weeklyAttendance.fold(0, (sum, e) => sum + e.total);

  @override
  Widget build(BuildContext context) {
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
          // ── Header ──
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
                      text: _totalKelas == 0
                          ? '0'
                          : '${((_totalHadir / _totalKelas) * 100).round()}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0C447C),
                      ),
                    ),
                    const TextSpan(
                      text: '%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0C447C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Kartu ringkasan Hadir / Izin / Alfa ──
          Row(
            children: [
              _SummaryChip(
                label: 'Hadir',
                value: _totalHadir,
                bgColor: const Color(0xFFEAF3DE),
                textColor: const Color(0xFF27500A),
                iconColor: const Color(0xFF4CAF82),
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'Izin',
                value: _totalIzin,
                bgColor: const Color(0xFFE8F0FB),
                textColor: const Color(0xFF1A3A6B),
                iconColor: const Color(0xFF4A7BD4),
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'Alfa',
                value: _totalAlfa,
                bgColor: const Color(0xFFFCEBEB),
                textColor: const Color(0xFF791F1F),
                iconColor: const Color(0xFFEF5350),
                icon: Icons.cancel_outlined,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Bar chart ──
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _weeklyAttendance.map((data) {
                    return _buildBar(data, animation.value);
                  }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // ── Legenda ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: const Color(0xFF4CAF82), label: 'Hadir'),
              const SizedBox(width: 14),
              _Legend(color: const Color(0xFF4A7BD4), label: 'Izin'),
              const SizedBox(width: 14),
              _Legend(color: const Color(0xFFEF5350), label: 'Alfa'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(AttendanceData data, double animValue) {
    const maxBarHeight = 72.0;

    // Tinggi masing-masing segmen
    final totalPct = data.total == 0 ? 0.0 : 1.0;
    final hadirH =
        maxBarHeight *
        (data.total == 0 ? 0 : data.hadir / data.total) *
        animValue;
    final izinH =
        maxBarHeight *
        (data.total == 0 ? 0 : data.izin / data.total) *
        animValue;
    final alfaH =
        maxBarHeight *
        (data.total == 0 ? 0 : data.alfa / data.total) *
        animValue;
    final totalH = (hadirH + izinH + alfaH).clamp(4.0, maxBarHeight);

    final isToday = data.day == 'Rab';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Label nilai di atas bar
            Text(
              '${data.hadir}/${data.total}',
              style: TextStyle(
                fontSize: 9,
                color: isToday ? const Color(0xFF0C447C) : Colors.grey.shade400,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 3),

            // Stacked bar: Alfa (bawah) → Izin → Hadir (atas)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: double.infinity,
                height: totalH,
                child: Column(
                  children: [
                    // Hadir (atas)
                    if (hadirH > 0)
                      Flexible(
                        flex: data.hadir,
                        child: Container(
                          color: isToday
                              ? const Color(0xFF4CAF82)
                              : const Color(0xFF4CAF82).withOpacity(0.5),
                        ),
                      ),
                    // Izin (tengah)
                    if (izinH > 0)
                      Flexible(
                        flex: data.izin,
                        child: Container(
                          color: isToday
                              ? const Color(0xFF4A7BD4)
                              : const Color(0xFF4A7BD4).withOpacity(0.5),
                        ),
                      ),
                    // Alfa (bawah)
                    if (alfaH > 0)
                      Flexible(
                        flex: data.alfa,
                        child: Container(
                          color: isToday
                              ? const Color(0xFFEF5350)
                              : const Color(0xFFEF5350).withOpacity(0.5),
                        ),
                      ),
                    // Placeholder agar bar minimal terlihat saat semua 0
                    if (data.hadir == 0 && data.izin == 0 && data.alfa == 0)
                      Expanded(child: Container(color: Colors.grey.shade200)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Label hari
            Text(
              data.day,
              style: TextStyle(
                fontSize: 11,
                color: isToday ? const Color(0xFF0C447C) : Colors.grey.shade500,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chip ringkasan Hadir / Izin / Alfa ───────────────────
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

// ── Legenda bar chart ─────────────────────────────────────
class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

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

// ── Kartu jadwal ─────────────────────────────────────────
class _ScheduleCard extends StatelessWidget {
  final ScheduleItem item;
  const _ScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final status = _statusConfig(item.status);

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
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.room,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: status.bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: status.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.time,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusConfig(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.belumMulai:
        return _StatusStyle(
          label: 'Belum Mulai',
          bgColor: const Color(0xFFFAEEDA),
          textColor: const Color(0xFF633806),
        );
      case AttendanceStatus.hadir:
        return _StatusStyle(
          label: 'Hadir',
          bgColor: const Color(0xFFEAF3DE),
          textColor: const Color(0xFF27500A),
        );
      case AttendanceStatus.tidakHadir:
        return _StatusStyle(
          label: 'Tidak Hadir',
          bgColor: const Color(0xFFFCEBEB),
          textColor: const Color(0xFF791F1F),
        );
      case AttendanceStatus.selesai:
        return _StatusStyle(
          label: 'Selesai',
          bgColor: const Color(0xFFF1EFE8),
          textColor: const Color(0xFF444441),
        );
    }
  }
}

class _StatusStyle {
  final String label;
  final Color bgColor;
  final Color textColor;
  const _StatusStyle({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });
}
