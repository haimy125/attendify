import 'class_schedule.dart';

class StudentClassModel {
  final String enrollmentId;
  final String classId;
  final String name;
  final String code;
  final ClassSchedule schedule;
  final DateTime joinedAt;

  StudentClassModel({
    required this.enrollmentId,
    required this.classId,
    required this.name,
    required this.code,
    required this.schedule,
    required this.joinedAt,
  });
}
