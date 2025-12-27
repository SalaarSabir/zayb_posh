// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'screens/splash/splash_screen.dart';

class ZaybPoshApp extends StatelessWidget {
  const ZaybPoshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        // Add more providers here as needed
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,

        // Use custom theme
        theme: AppTheme.lightTheme,

        // Dark theme (optional - for future)
        // darkTheme: AppTheme.darkTheme,
        // themeMode: ThemeMode.system,

        // Starting screen
        home: const SplashScreen(),
      ),
    );
  }
}