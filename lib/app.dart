// lib/app.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'screens/splash/splash_screen.dart';

class ZaybPoshApp extends StatelessWidget {
  const ZaybPoshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // Use custom theme
      theme: AppTheme.lightTheme,

      // Dark theme (optional - for future)
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,

      // Starting screen
      home: const SplashScreen(),
    );
  }
}