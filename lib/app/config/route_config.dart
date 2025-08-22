import 'package:flutter/material.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/dashboard/screens/lecturer_dashboard.dart';
import '../../features/dashboard/screens/student_dashboard.dart';

class RouteConfig {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String lecturerDashboard = '/lecturer-dashboard';
  static const String studentDashboard = '/student-dashboard';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const LoginScreen(), // Temporary
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    lecturerDashboard: (context) => const LecturerDashboard(),
    studentDashboard: (context) => const StudentDashboard(),
  };
}
