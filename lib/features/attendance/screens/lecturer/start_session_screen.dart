import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../lecturer/qr_display_screen.dart';

class StartSessionScreen extends StatefulWidget {
  final String classId;
  const StartSessionScreen({super.key, required this.classId});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  final SessionService _sessionService = SessionService();
  bool _isLoading = false;

  Future<void> _startSession() async {
    setState(() => _isLoading = true);

    final session = await _sessionService.createSession(widget.classId);

    setState(() => _isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QRDisplayScreen(session: session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bắt đầu điểm danh")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text("Bắt đầu buổi điểm danh"),
                onPressed: _startSession,
              ),
      ),
    );
  }
}
