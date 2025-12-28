import 'package:flutter/material.dart';
import 'package:fast_note/services/hive_service.dart';
import 'package:fast_note/screens/home_screen.dart';
import 'package:fast_note/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const FastNoteApp());
}

class FastNoteApp extends StatelessWidget {
  const FastNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fast Note',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
