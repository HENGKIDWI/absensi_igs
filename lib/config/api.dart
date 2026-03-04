class ApiConfig {
  static const baseUrl = "http://10.0.2.2:8000";
  // static const baseUrl = "http://192.168.1.16:8000";
}

class ApiEndpoint {
  static const register = "/api/register";
  static const login = "/api/login";
  static const user = "/api/user";
  static const logout = "/api/logout";
  static const verifyEmail = "/api/dashboard";
}
