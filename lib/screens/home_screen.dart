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

// Data dummy — nanti ganti dengan call API
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

class _HomeScreenState extends State<HomeScreen> {
  bool _nextWeekExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 171, 228, 255),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _buildTopBar(),
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

  // Top bar: greeting + avatar
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

  // Label section (TODAY, TOMORROW, dll)
  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.black,
        letterSpacing: 0.8,
      ),
    );
  }

  // Card kosong
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

  // Header Next Week dengan chevron
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

  // Tombol lihat jadwal selengkapnya
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
          // Kiri: nama, ruangan, status
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
          // Kanan: jam
          Text(
            item.time,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Mapping status → warna
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
