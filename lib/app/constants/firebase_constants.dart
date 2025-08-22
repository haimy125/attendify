class FirebaseConstants {
  // Collection names
  static const String usersCollection = 'users';
  static const String classesCollection = 'classes';
  static const String enrollmentsCollection = 'enrollments';
  static const String sessionsCollection = 'sessions';
  static const String attendanceRecordsCollection = 'attendance_records';

  // User roles
  static const String studentRole = 'student';
  static const String lecturerRole = 'lecturer';

  // Attendance status
  static const String presentStatus = 'present';
  static const String absentStatus = 'absent';
  static const String lateStatus = 'late';

  // Session settings
  static const int defaultMaxDistance = 50; // meters
  static const int tokenExpiryMinutes = 5;
  static const int qrCodeRefreshSeconds = 30;

  // Validation constants
  static const int minPasswordLength = 6;
  static const int minFullNameLength = 2;
  static const int minStudentIdLength = 3;
  static const int maxClassCodeLength = 10;
  static const int maxClassNameLength = 100;
}
