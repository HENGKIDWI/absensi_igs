import 'package:flutter/material.dart';
import 'package:igs_absensi/model/class.dart';
import 'package:igs_absensi/services/api_service.dart';

// ── Model Meeting dari API ────────────────────────────────
class MeetingModel {
  final int id;
  final String name;
  final String? date;
  final String? status; // null, 'hadir', 'izin', 'alfa'
  final String? loggedAt;

  const MeetingModel({
    required this.id,
    required this.name,
    this.date,
    this.status,
    this.loggedAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) => MeetingModel(
    id: json['id'] as int,
    name: json['name'] as String? ?? '-',
    date: json['date'] as String?,
    status: json['status'] as String?,
    loggedAt: json['logged_at'] as String?,
  );
}

// ── Model response detail kelas ──────────────────────────
class ClassDetailData {
  final ClassModel course;
  final List<MeetingModel> meetings;

  const ClassDetailData({required this.course, required this.meetings});
}

// ════════════════════════════════════════════════════════
// MyClassDetailScreen
// ════════════════════════════════════════════════════════
class MyClassDetailScreen extends StatefulWidget {
  final ClassModel classModel;

  const MyClassDetailScreen({super.key, required this.classModel});

  @override
  State<MyClassDetailScreen> createState() => _MyClassDetailScreenState();
}

class _MyClassDetailScreenState extends State<MyClassDetailScreen> {
  final ApiService _apiService = ApiService();

  ClassDetailData? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail = await _apiService.getClassDetail(widget.classModel.id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat detail kelas';
        _isLoading = false;
      });
    }
  }

  // Hitung ringkasan kehadiran
  int _count(String? status) =>
      _detail?.meetings.where((m) => m.status == status).length ?? 0;

  int get _totalMeetings => _detail?.meetings.length ?? 0;
  int get _hadir => _count('hadir');
  int get _izin => _count('izin');
  int get _alfa => _count('alfa');
  int get _belum => _totalMeetings - _hadir - _izin - _alfa;

  double get _pct => _totalMeetings == 0 ? 0 : (_hadir / _totalMeetings) * 100;

  @override
  Widget build(BuildContext context) {
    final c = widget.classModel;

    return Scaffold(
      backgroundColor: const Color(0xFFABE4FF),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────
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
                      Icons.menu_book_rounded,
                      size: 160,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF0C447C)),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchDetail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C447C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Info kelas ──────────────────────────
                    _InfoCard(classModel: c),
                    const SizedBox(height: 16),

                    // ── Ringkasan kehadiran ─────────────────
                    _AttendanceSummaryCard(
                      total: _totalMeetings,
                      hadir: _hadir,
                      izin: _izin,
                      alfa: _alfa,
                      belum: _belum,
                      pct: _pct,
                    ),
                    const SizedBox(height: 24),

                    // ── Timeline pertemuan ──────────────────
                    const Text(
                      'RIWAYAT PERTEMUAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_detail!.meetings.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Text(
                            'Belum ada pertemuan',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      )
                    else
                      _MeetingTimeline(meetings: _detail!.meetings),

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
          // Badge prodi + semester
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

// ── Ringkasan Kehadiran ───────────────────────────────────
class _AttendanceSummaryCard extends StatelessWidget {
  final int total;
  final int hadir;
  final int izin;
  final int alfa;
  final int belum;
  final double pct;

