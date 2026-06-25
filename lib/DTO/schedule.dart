import 'package:igs_absensi/model/schedule.dart';

class ScheduleResponse {
  final List<CourseSchedule> todayCourses;
  final List<CourseSchedule> tomorrowCourses;
  final String today;
  final String tomorrow;

  ScheduleResponse({
    required this.todayCourses,
    required this.tomorrowCourses,
    required this.today,
    required this.tomorrow,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      todayCourses: (json['todayCourses'] as List)
          .map((e) => CourseSchedule.fromJson(e))
          .toList(),

      tomorrowCourses: (json['tomorrowCourses'] as List)
          .map((e) => CourseSchedule.fromJson(e))
          .toList(),

      today: json['today'] ?? '',
      tomorrow: json['tomorrow'] ?? '',
    );
  }
}
