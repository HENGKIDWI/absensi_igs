class LecturerModel {
  final int id;
  final String? userId;
  final LecturerUserModel? user;

  const LecturerModel({required this.id, this.userId, this.user});

  factory LecturerModel.fromJson(Map<String, dynamic> json) {
    return LecturerModel(
      id: json['id'] as int,
      userId: json['user_id']?.toString(),
      user: json['user'] != null
          ? LecturerUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Nama dosen — ambil dari relasi user jika ada
  String get name => user?.name ?? '-';
}

class LecturerUserModel {
  final int id;
  final String name;
  final String? email;

  const LecturerUserModel({required this.id, required this.name, this.email});

  factory LecturerUserModel.fromJson(Map<String, dynamic> json) {
    return LecturerUserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '-',
      email: json['email'] as String?,
    );
  }
}
