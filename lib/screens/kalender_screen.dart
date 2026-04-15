import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  late EventController _controller;

  @override
  void initState() {
    super.initState();

    _controller = EventController();

    _controller.addAll([
      CalendarEventData(
        date: DateTime(2026, 4, 10),
        startTime: DateTime(2026, 4, 10, 8, 0),
        endTime: DateTime(2026, 4, 10, 10, 0),
        title: "Alpro",
      ),
      CalendarEventData(
        date: DateTime(2026, 4, 10),
        startTime: DateTime(2026, 4, 10, 13, 0),
        endTime: DateTime(2026, 4, 10, 15, 0),
        title: "PBO",
      ),
      CalendarEventData(
        date: DateTime(2026, 4, 10),
        startTime: DateTime(2026, 4, 10, 16, 0),
        endTime: DateTime(2026, 4, 10, 18, 0),
        title: "Jarkom",
      ),
      CalendarEventData(
        title: "Struktur data",
        date: DateTime(2026, 4, 10),
        startTime: DateTime(2026, 4, 10, 19, 0),
        endTime: DateTime(2026, 4, 10, 21, 0),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: _controller,
      child: Scaffold(
        appBar: AppBar(title: const Text("Kalender")),
        body: MonthView(controller: _controller),
      ),
    );
  }
}
