import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:igs_absensi/config/api.dart';
import 'package:igs_absensi/config/auth_storage.dart';
import 'package:igs_absensi/model/user_model.dart';

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

    // Return token dari response register
    return {'token': decoded['token']};
  }

  // verifikasi email
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
    final url = Uri.parse(ApiConfig.baseUrl + ApiEndpoint.resendOtp);

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
      throw Exception(data['message']);
    }
  }
}
