class ApiConfig {
  // Emulator Android
  // static const baseUrl = "http://10.0.2.2:8000";

  // Real device / local network
  static const baseUrl = "http://192.168.1.17:8000";
}

class ApiEndpoint {
  // Auth
  static const register = "/api/register";
  static const login = "/api/login";
  static const user = "/api/user";
  static const logout = "/api/logout";

  // Email & OTP
  static const verifyEmail = "/api/email/verify-otp";
  static const resendOtp = "/api/email/resend-otp";
  static const sendOtp = "/api/reset-password";
  static const checkOtp = "/api/otp-check";
  static const resetPassword = "/api/new-password";

  // Search
  static const search = "/api/search";

  // Academic
  static const faculty = "/api/faculties";
  static const studyPrograms = "/api/study-program";

  // Student
  static const schedule = "/api/student/schedule";
  static const allClasses = "/api/student/all-classes";
  static const enrolledClasses = "/api/student/classes";
  static const profile = "/api/student/profile";
  static const attendanceSummary = "/api/student/attendance-summary";

  // Dynamic endpoint helper
  static String classDetail(int id) => "/api/student/classes/$id";

  static String scanQr(String token) => "/api/student/scan/$token";

  static String enroll(int id) => "/api/student/all-classes/$id/enroll";
}
