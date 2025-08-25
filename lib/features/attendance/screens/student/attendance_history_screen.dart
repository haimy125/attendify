import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/attendance_record_model.dart';
import '../../services/attendance_service.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final attendanceService = AttendanceService();

    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử điểm danh")),
      body: StreamBuilder<List<AttendanceRecord>>(
        stream: attendanceService.getStudentHistory(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có lịch sử điểm danh"));
          }

          final records = snapshot.data!;

          return ListView.separated(
            itemCount: records.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final r = records[index];
              return ListTile(
                leading: Icon(
                  Icons.qr_code_2,
                  color: r.status == "present" ? Colors.green : Colors.red,
                ),
                title: Text("Session: ${r.sessionId}"),
                subtitle: Text(
                  "Trạng thái: ${r.status}\n"
                  "Thời gian: ${r.checkinTime}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
