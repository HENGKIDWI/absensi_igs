class SemesterModel {
  final int id;
  final String name;
  final String? year;
  final bool? isActive;

  const SemesterModel({
    required this.id,
    required this.name,
    this.year,
    this.isActive,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '-',
      year: json['year']?.toString(),
      isActive: json['is_active'] as bool?,
    );
  }
}
