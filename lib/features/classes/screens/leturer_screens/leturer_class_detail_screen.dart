import 'package:flutter/material.dart';
import '../../models/class_model.dart';
import '../../models/enrollment_model.dart';
import '../../services/class_service.dart';

class LecturerClassDetailScreen extends StatelessWidget {
  final ClassModel classModel;
  const LecturerClassDetailScreen({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final classService = ClassService();

    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết lớp: ${classModel.name}")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin lớp
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mã lớp: ${classModel.code}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Lịch học: ${classModel.schedule}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(),

          // Danh sách sinh viên đã enroll
          Expanded(
            child: StreamBuilder<List<EnrollmentModel>>(
              stream: classService.getEnrollmentsByClass(classModel.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Chưa có sinh viên tham gia."),
                  );
                }

                final enrollments = snapshot.data!;

                return ListView.builder(
                  itemCount: enrollments.length,
                  itemBuilder: (context, index) {
                    final e = enrollments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text("Sinh viên: ${e.studentUid}"),
                        subtitle: Text(
                          "Ngày tham gia: ${e.joinedAt.toLocal()}",
                        ),
                        onTap: () {
                          // TODO: hiển thị profile sinh viên (nếu có)
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: mở StartSessionScreen để điểm danh cho lớp này
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chức năng tạo buổi học coming soon")),
          );
        },
        icon: const Icon(Icons.qr_code),
        label: const Text("Tạo buổi học"),
      ),
    );
  }
}
