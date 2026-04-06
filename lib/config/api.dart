class ApiConfig {
  static const baseUrl = "http://10.0.2.2:8000";
  // static const baseUrl = "http://172.16.13.160:8000";
}

class ApiEndpoint {
  static const register = "/api/register";
  static const login = "/api/login";
  static const user = "/api/user";
  static const logout = "/api/logout";
  static const verifyEmail = "/api/email/verify-otp";
  static const resendOtp = "/api/email/resend-otp";
  static const sendOtp = "/api/reset-password";
  static const checkOtp = "/api/otp-check";
  static const resetPassword = "/api/new-password";
}
