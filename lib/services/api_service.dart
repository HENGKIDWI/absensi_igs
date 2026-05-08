import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:igs_absensi/DTO/schedule.dart';
import 'package:igs_absensi/config/api.dart';
import 'package:igs_absensi/config/auth_storage.dart';
import 'package:igs_absensi/model/class.dart';
import 'package:igs_absensi/model/faculty.dart';
import 'package:igs_absensi/model/schedule.dart';
import 'package:igs_absensi/DTO/search.dart';
import 'package:igs_absensi/model/study_program.dart';
import 'package:igs_absensi/model/user.dart';
import 'package:igs_absensi/screens/class_list/class_list_detail_screen.dart';
import 'package:igs_absensi/screens/my_class/my_class_detail_screen.dart';

class ApiService {
  // login
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiEndpoint.login),
      body: {"email": email, "password": password},
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'];

      if (token != null) {
        await AuthStorage.saveToken(token);

        // ✅ Langsung fetch & simpan data user
        final user = await getUser(token);
        await AuthStorage.saveUser(jsonEncode(user.toJson()));
        return true;
      }
    }
    return false;
  }

  // get user
  Future<User> getUser(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.baseUrl + ApiEndpoint.user),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    final data = jsonDecode(response.body);
    return User.fromJson(data);
  }

  // register
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String confirmPassword,
    int facultyId, // ← tambah
    int studyProgramId, // ← tambah
  ) async {
    final uri = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.register);

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
        'faculty_id': facultyId, // ← tambah
        'study_program_id': studyProgramId, // ← tambah
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }
    throw Exception(data['message'] ?? 'Gagal registrasi');
  }

  // verifikasi email
  Future<Map<String, dynamic>> verifyEmail(String email, String otp) async {
    final url = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.verifyEmail);

    final token = await AuthStorage.getToken();

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'token': data['token'], 'user': User.fromJson(data['user'])};
    } else {
      throw Exception(data['message']);
    }
  }

  // resend verifikasi email
  Future<String> resendOtp(String email) async {
    final token = await AuthStorage.getToken();

    final url = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.resendOtp);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'];
    } else {
      throw Exception(data['message']);
    }
  }

  // validate token (untuk auto-login)
  Future<User?> validateToken() async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) return null;

      final response = await http
          .get(
            Uri.parse(ApiConfig.baseUrl + ApiEndpoint.user),
            headers: {
              "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);

        // ignore: unnecessary_cast
        await AuthStorage.saveUser(jsonEncode(data) as String);
        return user;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> sendOtp(String email) async {
    final url = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.sendOtp);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'];
    } else {
      throw Exception(data['message'] ?? 'Gagal mengirim OTP');
    }
  }

  // 2. Verifikasi OTP
  Future<String> checkOtp(String otp) async {
    final url = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.checkOtp);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'otp': otp}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['reset-token']; // ambil token reset password
    } else {
      throw Exception(data['message'] ?? 'OTP tidak valid');
    }
  }

  // 3. Reset Password
  Future<String> resetPassword(
    String resetToken,
    String password,
    String passwordConfirmation,
  ) async {
    final url = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.resetPassword);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'];
    } else {
      throw Exception(data['message'] ?? 'Gagal reset password');
    }
  }

  Future<void> logout() async {
    final token = await AuthStorage.getToken();

    await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiEndpoint.logout),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    // hapus token & user dari storage
    await AuthStorage.clear();
  }

  Future<SearchResult> searchCourses(String query, {String? cursor}) async {
    final token = await AuthStorage.getToken();

    final uri = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.search).replace(
      queryParameters: {
        if (query.isNotEmpty) 'q': query,
        if (cursor != null) 'cursor': cursor,
      },
    );

    // ── Debug: lihat URL & token ──
    debugPrint('=== SEARCH REQUEST ===');
    debugPrint('URL   : $uri');
    debugPrint('Token : $token');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    // ── Debug: lihat response ──
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body  : ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return SearchResult.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Gagal mengambil data');
    }
  }

  Future<List<FacultyModel>> getFaculties() async {
    final uri = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.faculty);
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body  : ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['faculties'] as List)
          .map((e) => FacultyModel.fromJson(e))
          .toList();
    }
    throw Exception('Gagal mengambil data fakultas');
  }

  Future<List<StudyProgramModel>> getStudyPrograms(int facultyId) async {
    final uri = Uri.parse(
      ApiConfig.baseUrl + ApiEndpoint.studyPrograms,
    ).replace(queryParameters: {'faculty_id': '$facultyId'});

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['study_programs'] as List)
          .map((e) => StudyProgramModel.fromJson(e))
          .toList();
    }
    throw Exception('Gagal mengambil data program studi');
  }

  Future<ScheduleResponse> getSchedule() async {
    final token = await AuthStorage.getToken();

    final uri = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.schedule);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ScheduleResponse.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Gagal mengambil jadwal');
    }
  }

  Future<String> enrollCourse(int courseId) async {
    try {
      final token = await AuthStorage.getToken();
      print('ENROLL TOKEN: $token');

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiEndpoint.enroll}/$courseId/enroll',
      );
      print('ENROLL URL: $uri');

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('ENROLL STATUS: ${response.statusCode}');
      print('ENROLL BODY: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final message = data['message'] as String? ?? 'Terjadi kesalahan';

      if (response.statusCode == 200 || response.statusCode == 201) {
        return message;
      }

      throw EnrollException(message: message, statusCode: response.statusCode);
    } catch (e) {
      print('ENROLL ERROR: $e');
      rethrow;
    }
  }

  // GET /api/student/classes → daftar kelas yang diikuti student saat ini
  Future<List<ClassModel>> getEnrolledClasses() async {
    final token = await AuthStorage.getToken();

    final uri = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.enrolledClasses);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(data['message'] ?? 'Gagal mengambil kelas');
  }

  // GET /api/student/classes/{course_id} → detail kelas (termasuk daftar pertemuan)
  Future<ClassDetailData> getClassDetail(int courseId) async {
    final token = await AuthStorage.getToken();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoint.classDetail}/$courseId',
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final data = body['data'] as Map<String, dynamic>;

      final courseJson = data['course'] as Map<String, dynamic>;
      final meetingsJson = data['meetings'] as List<dynamic>? ?? [];

      final course = ClassModel(
        id: courseJson['id'] as int,
        name: courseJson['name'] as String? ?? '-',
        room: _resolveRoom(courseJson),
        startTime: _formatTime(courseJson['start_time'] as String?),
        endTime: _formatTime(courseJson['end_time'] as String?),
        studyProgram:
            (courseJson['study_program'] as Map<String, dynamic>?)?['name']
                as String?,
        semester:
            (courseJson['semester'] as Map<String, dynamic>?)?['name']
                as String?,
        lecturerName:
            ((courseJson['lecturer'] as Map<String, dynamic>?)?['user']
                    as Map<String, dynamic>?)?['name']
                as String?,
      );

      final meetings = meetingsJson
          .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ClassDetailData(course: course, meetings: meetings);
    }

    throw Exception(body['message'] ?? 'Gagal mengambil detail kelas');
  }

  String? _resolveRoom(Map<String, dynamic> json) {
    final classroom = json['classroom'] as Map<String, dynamic>?;
    if (classroom == null) return json['room'] as String?;

    final locationName =
        (classroom['location'] as Map<String, dynamic>?)?['name'] as String?;
    final roomName = classroom['name'] as String?;

    final parts = [
      if (locationName != null && locationName.isNotEmpty) locationName,
      if (roomName != null && roomName.isNotEmpty) roomName,
    ];

    return parts.isNotEmpty ? parts.join(' - ') : json['room'] as String?;
  }

  /// Helper: "07:00:00" → "07:00"
  String? _formatTime(String? raw) {
    if (raw == null) return null;
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }
}
