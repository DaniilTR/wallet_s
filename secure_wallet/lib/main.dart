import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Wallet',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthChecker(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthChecker extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    if (_authService.isAuthenticated) {
      return const HomeScreen();
    }
    return const AuthScreen();
  }
}