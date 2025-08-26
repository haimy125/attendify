import 'package:attendify_app/app/config/route_config.dart';
import 'package:attendify_app/app/services/auth_service.dart';
import 'package:attendify_app/features/attendance/screens/student/attendance_history_screen.dart';
import 'package:attendify_app/features/attendance/screens/student/qr_scanner_screen.dart';
import 'package:attendify_app/features/classes/screens/student_screens/student_class_list_screen.dart';
import 'package:attendify_app/features/classes/screens/student_screens/student_join_class_screen.dart';
import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});
  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pushReplacementNamed(context, RouteConfig.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Sinh viên"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            context,
            title: "Lớp học của tôi",
            subtitle: "Xem danh sách các lớp đã ghi danh",
            icon: Icons.school,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentClassListScreen(),
                ),
              );
            },
          ),
          _buildCard(
            context,
            title: "Điểm danh bằng QR",
            subtitle: "Mở camera để quét mã QR",
            icon: Icons.qr_code_scanner,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScannerScreen()),
              );
            },
          ),
          _buildCard(
            context,
            title: "Lịch sử điểm danh",
            subtitle: "Xem lại kết quả điểm danh của bạn",
            icon: Icons.history,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AttendanceHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _logout(context);
            },
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }
}
