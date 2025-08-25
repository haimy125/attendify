import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/session_model.dart';
import '../../services/session_service.dart';

class QRDisplayScreen extends StatefulWidget {
  final Session session;
  const QRDisplayScreen({super.key, required this.session});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  final SessionService _sessionService = SessionService();
  String _qrData = "";
  Timer? _timer;
  bool _isSessionActive = true;

  @override
  void initState() {
    super.initState();
    _updateQR(widget.session.id, widget.session.currentToken);

    // Cứ 60s thì generate token mới (nếu session còn active)
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_isSessionActive) {
        final newToken = DateTime.now().millisecondsSinceEpoch.toString();
        _sessionService.updateToken(widget.session.id, newToken);
        _updateQR(widget.session.id, newToken);
      }
    });
  }

  void _updateQR(String sessionId, String token) {
    setState(() {
      _qrData = '{"sessionId":"$sessionId","token":"$token"}';
    });
  }

  Future<void> _endSession() async {
    await _sessionService.closeSession(widget.session.id);
    setState(() {
      _isSessionActive = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Buổi điểm danh đã kết thúc")),
      );
      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      ); // quay về Dashboard
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mã QR Điểm danh"),
        actions: [
          if (_isSessionActive)
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.red),
              tooltip: "Kết thúc buổi học",
              onPressed: _endSession,
            ),
        ],
      ),
      body: Center(
        child: _isSessionActive
            ? (_qrData.isEmpty
                  ? const CircularProgressIndicator()
                  : QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 250.0,
                    ))
            : const Text(
                "Buổi điểm danh đã kết thúc",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
