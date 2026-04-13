import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EventController();

    controller.add(
      CalendarEventData(
        date: DateTime(2026, 4, 10),

        startTime: DateTime(2026, 4, 10),
        endTime: DateTime(2026, 4, 10),

        event: "Meeting",
        title: "Meeting Tim",
        description: "Diskusi project",
      ),
    );

    return CalendarControllerProvider(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(title: const Text("Dashboard")),
        body: MonthView(controller: controller),
      ),
    );
  }
}
