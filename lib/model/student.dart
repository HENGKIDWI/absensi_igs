class Student {
  final int id;
  final String nim;
  final String? gender;
  final String? dateOfBirth;

  const Student({
    required this.id,
    required this.nim,
    this.gender,
    this.dateOfBirth,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] as int,
    nim: json['nim'] as String,
    gender: json['gender'] as String?,
    dateOfBirth: json['date_of_birth'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'nim': nim,
    'gender': gender,
    'date_of_birth': dateOfBirth,
  };
}
