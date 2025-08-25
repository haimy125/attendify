import 'package:attendify_app/features/classes/models/class_schedule.dart';

class ScheduleFormatter {
  static String format(ClassSchedule schedule) {
    final dayNames = {
      1: "T2",
      2: "T3",
      3: "T4",
      4: "T5",
      5: "T6",
      6: "T7",
      7: "CN",
    };

    final days = schedule.daysOfWeek.map((d) => dayNames[d]).join(", ");

    final startDate = schedule.startDate != null
        ? _formatDate(schedule.startDate!)
        : "?";
    final endDate = schedule.endDate != null
        ? _formatDate(schedule.endDate!)
        : "?";

    return "$days - ${schedule.startTime} → ${schedule.endTime}\n"
        "Từ $startDate đến $endDate";
  }

  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}
