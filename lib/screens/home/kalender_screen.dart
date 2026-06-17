import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:igs_absensi/config/api.dart';
import 'package:igs_absensi/config/auth_storage.dart';

// ── Warna tema (sama dengan HomeScreen) ─────────────────
const _primary = Color(0xFF0C447C);
const _primaryLight = Color(0xFF1565A0);
const _surface = Color(0xFFFFFFFF);
const _bg = Color(0xFFF2F7FC);
const _accent = Color(0xFFEEF6FF);

// Palet warna per mata kuliah (otomatis di-assign berdasarkan index)
const _courseColors = [
  Color(0xFF4285F4),
  Color(0xFF34A853),
  Color(0xFFEA4335),
  Color(0xFFFB8C00),
  Color(0xFF9C27B0),
  Color(0xFF00BCD4),
  Color(0xFFFF5722),
  Color(0xFF607D8B),
];

// ── Model lokal untuk data kelas ─────────────────────────
class _CourseItem {
  final int id;
  final String name;
  final String day; // nama hari dalam bahasa Indonesia
  final String? room;
  final String startTime; // "HH:mm:ss" atau "HH:mm"
  final String endTime;

  const _CourseItem({
    required this.id,
    required this.name,
    required this.day,
    this.room,
    required this.startTime,
    required this.endTime,
  });

  factory _CourseItem.fromJson(Map<String, dynamic> json) {
    return _CourseItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      day: (json['day'] as String? ?? '').toLowerCase(),
      room: json['room'] as String?,
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
    );
  }
  String get formattedStart => startTime.substring(0, 5);
  String get formattedEnd => endTime.substring(0, 5);
}

// Mapping nama hari (id) → weekday (1=Mon ... 7=Sun)
const _dayToWeekday = {
  'senin': 1,
  'selasa': 2,
  'rabu': 3,
  'kamis': 4,
  'jumat': 5,
  'jum\'at': 5,
  'sabtu': 6,
  'minggu': 7,
};

// ════════════════════════════════════════════════════════
// KalenderScreen
// ════════════════════════════════════════════════════════
class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  List<_CourseItem> _courses = [];
  bool _isLoading = true;
  String? _error;

  // Bulan yang sedang ditampilkan
  late DateTime _focusedMonth;
  // Hari yang dipilih
  DateTime? _selectedDay;

  // Cache warna per course id
  final Map<int, Color> _colorCache = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await AuthStorage.getToken();
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiEndpoint.enrolledClasses}',
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw Exception(body['message'] ?? 'Gagal memuat kelas');
      }

      final rawList = body['data'] as List<dynamic>? ?? [];
      final list = rawList
          .map((e) => _CourseItem.fromJson(e as Map<String, dynamic>))
          .where((c) => c.day.isNotEmpty && c.startTime.isNotEmpty)
          .toList();

      for (var i = 0; i < list.length; i++) {
        _colorCache[list[i].id] = _courseColors[i % _courseColors.length];
      }

      if (!mounted) return;
      setState(() {
        _courses = list;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('ERROR FETCH COURSES: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Kembalikan semua tanggal di bulan [month] yang jatuh pada hari [weekday]
  List<DateTime> _datesForWeekday(int year, int month, int weekday) {
    final dates = <DateTime>[];
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      if (date.weekday == weekday) dates.add(date);
    }
    return dates;
  }

  // Map: tanggal → list kelas di hari itu
  Map<DateTime, List<_CourseItem>> get _eventMap {
    final map = <DateTime, List<_CourseItem>>{};
    for (final course in _courses) {
      final wd = _dayToWeekday[course.day];
      if (wd == null) continue;
      for (final date in _datesForWeekday(
        _focusedMonth.year,
        _focusedMonth.month,
        wd,
      )) {
        map.putIfAbsent(date, () => []).add(course);
      }
    }
    return map;
  }

  List<_CourseItem> _eventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventMap[key] ?? [];
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  void _prevMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    _selectedDay = null;
  });

  void _nextMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    _selectedDay = null;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Kalender Jadwal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _error != null
          ? _buildError()
          : Column(
              children: [
                _buildCalendar(),
                const SizedBox(height: 4),
                Expanded(child: _buildEventList()),
              ],
            ),
    );
  }

  // ── Error ────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _fetchCourses,
            style: TextButton.styleFrom(
              backgroundColor: _accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Coba lagi', style: TextStyle(color: _primary)),
          ),
        ],
      ),
    );
  }

  // ── Kalender ─────────────────────────────────────────
  Widget _buildCalendar() {
    final eventMap = _eventMap;

    const dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
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

    // Hari pertama bulan ini (weekday 1=Sen)
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    // Offset: berapa sel kosong sebelum hari 1 (Senin=0 offset)
    final offset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final totalCells = offset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          // ── Navigator bulan ──
          Row(
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: const Icon(Icons.chevron_left_rounded, color: _primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Text(
                  '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right_rounded, color: _primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Label hari ──
          Row(
            children: dayLabels
                .map(
                  (l) => Expanded(
                    child: Text(
                      l,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: l == 'Min'
                            ? Colors.red.shade300
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),

          // ── Grid hari ──
          ...List.generate(rows, (row) {
            return Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNum = cellIndex - offset + 1;

                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 52));
                }

                final date = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month,
                  dayNum,
                );
                final events = eventMap[date] ?? [];
                final isSelected =
                    _selectedDay != null && _isSameDay(date, _selectedDay!);
                final isToday = _isToday(date);
                final isSunday = date.weekday == 7;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = date),
                    child: Container(
                      height: 52,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primary
                            : isToday
                            ? _accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Angka tanggal
                          Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isToday || isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                  ? _primary
                                  : isSunday
                                  ? Colors.red.shade300
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Dot indikator event (maks 3)
                          if (events.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: events
                                  .take(3)
                                  .map(
                                    (e) => Container(
                                      width: 5,
                                      height: 5,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white70
                                            : _colorCache[e.id] ?? _primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  // ── Daftar event hari yang dipilih ───────────────────
  Widget _buildEventList() {
    if (_selectedDay == null) {
      return _buildHint('Pilih tanggal untuk melihat jadwal');
    }

    final events = _eventsForDay(_selectedDay!);
    final isToday = _isToday(_selectedDay!);

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    const daysFull = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    final label =
        '${daysFull[_selectedDay!.weekday - 1]}, ${_selectedDay!.day} '
        '${months[_selectedDay!.month - 1]} ${_selectedDay!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header tanggal terpilih
        Container(
          color: _surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Hari ini',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // List kelas atau empty state
        Expanded(
          child: events.isEmpty
              ? _buildHint('Tidak ada kelas di hari ini')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _EventTile(
                    course: events[i],
                    color: _colorCache[events[i].id] ?? _primary,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHint(String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 32,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// _EventTile
// ════════════════════════════════════════════════════════
class _EventTile extends StatelessWidget {
  final _CourseItem course;
  final Color color;
  const _EventTile({required this.course, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            // Strip warna
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
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
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Ikon warna
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.book_rounded, size: 18, color: color),
                    ),
                    const SizedBox(width: 12),
                    // Info kelas
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (course.room != null &&
                              course.room!.isNotEmpty) ...[
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
                                  course.room!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Waktu
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          course.formattedStart,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          course.formattedEnd,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
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
}
