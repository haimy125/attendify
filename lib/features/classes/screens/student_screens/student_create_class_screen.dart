import 'package:attendify_app/features/classes/models/class_schedule.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/class_service.dart';
import '../../models/class_model.dart';

class StudentCreateClassScreen extends StatefulWidget {
  const StudentCreateClassScreen({super.key});

  @override
  State<StudentCreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<StudentCreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  List<int> _selectedDays = []; // lưu thứ trong tuần
  bool _loading = false;

  final _classService = ClassService();

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDate: now,
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split("T").first;
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  Future<void> _createClass() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn ít nhất 1 ngày trong tuần"),
        ),
      );
      return;
    }

    final startDate = DateTime.tryParse(_startDateController.text);
    final endDate = DateTime.tryParse(_endDateController.text);

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ngày bắt đầu/kết thúc không hợp lệ")),
      );
      return;
    }
    if (startDate.isAfter(endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ngày bắt đầu phải trước ngày kết thúc")),
      );
      return;
    }

    // check giờ
    if (_startTimeController.text.isEmpty || _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng chọn giờ học")));
      return;
    }

    setState(() => _loading = true);

    try {
      final lecturerUid = FirebaseAuth.instance.currentUser!.uid;

      // check mã lớp tồn tại
      final existing = await FirebaseFirestore.instance
          .collection('classes')
          .where('code', isEqualTo: _codeController.text.trim())
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        throw Exception("Mã lớp đã tồn tại, vui lòng chọn mã khác");
      }

      final schedule = ClassSchedule(
        daysOfWeek: _selectedDays,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        startDate: startDate,
        endDate: endDate,
      );

      final newClass = ClassModel(
        id: "",
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        schedule: schedule,
        lecturerUid: lecturerUid,
        createdAt: DateTime.now(),
      );

      await _classService.createClass(newClass);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Tạo lớp thành công")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const weekdayNames = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    const weekdayValues = [1, 2, 3, 4, 5, 6, 7];

    return Scaffold(
      appBar: AppBar(title: const Text("Tạo lớp học")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Tên lớp"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Nhập tên lớp" : null,
              ),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: "Mã lớp"),
                validator: (v) => v == null || v.isEmpty ? "Nhập mã lớp" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                        labelText: "Ngày bắt đầu",
                      ),
                      readOnly: true,
                      onTap: () => _pickDate(_startDateController),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Chọn ngày bắt đầu" : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      decoration: const InputDecoration(
                        labelText: "Ngày kết thúc",
                      ),
                      readOnly: true,
                      onTap: () => _pickDate(_endDateController),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Chọn ngày kết thúc" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: List.generate(weekdayNames.length, (i) {
                    return FilterChip(
                      label: Text(weekdayNames[i]),
                      selected: _selectedDays.contains(weekdayValues[i]),
                      onSelected: (sel) {
                        setState(() {
                          if (sel) {
                            _selectedDays.add(weekdayValues[i]);
                          } else {
                            _selectedDays.remove(weekdayValues[i]);
                          }
                        });
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      decoration: const InputDecoration(
                        labelText: "Giờ bắt đầu",
                      ),
                      readOnly: true,
                      onTap: () => _pickTime(_startTimeController),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Chọn giờ bắt đầu" : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      decoration: const InputDecoration(
                        labelText: "Giờ kết thúc",
                      ),
                      readOnly: true,
                      onTap: () => _pickTime(_endTimeController),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Chọn giờ kết thúc" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _createClass,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Tạo lớp"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
