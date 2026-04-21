class StudyProgramModel {
  final int id;
  final String name;
  final int facultyId;

  const StudyProgramModel({
    required this.id,
    required this.name,
    required this.facultyId,
  });

  factory StudyProgramModel.fromJson(Map<String, dynamic> json) =>
      StudyProgramModel(
        id: json['id'],
        name: json['name'],
        facultyId: json['faculty_id'],
      );
}
