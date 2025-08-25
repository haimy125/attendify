import 'package:flutter/material.dart';

class AttendanceResultScreen extends StatelessWidget {
  final String message;

  const AttendanceResultScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kết quả điểm danh")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                message.contains("thành công")
                    ? Icons.check_circle
                    : Icons.error,
                color: message.contains("thành công")
                    ? Colors.green
                    : Colors.red,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Về Dashboard"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
