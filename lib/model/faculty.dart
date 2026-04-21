// lib/models/faculty_model.dart
class FacultyModel {
  final int id;
  final String name;

  const FacultyModel({required this.id, required this.name});

  factory FacultyModel.fromJson(Map<String, dynamic> json) =>
      FacultyModel(id: json['id'], name: json['name']);
}
