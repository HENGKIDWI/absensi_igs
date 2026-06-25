import 'package:flutter/material.dart';
import 'package:igs_absensi/model/schedule.dart';
import 'package:igs_absensi/services/api_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final ApiService _service = ApiService();

  bool isLoading = false;

  List<CourseSchedule> todayCourses = [];
  List<CourseSchedule> tomorrowCourses = [];

  Future<void> loadSchedule() async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await _service.getSchedule();

      print("Today: ${result.todayCourses.length}");
      print("Tomorrow: ${result.tomorrowCourses.length}");

      todayCourses = result.todayCourses;
      tomorrowCourses = result.tomorrowCourses;
    } catch (e, s) {
      print(e);
      print(s);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
