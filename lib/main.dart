import 'package:fast_note/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:fast_note/services/hive_service.dart';
import 'package:fast_note/screens/home_screen.dart';
import 'package:fast_note/providers/theme_provider.dart';
import 'package:fast_note/providers/settings_provider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const FastNoteApp(),
    ),
  );
}

class FastNoteApp extends StatelessWidget {
  const FastNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Also listen to SettingsProvider for full screen mode changes
        return Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return MaterialApp(
              title: 'Fast Note',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.materialThemeMode,
              debugShowCheckedModeBanner: false,
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}