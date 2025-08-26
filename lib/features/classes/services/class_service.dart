import 'package:attendify_app/features/classes/models/student_class_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';
import '../models/enrollment_model.dart';

class ClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createClass(ClassModel classModel) async {
    await _firestore.collection('classes').add(classModel.toMap());
  }

  Future<void> enrollStudent(String classCode, String studentUid) async {
    // Tìm lớp theo code
    final query = await _firestore
        .collection('classes')
        .where('code', isEqualTo: classCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception("Không tìm thấy lớp với mã $classCode");
    }

    final classDoc = query.docs.first;

    // Kiểm tra SV đã tham gia chưa
    final existing = await _firestore
        .collection('enrollments')
        .where('classId', isEqualTo: classDoc.id)
        .where('studentUid', isEqualTo: studentUid)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception("Bạn đã tham gia lớp này rồi");
    }

    // Thêm enrollment
    await _firestore.collection('enrollments').add({
      'classId': classDoc.id,
      'studentUid': studentUid,
      'joinedAt': FieldValue.serverTimestamp(),
      'registeredDeviceId': null,
    });
  }

  Stream<List<ClassModel>> getLecturerClasses(String lecturerUid) {
    return _firestore
        .collection('classes')
        .where('lecturerUid', isEqualTo: lecturerUid)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => ClassModel.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<EnrollmentModel>> getStudentEnrollments(String studentUid) {
    return _firestore
        .collection('enrollments')
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => EnrollmentModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<EnrollmentModel>> getEnrollmentsByClass(String classId) {
    return _firestore
        .collection('enrollments')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => EnrollmentModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Lấy tất cả các lớp học
  Stream<List<ClassModel>> getAllClasses() {
    return _firestore.collection('classes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> joinClass(String classId, String studentUid) async {
    await _firestore.collection('classes').doc(classId).update({
      'students': FieldValue.arrayUnion([studentUid]),
    });
  }

  /// Lấy danh sách lớp mà sinh viên đã tham gia (hợp nhất từ enrollments + classes)
  Stream<List<StudentClassModel>> getStudentClasses(String studentUid) {
    return _firestore
        .collection('enrollments')
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .asyncMap((snapshot) async {
          List<StudentClassModel> result = [];

          for (var doc in snapshot.docs) {
            final enrollment = EnrollmentModel.fromFirestore(doc);

            // lấy class tương ứng
            final classDoc = await _firestore
                .collection('classes')
                .doc(enrollment.classId)
                .get();

            if (classDoc.exists) {
              final classData = ClassModel.fromFirestore(classDoc);

              result.add(
                StudentClassModel(
                  enrollmentId: enrollment.id,
                  classId: classData.id,
                  name: classData.name,
                  code: classData.code,
                  schedule: classData.schedule,
                  joinedAt: enrollment.joinedAt,
                ),
              );
            }
          }

          return result;
        });
  }
}
