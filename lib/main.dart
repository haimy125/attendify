import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/config/app_config.dart';
import 'app/config/route_config.dart';
import 'app/config/theme_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const AttendifyApp());
}

class AttendifyApp extends StatelessWidget {
  const AttendifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      initialRoute: RouteConfig.splash,
      routes: RouteConfig.routes,
    );
  }
}
