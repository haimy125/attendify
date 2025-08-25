import 'package:attendify_app/app/config/route_config.dart';
import 'package:attendify_app/app/services/auth_service.dart';
import 'package:attendify_app/features/attendance/screens/lecturer/start_session_screen.dart';
import 'package:attendify_app/features/classes/screens/leturer_screens/leturer_class_list_screen.dart'; // 👈 thêm màn hình quản lý lớp
import 'package:flutter/material.dart';

class LecturerDashboard extends StatelessWidget {
  const LecturerDashboard({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pushReplacementNamed(context, RouteConfig.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Giảng viên'),
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
            title: "Quản lý lớp học",
            subtitle: "Tạo, chỉnh sửa và xem danh sách lớp học",
            icon: Icons.class_,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LecturerClassListScreen(),
                ),
              );
            },
          ),
          _buildCard(
            context,
            title: "Điểm danh",
            subtitle: "Bắt đầu buổi học và hiển thị mã QR",
            icon: Icons.qr_code,
            onTap: () {
              // Ở đây cần truyền classId thực tế (chọn từ ClassList)
              final classId = "CLASS_123";
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StartSessionScreen(classId: classId),
                ),
              );
            },
          ),
          _buildCard(
            context,
            title: "Báo cáo & Thống kê",
            subtitle: "Xem lịch sử điểm danh và báo cáo chuyên cần",
            icon: Icons.bar_chart,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => const ReportScreen()),
              // );
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
