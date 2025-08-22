// Firebase collections
class FirebaseConstants {
  // Collections
  static const String usersCollection = 'users';
  static const String classesCollection = 'classes';
  static const String enrollmentsCollection = 'enrollments';
  static const String sessionsCollection = 'sessions';
  static const String attendanceRecordsCollection = 'attendance_records';

  // User Fields
  static const String userEmail = 'email';
  static const String userFullName = 'fullName';
  static const String userRole = 'role';
  static const String userStudentId = 'studentId';

  // Class Fields
  static const String className = 'className';
  static const String classCode = 'classCode';
  static const String classDescription = 'description';
  static const String classLecturerId = 'lecturerId';

  // Session Fields
  static const String sessionClassId = 'classId';
  static const String sessionCreatedAt = 'createdAt';
  static const String sessionLecturerLocation = 'lecturerLocation';
  static const String sessionActiveToken = 'activeToken';
  static const String sessionTokenExpiry = 'tokenExpiry';
  static const String sessionIsOpen = 'isOpen';

  // Attendance Records Fields
  static const String attendanceSessionId = 'sessionId';
  static const String attendanceStudentUid = 'studentUid';
  static const String attendanceCheckinTime = 'checkinTime';
  static const String attendanceStatus = 'status';
  static const String attendanceScannedLocation = 'scannedLocation';
  static const String attendanceScannedDeviceId = 'scannedDeviceId';

  // Enrollment Fields
  static const String enrollmentClassId = 'classId';
  static const String enrollmentStudentUid = 'studentUid';
  static const String enrollmentRegisteredDeviceId = 'registeredDeviceId';
}
