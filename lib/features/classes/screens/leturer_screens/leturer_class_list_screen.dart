// import 'package:attendify_app/features/classes/models/class_schedule.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/class_model.dart';
import '../../services/class_service.dart';
import 'leturer_create_class_screen.dart';
import 'leturer_class_detail_screen.dart';
import '../../../../app/utils/schedule_formatter.dart';

class LecturerClassListScreen extends StatelessWidget {
  const LecturerClassListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lecturerUid = FirebaseAuth.instance.currentUser!.uid;
    final classService = ClassService();

    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách lớp học")),
      body: StreamBuilder<List<ClassModel>>(
        stream: classService.getLecturerClasses(lecturerUid),
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
                  title: Text(
                    c.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Mã lớp: ${c.code}\n${ScheduleFormatter.format(c.schedule)}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LecturerClassDetailScreen(classModel: c),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LecturerCreateClassScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
