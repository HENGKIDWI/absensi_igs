class CourseSchedule {
  final int id;
  final String name;
  final String day;
  final String startTime;
  final String endTime;
  final String status;

  CourseSchedule({
    required this.id,
    required this.name,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory CourseSchedule.fromJson(Map<String, dynamic> json) {
    return CourseSchedule(
      id: json['id'],
      name: json['name'] ?? '',
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
