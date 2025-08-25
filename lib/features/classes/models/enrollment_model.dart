import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  final String id;
  final String classId;
  final String studentUid;
  final DateTime joinedAt;
  final String? registeredDeviceId;

  EnrollmentModel({
    required this.id,
    required this.classId,
    required this.studentUid,
    required this.joinedAt,
    this.registeredDeviceId,
  });

  factory EnrollmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EnrollmentModel(
      id: doc.id,
      classId: data['classId'],
      studentUid: data['studentUid'],
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      registeredDeviceId: data['registeredDeviceId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'studentUid': studentUid,
      'joinedAt': joinedAt,
      'registeredDeviceId': registeredDeviceId,
    };
  }
}
