// Điều hướng tới màn hình của GV/SV
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String role; // 'lecturer' hoặc 'student'
  const HomeScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          role == 'lecturer' ? 'Dashboard Giảng viên' : 'Dashboard Sinh viên',
        ),
        centerTitle: true,
      ),
      body: role == 'lecturer'
          ? _buildLecturerDashboard()
          : _buildStudentDashboard(),
    );
  }

  Widget _buildLecturerDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton(
          onPressed: () {
            // TODO: Điều hướng tới màn hình quản lý lớp học
          },
          child: const Text("Quản lý Lớp học"),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Điều hướng tới màn hình tạo phiên điểm danh
          },
          child: const Text("Bắt đầu điểm danh"),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Điều hướng tới màn hình báo cáo
          },
          child: const Text("Báo cáo & Thống kê"),
        ),
      ],
    );
  }

  Widget _buildStudentDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton(
          onPressed: () {
            // TODO: Điều hướng tới màn hình danh sách lớp đã ghi danh
          },
          child: const Text("Lớp học của tôi"),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Điều hướng tới màn hình quét QR
          },
          child: const Text("Điểm danh bằng QR"),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Điều hướng tới màn hình lịch sử điểm danh
          },
          child: const Text("Lịch sử điểm danh"),
        ),
      ],
    );
  }
}
