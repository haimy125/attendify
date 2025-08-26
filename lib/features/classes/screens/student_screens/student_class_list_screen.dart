import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/student_class_model.dart';
import '../../services/class_service.dart';
import '../../../../app/utils/schedule_formatter.dart';
import 'student_join_class_screen.dart';

class StudentClassListScreen extends StatelessWidget {
  const StudentClassListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentUid = FirebaseAuth.instance.currentUser!.uid;
    final classService = ClassService();

    return Scaffold(
      appBar: AppBar(title: const Text("Lớp học của tôi")),
      body: StreamBuilder<List<StudentClassModel>>(
        stream: classService.getStudentClasses(studentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Bạn chưa tham gia lớp nào."));
          }

          final classes = snapshot.data!;

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final c = classes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(
                    c.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Mã lớp: ${c.code}\n"
                    "${ScheduleFormatter.format(c.schedule)}\n"
                    "Tham gia: ${_formatDate(c.joinedAt)}",
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // TODO: mở màn chi tiết lớp dành cho sinh viên
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentJoinClassScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Tham gia lớp"),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}
