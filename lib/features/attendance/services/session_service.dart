import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tạo buổi học mới
  Future<Session> createSession(String classId) async {
    final docRef = _firestore.collection('sessions').doc();
    final token = DateTime.now().millisecondsSinceEpoch.toString();

    final session = Session(
      id: docRef.id,
      classId: classId,
      currentToken: token,
      createdAt: DateTime.now(),
      isActive: true,
    );

    await docRef.set(session.toMap());

    return session;
  }

  // Cập nhật token (QR động)
  Future<void> updateToken(String sessionId, String newToken) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'currentToken': newToken,
    });
  }

  // Kết thúc buổi học
  Future<void> closeSession(String sessionId) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'isActive': false,
    });
  }

  // Lấy session theo ID
  Future<Session?> getSession(String sessionId) async {
    final doc = await _firestore.collection('sessions').doc(sessionId).get();
    if (!doc.exists) return null;
    return Session.fromFirestore(doc);
  }
}
