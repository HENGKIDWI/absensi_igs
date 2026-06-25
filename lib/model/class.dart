// lib/model/class_model.dart

class ClassModel {
  final int id;
  final String name;
  final String? room;
  final String? startTime;
  final String? endTime;
  final String? studyProgram;
  final String? semester;
  final String? lecturerName;
  final int? sks;

  const ClassModel({
    required this.id,
    required this.name,
    this.room,
    this.startTime,
    this.endTime,
    this.studyProgram,
    this.semester,
    this.lecturerName,
    this.sks,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
    id: json['id'],
    name: json['name'],
    room: json['room'],
    startTime: json['start_time'],
    endTime: json['end_time'],
    studyProgram: json['study_program'],
    semester: json['semester'],
    lecturerName: json['lecturer_name'],
    sks: json['sks'],
  );
}
