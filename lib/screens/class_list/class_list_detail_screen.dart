import 'package:flutter/material.dart';
import 'package:igs_absensi/model/class.dart';
import 'package:igs_absensi/services/api_service.dart';

// ── Custom exception untuk enroll ────────────────────────
class EnrollException implements Exception {
  final String message;
  final int statusCode;
  const EnrollException({required this.message, required this.statusCode});
}

// ── Dummy model pertemuan ─────────────────────────────────
class MeetingItem {
  final int number;
  final String date;
  final String topic;
  final MeetingStatus status;

  const MeetingItem({
    required this.number,
    required this.date,
    required this.topic,
    required this.status,
  });
}

enum MeetingStatus { selesai, berlangsung, belumMulai }

final _dummyMeetings = [
  MeetingItem(
    number: 1,
    date: '3 Feb 2025',
    topic: 'Pengenalan Mata Kuliah',
    status: MeetingStatus.selesai,
  ),
  MeetingItem(
    number: 2,
    date: '10 Feb 2025',
    topic: 'Dasar-dasar Teori',
    status: MeetingStatus.selesai,
  ),
  MeetingItem(
    number: 3,
    date: '17 Feb 2025',
    topic: 'Studi Kasus I',
    status: MeetingStatus.selesai,
  ),
  MeetingItem(
    number: 4,
    date: '24 Feb 2025',
    topic: 'Diskusi & Latihan',
    status: MeetingStatus.berlangsung,
  ),
  MeetingItem(
    number: 5,
    date: '3 Mar 2025',
    topic: 'Studi Kasus II',
    status: MeetingStatus.belumMulai,
  ),
  MeetingItem(
    number: 6,
    date: '10 Mar 2025',
    topic: 'Presentasi Kelompok',
    status: MeetingStatus.belumMulai,
  ),
  MeetingItem(
    number: 7,
    date: '17 Mar 2025',
    topic: 'Ujian Tengah Semester',
    status: MeetingStatus.belumMulai,
  ),
  MeetingItem(
    number: 8,
    date: '',
    topic: 'Materi Lanjutan',
    status: MeetingStatus.belumMulai,
  ),
  MeetingItem(
    number: 9,
    date: '',
    topic: 'Materi Lanjutan',
    status: MeetingStatus.belumMulai,
  ),
  MeetingItem(
    number: 10,
    date: '',
    topic: 'Materi Lanjutan',
    status: MeetingStatus.belumMulai,
  ),
  MeetingItem(
    number: 11,
    date: '',
    topic: 'Materi Lanjutan',
    status: MeetingStatus.belumMulai,
  ),
  MeetingItem(
    number: 12,
    date: '',
    topic: 'Materi Lanjutan',
    status: MeetingStatus.belumMulai,
  ),
  MeetingItem(
    number: 13,
    date: '',
    topic: 'Materi Lanjutan',
    status: MeetingStatus.belumMulai,
  ),
  MeetingItem(
    number: 14,
    date: '',
    topic: 'Materi Lanjutan',
    status: MeetingStatus.belumMulai,
  ),
  MeetingItem(
    number: 15,
    date: '',
    topic: 'Review Materi',
    status: MeetingStatus.belumMulai,
  ),
  MeetingItem(
    number: 16,
    date: '',
    topic: 'Ujian Akhir Semester',
    status: MeetingStatus.belumMulai,
  ),
];

// ── Screen ───────────────────────────────────────────────
class ClassDetailScreen extends StatefulWidget {
  final ClassModel classModel;

  const ClassDetailScreen({super.key, required this.classModel});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isEnrolled = false;
  bool _isEnrolling = false;

