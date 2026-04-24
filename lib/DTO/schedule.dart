import 'package:igs_absensi/model/schedule.dart';

class ScheduleResponse {
  final List<ScheduleModel> todayCourses;
  final List<ScheduleModel> tomorrowCourses;
  final String today;
  final String tomorrow;

  const ScheduleResponse({
    required this.todayCourses,
    required this.tomorrowCourses,
    required this.today,
    required this.tomorrow,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      todayCourses: (json['todayCourses'] as List<dynamic>? ?? [])
          .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      tomorrowCourses: (json['tomorrowCourses'] as List<dynamic>? ?? [])
          .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      today: json['today'] as String? ?? '',
      tomorrow: json['tomorrow'] as String? ?? '',
    );
  }
}
