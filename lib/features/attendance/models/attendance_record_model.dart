import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentUid;
  final DateTime checkinTime;
  final String status; // present | late | absent

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentUid,
    required this.checkinTime,
    required this.status,
  });

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      studentUid: data['studentUid'] ?? '',
      checkinTime:
          (data['checkinTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'present',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'studentUid': studentUid,
      'checkinTime': Timestamp.fromDate(checkinTime),
      'status': status,
    };
  }
}
