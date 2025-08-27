import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/class_service.dart';

class StudentJoinClassScreen extends StatefulWidget {
  const StudentJoinClassScreen({super.key});

  @override
  State<StudentJoinClassScreen> createState() => _StudentJoinClassScreenState();
}

class _StudentJoinClassScreenState extends State<StudentJoinClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _loading = false;

  final _classService = ClassService();

  Future<void> _joinClass() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final studentUid = FirebaseAuth.instance.currentUser!.uid;
      await _classService.enrollStudent(
        _codeController.text.trim(),
        studentUid,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Tham gia lớp thành công")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) {
        // Thêm kiểm tra mounted
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tham gia lớp")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: "Mã lớp"),
                validator: (v) => v == null || v.isEmpty ? "Nhập mã lớp" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _joinClass,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Tham gia lớp"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
