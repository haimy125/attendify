import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/attendance_record_model.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> markAttendance({
    required String sessionId,
    required String studentUid,
    required double latitude,
    required double longitude,
    required String deviceId,
  }) async {
    final sessionDoc = await _firestore
        .collection('sessions')
        .doc(sessionId)
        .get();
    if (!sessionDoc.exists) throw Exception("Session not found");

    final data = sessionDoc.data()!;
    final bool isOpen = data['isOpen'] ?? true;
    final String activeToken = data['activeToken'] ?? '';
    final Timestamp expiry = data['tokenExpiry'];
    final GeoPoint lecturerLocation = data['lecturerLocation'];

    if (!isOpen) throw Exception("Buổi học đã kết thúc");
    if (DateTime.now().isAfter(expiry.toDate())) {
      throw Exception("Mã QR đã hết hạn");
    }

    // Lấy deviceId
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final deviceId = androidInfo.id; // hoặc sử dụng identifierForVendor cho iOS

    // Kiểm tra deviceId trong enrollments
    final enrollmentSnap = await _firestore
        .collection('enrollments')
        .where('classId', isEqualTo: data['classId'])
        .where('studentUid', isEqualTo: studentUid)
        .limit(1)
        .get();

    if (enrollmentSnap.docs.isEmpty) {
      throw Exception("Bạn chưa được ghi danh vào lớp này");
    }

    final enrollment = enrollmentSnap.docs.first;
    final registeredDeviceId = enrollment['registeredDeviceId'];

    if (registeredDeviceId == null) {
      // Lần đầu: lưu deviceId
      await enrollment.reference.update({'registeredDeviceId': deviceId});
    } else if (registeredDeviceId != deviceId) {
      throw Exception(
        "Thiết bị không hợp lệ. Vui lòng dùng thiết bị đã đăng ký",
      );
    }

    // Kiểm tra khoảng cách với vị trí GV
    final distance = Geolocator.distanceBetween(
      lecturerLocation.latitude,
      lecturerLocation.longitude,
      latitude,
      longitude,
    );

    if (distance > 50) {
      throw Exception("Bạn không ở trong khu vực lớp học");
    }

    // Lưu attendance record
    await _firestore.collection('attendance_records').add({
      'sessionId': sessionId,
      'studentUid': studentUid,
      'checkinTime': FieldValue.serverTimestamp(),
      'status': 'present',
      'scannedLocation': GeoPoint(latitude, longitude),
      'scannedDeviceId': deviceId,
    });
  }

  // Lấy danh sách điểm danh theo session
  Stream<List<AttendanceRecord>> getAttendanceRecords(String sessionId) {
    return _firestore
        .collection('attendance_records')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('checkinTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceRecord.fromFirestore(doc))
              .toList(),
        );
  }

  // Lấy danh sách điểm danh theo lớp học
  Stream<List<AttendanceRecord>> getClassAttendanceRecords(String classId) {
    return _firestore
        .collection('attendance_records')
        .where('classId', isEqualTo: classId)
        .orderBy('checkinTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceRecord.fromFirestore(doc))
              .toList(),
        );
  }

  // Lấy lịch sử điểm danh theo studentUid
  Stream<List<AttendanceRecord>> getStudentHistory(String studentUid) {
    return _firestore
        .collection('attendance_records')
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('checkinTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceRecord.fromFirestore(doc))
              .toList(),
        );
  }
}
