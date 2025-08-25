import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../services/attendance_service.dart';
import 'attendance_result_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AttendanceService _attendanceService = AttendanceService();
  bool _isProcessing = false;

  Future<void> _handleScan(String qrData) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // Decode dữ liệu QR: {"sessionId":"...", "token":"..."}
      final payload = jsonDecode(qrData);
      final sessionId = payload['sessionId'];
      final studentUid = _auth.currentUser!.uid;

      // Lấy vị trí GPS
      final position = await _determinePosition();

      // Lấy deviceId
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = "unknown";
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "unknown_ios";
      }

      // Gọi service để markAttendance
      await _attendanceService.markAttendance(
        sessionId: sessionId,
        studentUid: studentUid,
        latitude: position.latitude,
        longitude: position.longitude,
        deviceId: deviceId,
      );

      _showResult("Điểm danh thành công!");
    } catch (e) {
      _showResult("Không thể điểm danh: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("GPS chưa được bật");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Bạn cần cấp quyền vị trí");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Quyền vị trí bị từ chối vĩnh viễn");
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showResult(String message) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceResultScreen(message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quét QR điểm danh")),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          final String? code = barcodeCapture.barcodes.first.rawValue;
          if (code != null) {
            _handleScan(code);
          }
        },
      ),
    );
  }
}