  const _AttendanceSummaryCard({
    required this.total,
    required this.hadir,
    required this.izin,
    required this.alfa,
    required this.belum,
    required this.pct,
  });

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Kehadiran',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$hadir dari $total pertemuan',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: pct.round().toString(),
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

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  if (hadir > 0)
                    Flexible(
                      flex: hadir,
                      child: Container(color: const Color(0xFF4CAF82)),
                    ),
                  if (izin > 0)
                    Flexible(
                      flex: izin,
                      child: Container(color: const Color(0xFF4A7BD4)),
                    ),
                  if (alfa > 0)
                    Flexible(
                      flex: alfa,
                      child: Container(color: const Color(0xFFEF5350)),
                    ),
                  if (belum > 0)
                    Flexible(
                      flex: belum,
                      child: Container(color: Colors.grey.shade200),
                    ),
                  if (total == 0)
                    Expanded(child: Container(color: Colors.grey.shade200)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Chip ringkasan
          Row(
            children: [
              _SummaryChip(
                label: 'Hadir',
                value: hadir,
                bgColor: const Color(0xFFEAF3DE),
                textColor: const Color(0xFF27500A),
                iconColor: const Color(0xFF4CAF82),
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'Izin',
                value: izin,
                bgColor: const Color(0xFFE8F0FB),
                textColor: const Color(0xFF1A3A6B),
                iconColor: const Color(0xFF4A7BD4),
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'Alfa',
                value: alfa,
                bgColor: const Color(0xFFFCEBEB),
                textColor: const Color(0xFF791F1F),
                iconColor: const Color(0xFFEF5350),
                icon: Icons.cancel_outlined,
              ),
            ],
          ),
        ],
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

// ── Timeline Pertemuan ────────────────────────────────────
class _MeetingTimeline extends StatelessWidget {
  final List<MeetingModel> meetings;
  const _MeetingTimeline({required this.meetings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(meetings.length, (i) {
        return _MeetingRow(
          meeting: meetings[i],
          number: i + 1,
          isLast: i == meetings.length - 1,
        );
      }),
    );
  }
}

class _MeetingRow extends StatelessWidget {
  final MeetingModel meeting;
  final int number;
  final bool isLast;

  const _MeetingRow({
    required this.meeting,
    required this.number,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _statusConfig(meeting.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + garis
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

          // Kartu pertemuan
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
                          'Pertemuan $number',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meeting.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        if (meeting.date != null &&
                            meeting.date!.isNotEmpty) ...[
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
                                meeting.date!,
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
                  // Status pill
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

  _MeetingCfg _statusConfig(String? status) {
    switch (status) {
      case 'hadir':
        return _MeetingCfg(
          dotBg: const Color(0xFFEAF3DE),
          dotBorder: const Color(0xFF4CAF82),
          dotIcon: Icons.check_rounded,
          dotIconColor: const Color(0xFF4CAF82),
          cardBg: Colors.white,
          cardBorder: Colors.grey.shade200,
          pillBg: const Color(0xFFEAF3DE),
          pillText: const Color(0xFF27500A),
          pillLabel: 'Hadir',
        );
      case 'izin':
        return _MeetingCfg(
          dotBg: const Color(0xFFE8F0FB),
          dotBorder: const Color(0xFF4A7BD4),
          dotIcon: Icons.info_outline_rounded,
          dotIconColor: const Color(0xFF4A7BD4),
          cardBg: const Color(0xFFF5F9FF),
          cardBorder: const Color(0xFFB5D4F4),
          pillBg: const Color(0xFFE8F0FB),
          pillText: const Color(0xFF1A3A6B),
          pillLabel: 'Izin',
        );
      case 'alfa':
        return _MeetingCfg(
          dotBg: const Color(0xFFFCEBEB),
          dotBorder: const Color(0xFFEF5350),
          dotIcon: Icons.close_rounded,
          dotIconColor: const Color(0xFFEF5350),
          cardBg: const Color(0xFFFFF8F8),
          cardBorder: const Color(0xFFF5C6C6),
          pillBg: const Color(0xFFFCEBEB),
          pillText: const Color(0xFF791F1F),
          pillLabel: 'Alfa',
        );
      default:
        return _MeetingCfg(
          dotBg: Colors.grey.shade100,
          dotBorder: Colors.grey.shade300,
          dotIcon: Icons.radio_button_unchecked_rounded,
          dotIconColor: Colors.grey.shade400,
          cardBg: Colors.white,
          cardBorder: Colors.grey.shade200,
          pillBg: const Color(0xFFF1EFE8),
          pillText: const Color(0xFF444441),
          pillLabel: 'Belum',
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
