class ClassSchedule {
  final List<int> daysOfWeek; // [2,4,6]
  final String startTime; // "07:30"
  final String endTime; // "09:30"
  final DateTime? startDate;
  final DateTime? endDate;

  ClassSchedule({
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    this.startDate,
    this.endDate,
  });

  factory ClassSchedule.fromMap(Map<String, dynamic> map) {
    return ClassSchedule(
      daysOfWeek: List<int>.from(map['daysOfWeek']),
      startTime: map['startTime'],
      endTime: map['endTime'],
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'])
          : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'daysOfWeek': daysOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }
}