  Future<void> _handleEnroll() async {
    setState(() => _isEnrolling = true);

    try {
      final message = await _apiService.enrollCourse(widget.classModel.id);

      if (!mounted) return;
      setState(() {
        _isEnrolled = true;
        _isEnrolling = false;
      });

      _showSnackbar(message, isError: false);

      Navigator.pop(context, true);
    } on EnrollException catch (e) {
      if (!mounted) return;
      setState(() => _isEnrolling = false);

      if (e.statusCode == 409 && e.message.contains('sudah terdaftar')) {
        setState(() => _isEnrolled = true);
      }

      _showSnackbar(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isEnrolling = false);
      _showSnackbar('Tidak dapat terhubung ke server', isError: true);
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFEF5350)
            : const Color(0xFF4CAF82),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.classModel;

    return Scaffold(
      backgroundColor: const Color(0xFFABE4FF),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF0C447C),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: Text(
                c.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0C447C), Color(0xFF185FA5)],
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Opacity(
                    opacity: 0.08,
                    child: Icon(
                      Icons.school_rounded,
                      size: 160,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoCard(classModel: c),
                  const SizedBox(height: 16),

                  _EnrollButton(
                    isEnrolled: _isEnrolled,
                    isEnrolling: _isEnrolling,
                    onTap: (_isEnrolled || _isEnrolling) ? null : _handleEnroll,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'JADWAL PERTEMUAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MeetingTimeline(meetings: _dummyMeetings),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final ClassModel classModel;
  const _InfoCard({required this.classModel});

  @override
  Widget build(BuildContext context) {
    final c = classModel;

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
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (c.studyProgram != null)
                _Pill(
                  label: c.studyProgram!,
                  bgColor: const Color(0xFFE1F5EE),
                  textColor: const Color(0xFF085041),
                ),
              if (c.semester != null)
                _Pill(
                  label: c.semester!,
                  bgColor: const Color(0xFFFAEEDA),
                  textColor: const Color(0xFF633806),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Dosen',
            value: c.lecturerName ?? '-',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.room_outlined,
            label: 'Ruangan',
            value: c.room ?? '-',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.access_time_outlined,
            label: 'Waktu',
            value: (c.startTime != null && c.endTime != null)
                ? '${c.startTime} – ${c.endTime}'
                : '-',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
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
    );
  }
}

// ── Enroll Button ─────────────────────────────────────────
class _EnrollButton extends StatelessWidget {
  final bool isEnrolled;
  final bool isEnrolling;
  final VoidCallback? onTap;

  const _EnrollButton({
    required this.isEnrolled,
    required this.isEnrolling,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isEnrolled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3DE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: Color(0xFF4CAF82),
            ),
            SizedBox(width: 8),
            Text(
              'Sudah Terdaftar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF27500A),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnrolling ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C447C),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF0C447C).withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isEnrolling
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Daftar ke Kelas Ini',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

// ── Meeting Timeline ──────────────────────────────────────
class _MeetingTimeline extends StatelessWidget {
  final List<MeetingItem> meetings;
  const _MeetingTimeline({required this.meetings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(meetings.length, (i) {
        return _MeetingRow(
          meeting: meetings[i],
          isLast: i == meetings.length - 1,
        );
      }),
    );
  }
}

class _MeetingRow extends StatelessWidget {
  final MeetingItem meeting;
  final bool isLast;

  const _MeetingRow({required this.meeting, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final cfg = _statusConfig(meeting.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: cfg.dotBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: cfg.dotBorder, width: 1.5),
                  ),
                  child: Icon(cfg.dotIcon, size: 14, color: cfg.dotIconColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cfg.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cfg.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pertemuan ${meeting.number}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meeting.topic,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        if (meeting.date.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 11,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                meeting.date,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cfg.pillBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cfg.pillLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: cfg.pillText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _MeetingCfg _statusConfig(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.selesai:
        return _MeetingCfg(
          dotBg: const Color(0xFFEAF3DE),
          dotBorder: const Color(0xFF4CAF82),
          dotIcon: Icons.check_rounded,
          dotIconColor: const Color(0xFF4CAF82),
          cardBg: Colors.white,
          cardBorder: Colors.grey.shade200,
          pillBg: const Color(0xFFEAF3DE),
          pillText: const Color(0xFF27500A),
          pillLabel: 'Selesai',
        );
      case MeetingStatus.berlangsung:
        return _MeetingCfg(
          dotBg: const Color(0xFFE8F0FB),
          dotBorder: const Color(0xFF4A7BD4),
          dotIcon: Icons.radio_button_on_rounded,
          dotIconColor: const Color(0xFF4A7BD4),
          cardBg: const Color(0xFFF5F9FF),
          cardBorder: const Color(0xFFB5D4F4),
          pillBg: const Color(0xFFE8F0FB),
          pillText: const Color(0xFF1A3A6B),
          pillLabel: 'Berlangsung',
        );
      case MeetingStatus.belumMulai:
        return _MeetingCfg(
          dotBg: Colors.grey.shade100,
          dotBorder: Colors.grey.shade300,
          dotIcon: Icons.radio_button_unchecked_rounded,
          dotIconColor: Colors.grey.shade400,
          cardBg: Colors.white,
          cardBorder: Colors.grey.shade200,
          pillBg: const Color(0xFFF1EFE8),
          pillText: const Color(0xFF444441),
          pillLabel: 'Belum Mulai',
        );
    }
  }
}

class _MeetingCfg {
  final Color dotBg, dotBorder, dotIconColor;
  final IconData dotIcon;
  final Color cardBg, cardBorder;
  final Color pillBg, pillText;
  final String pillLabel;

  const _MeetingCfg({
    required this.dotBg,
    required this.dotBorder,
    required this.dotIcon,
    required this.dotIconColor,
    required this.cardBg,
    required this.cardBorder,
    required this.pillBg,
    required this.pillText,
    required this.pillLabel,
  });
}

// ── Pill badge ────────────────────────────────────────────
class _Pill extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Pill({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: textColor)),
    );
  }
}
