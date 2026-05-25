import 'package:igs_absensi/model/student.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? pendingEmail;
  final String? emailVerifiedAt;
  final String? address;
  final Student? student;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.pendingEmail,
    this.emailVerifiedAt,
    this.address,
    this.student,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    pendingEmail: json['pending_email'] as String?,
    emailVerifiedAt: json['email_verified_at'] as String?,
    address: json['address'] as String?,
    student: json['student'] != null
        ? Student.fromJson(json['student'] as Map<String, dynamic>)
        : null,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'pending_email': pendingEmail,
    'email_verified_at': emailVerifiedAt,
    'address': address,
    'student': student?.toJson(),
  };
}
