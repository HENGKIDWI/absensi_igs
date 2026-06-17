// lib/DTO/attendance_summary.dart

class AttendanceDayData {
  final String day;
  final int hadir;
  final int izin;
  final int alpha;
  final int total;

  const AttendanceDayData({
    required this.day,
    required this.hadir,
    required this.izin,
    required this.alpha,
    required this.total,
  });

  factory AttendanceDayData.fromJson(Map<String, dynamic> json) {
    return AttendanceDayData(
      day: json['day'] as String,
      hadir: json['hadir'] as int,
      izin: json['izin'] as int,
      alpha: json['alpha'] as int,
      total: json['total'] as int,
    );
  }
}

class AttendanceSummary {
  final int hadir;
  final int izin;
  final int alpha;
  final int total;

  const AttendanceSummary({
    required this.hadir,
    required this.izin,
    required this.alpha,
    required this.total,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      hadir: json['hadir'] as int,
      izin: json['izin'] as int,
      alpha: json['alpha'] as int,
      total: json['total'] as int,
    );
  }
}

class AttendanceSummaryResponse {
  final String weekStart;
  final String weekEnd;
  final AttendanceSummary summary;
  final List<AttendanceDayData> days;

  const AttendanceSummaryResponse({
    required this.weekStart,
    required this.weekEnd,
    required this.summary,
    required this.days,
  });

  factory AttendanceSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryResponse(
      weekStart: json['week_start'] as String,
      weekEnd: json['week_end'] as String,
      summary: AttendanceSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      days: (json['days'] as List<dynamic>)
          .map((e) => AttendanceDayData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
