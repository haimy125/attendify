import 'package:attendify_app/features/classes/models/class_schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String name;
  final String code;
  final ClassSchedule schedule;
  final String lecturerUid;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.name,
    required this.code,
    required this.schedule,
    required this.lecturerUid,
    required this.createdAt,
  });

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassModel(
      id: doc.id,
      name: data['name'],
      code: data['code'],
      schedule: ClassSchedule.fromMap(
        data['schedule'],
      ), // Chuyển lại thành object
      lecturerUid: data['lecturerUid'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'schedule': schedule.toMap(), // Chuyển thành Map
      'lecturerUid': lecturerUid,
      'createdAt': Timestamp.fromDate(createdAt), // Đảm bảo kiểu Timestamp
    };
  }
}
