import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase_constants.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream để lắng nghe trạng thái authentication
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  /// Đăng ký tài khoản mới
  Future<User?> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? studentId,
  }) async {
    try {
      // Validate input
      _validateRegistrationInput(email, password, fullName, role, studentId);

      // Kiểm tra studentId đã tồn tại chưa (nếu là sinh viên)
      if (role == 'student' && studentId != null) {
        await _checkStudentIdExists(studentId);
      }

      // Tạo tài khoản Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Tạo document user trong Firestore
      await _createUserDocument(
        uid: uid,
        email: email,
        fullName: fullName,
        role: role,
        studentId: studentId,
      );

      // Cập nhật displayName cho Firebase Auth
      await userCredential.user!.updateDisplayName(fullName);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e));
    } on Exception catch (e) {
      throw AuthException(e.toString());
    } catch (e) {
      throw AuthException("Có lỗi không xác định xảy ra: $e");
    }
  }

  /// Đăng nhập
  Future<User?> login(String email, String password) async {
    try {
      // Validate input
      if (email.trim().isEmpty || password.isEmpty) {
        throw AuthException("Email và mật khẩu không được để trống");
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Kiểm tra trạng thái tài khoản trong Firestore
      await _checkUserStatus(uid);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException("Có lỗi không xác định xảy ra: $e");
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException("Lỗi khi đăng xuất: $e");
    }
  }

  /// Quên mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw AuthException("Vui lòng nhập email");
      }

      if (!_isValidEmail(email.trim())) {
        throw AuthException("Email không hợp lệ");
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException("Có lỗi xảy ra khi gửi email reset: $e");
    }
  }

  /// Đổi mật khẩu
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException("Vui lòng đăng nhập để thực hiện chức năng này");
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException("Có lỗi xảy ra khi đổi mật khẩu: $e");
    }
  }

  /// Lấy thông tin user từ Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _db
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        throw AuthException("Không tìm thấy thông tin người dùng");
      }

      return doc.data();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException("Lỗi khi lấy thông tin người dùng: $e");
    }
  }

  /// Lấy role của user
  Future<String> getUserRole(String uid) async {
    try {
      final userData = await getUserData(uid);
      final role = userData?['role'] as String?;

      if (role == null) {
        throw AuthException("Không xác định được vai trò người dùng");
      }

      return role;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException("Lỗi khi lấy vai trò người dùng: $e");
    }
  }

  /// Cập nhật thông tin user
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _db
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update(data);
    } catch (e) {
      throw AuthException("Lỗi khi cập nhật thông tin: $e");
    }
  }

  /// Lấy danh sách sinh viên (dành cho giảng viên)
  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final querySnapshot = await _db
          .collection(FirebaseConstants.usersCollection)
          .where('role', isEqualTo: 'student')
          .where('isActive', isEqualTo: true)
          .orderBy('fullName')
          .get();

      return querySnapshot.docs.map((doc) => {
        'uid': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw AuthException("Lỗi khi lấy danh sách sinh viên: $e");
    }
  }

  /// Lấy danh sách giảng viên
  Future<List<Map<String, dynamic>>> getLecturers() async {
    try {
      final querySnapshot = await _db
          .collection(FirebaseConstants.usersCollection)
          .where('role', isEqualTo: 'lecturer')
          .where('isActive', isEqualTo: true)
          .orderBy('fullName')
          .get();

      return querySnapshot.docs.map((doc) => {
        'uid': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw AuthException("Lỗi khi lấy danh sách giảng viên: $e");
    }
  }

  /// Tìm kiếm user theo email hoặc studentId
  Future<Map<String, dynamic>?> findUserByEmailOrStudentId(String query) async {
    try {
      // Tìm theo email trước
      var querySnapshot = await _db
          .collection(FirebaseConstants.usersCollection)
          .where('email', isEqualTo: query.trim().toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {
          'uid': doc.id,
          ...doc.data(),
        };
      }

      // Nếu không tìm thấy, tìm theo studentId
      querySnapshot = await _db
          .collection(FirebaseConstants.usersCollection)
          .where('studentId', isEqualTo: query.trim())
          .where('role', isEqualTo: 'student')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {
          'uid': doc.id,
          ...doc.data(),
        };
      }

      return null;
    } catch (e) {
      throw AuthException("Lỗi khi tìm kiếm người dùng: $e");
    }
  }

  // PRIVATE METHODS

  void _validateRegistrationInput(
    String email,
    String password,
    String fullName,
    String role,
    String? studentId,
  ) {
    if (email.trim().isEmpty) {
      throw AuthException("Email không được để trống");
    }

    if (!_isValidEmail(email.trim())) {
      throw AuthException("Email không hợp lệ");
    }

    if (password.length < 6) {
      throw AuthException("Mật khẩu phải có ít nhất 6 ký tự");
    }

    if (fullName.trim().isEmpty || fullName.trim().length < 2) {
      throw AuthException("Họ tên phải có ít nhất 2 ký tự");
    }

    if (!['student', 'lecturer'].contains(role)) {
      throw AuthException("Vai trò không hợp lệ");
    }

    if (role == 'student' && (studentId == null || studentId.trim().isEmpty)) {
      throw AuthException("Mã sinh viên không được để trống");
    }

    if (role == 'student' && studentId != null && studentId.trim().length < 3) {
      throw AuthException("Mã sinh viên phải có ít nhất 3 ký tự");
    }
  }

  Future<void> _checkStudentIdExists(String studentId) async {
    final querySnapshot = await _db
        .collection(FirebaseConstants.usersCollection)
        .where('studentId', isEqualTo: studentId.trim())
        .where('role', isEqualTo: 'student')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw AuthException("Mã sinh viên đã tồn tại");
    }
  }

  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String fullName,
    required String role,
    String? studentId,
  }) async {
    final userData = {
      "uid": uid,
      "email": email.trim().toLowerCase(),
      "fullName": fullName.trim(),
      "role": role,
      "isActive": true,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    };

    if (studentId != null && studentId.trim().isNotEmpty) {
      userData["studentId"] = studentId.trim().toUpperCase();
    }

    await _db
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .set(userData);
  }

  Future<void> _checkUserStatus(String uid) async {
    try {
      final userData = await getUserData(uid);
      final isActive = userData?['isActive'] ?? true;

      if (!isActive) {
        await logout();
        throw AuthException(
          "Tài khoản đã bị khóa, vui lòng liên hệ quản trị viên",
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      // If we can't check status, allow login but log warning
      print("Warning: Could not check user status: $e");
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "Email không hợp lệ";
      case 'user-disabled':
        return "Tài khoản này đã bị vô hiệu hóa";
      case 'user-not-found':
        return "Không tìm thấy tài khoản với email này";
      case 'wrong-password':
        return "Mật khẩu không đúng";
      case 'email-already-in-use':
        return "Email này đã được sử dụng cho tài khoản khác";
      case 'weak-password':
        return "Mật khẩu quá yếu, vui lòng chọn mật khẩu mạnh hơn";
      case 'too-many-requests':
        return "Quá nhiều lần thử, vui lòng thử lại sau";
      case 'network-request-failed':
        return "Lỗi kết nối mạng, vui lòng kiểm tra internet";
      case 'invalid-credential':
        return "Thông tin đăng nhập không hợp lệ";
      case 'requires-recent-login':
        return "Vui lòng đăng nhập lại để thực hiện thao tác này";
      default:
        return e.message ?? "Có lỗi xảy ra, vui lòng thử lại";
    }
  }
}

/// Custom Exception class cho Auth
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}