import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:igs_absensi/config/api.dart';
import 'package:igs_absensi/model/user_model.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.login);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(decoded['message'] ?? 'Login gagal');
    }

    final token = decoded['token'];
    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

    return {'token': token};
  }

  Future<User> getUser(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.baseUrl + ApiEndpoint.user),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal ambil user");
    }

    return User.fromJson(jsonDecode(response.body));
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final url = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.register);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    print("REGISTER STATUS: ${response.statusCode}");
    print("REGISTER BODY: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(decoded['message'] ?? 'Register gagal');
    }
  }

  Future<bool> verifiEmail(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.baseUrl + ApiEndpoint.verifyEmail),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true; // sudah verified
    } else if (response.statusCode == 403) {
      return false; // belum verified
    } else {
      throw Exception('Gagal cek verifikasi');
    }
  }
}
