import 'package:igs_absensi/model/lecturer.dart';
import 'package:igs_absensi/model/semester.dart';
import 'package:igs_absensi/model/study_program.dart';

class ScheduleModel {
  final int id;
  final String name;
  final String? room;
  final String startTime;
  final String? endTime;
  final String day;
  final String? status; // null = belumMulai, hadir, tidak_hadir, selesai
  final LecturerModel? lecturer;
  final StudyProgramModel? studyProgram;
  final SemesterModel? semester;

  const ScheduleModel({
    required this.id,
    required this.name,
    this.room,
    required this.startTime,
    this.endTime,
    required this.day,
    this.status,
    this.lecturer,
    this.studyProgram,
    this.semester,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '-',
      room: json['room'] as String?,
      startTime: json['start_time'] as String? ?? '00:00',
      endTime: json['end_time'] as String?,
      day: json['day'] as String? ?? '',
      status: json['status'] as String?,
      lecturer: json['lecturer'] != null
          ? LecturerModel.fromJson(json['lecturer'] as Map<String, dynamic>)
          : null,
      studyProgram: json['study_program'] != null
          ? StudyProgramModel.fromJson(
              json['study_program'] as Map<String, dynamic>,
            )
          : null,
      semester: json['semester'] != null
          ? SemesterModel.fromJson(json['semester'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Format "07:00:00" → "07:00"
  String get formattedStartTime {
    if (startTime.length >= 5) return startTime.substring(0, 5);
    return startTime;
  }

  String? get formattedEndTime {
    if (endTime != null && endTime!.length >= 5)
      return endTime!.substring(0, 5);
    return endTime;
  }
}
