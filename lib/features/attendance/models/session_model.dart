import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id;
  final String classId;
  final String currentToken;
  final DateTime createdAt;
  final bool isActive;

  Session({
    required this.id,
    required this.classId,
    required this.currentToken,
    required this.createdAt,
    required this.isActive,
  });

  factory Session.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Session(
      id: doc.id,
      classId: data['classId'] ?? '',
      currentToken: data['currentToken'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'currentToken': currentToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}
