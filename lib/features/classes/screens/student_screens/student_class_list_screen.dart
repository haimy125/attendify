import 'package:attendify_app/app/services/auth_service.dart';
import 'package:attendify_app/features/classes/models/class_model.dart';
import 'package:attendify_app/features/classes/services/class_service.dart';
import 'package:flutter/material.dart';
import 'student_class_detail_screen.dart';

class StudentClassListScreen extends StatelessWidget {
  const StudentClassListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classService = ClassService();

    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách lớp học")),
      body: StreamBuilder<List<ClassModel>>(
        stream: classService.getAllClasses(), // Lấy tất cả lớp
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có lớp nào."));
          }

          final classes = snapshot.data!;

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final c = classes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(c.name),
                  subtitle: Text("Mã lớp: ${c.code}"),
                  trailing: ElevatedButton(
                    child: const Text("Tham gia"),
                    onPressed: () async {
                      // Lấy studentUid từ AuthService
                      final studentUid = AuthService().currentUser?.uid;
                      if (studentUid != null) {
                        await classService.joinClass(c.id, studentUid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tham gia lớp thành công!'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bạn cần đăng nhập để tham gia lớp!'),
                          ),
                        );
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentClassDetailScreen(classModel: c),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
