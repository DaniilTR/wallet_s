import 'package:flutter/material.dart';
import 'package:secure_wallet/screens/auth_screen.dart';
import 'package:secure_wallet/screens/home_screen.dart';
import 'package:secure_wallet/services/auth_service.dart';

/// Виджет, который проверяет статус аутентификации пользователя.
///
/// В зависимости от того, аутентифицирован ли пользователь,
/// он показывает либо [HomeScreen], либо [AuthScreen].
class AuthChecker extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    // Проверяем, аутентифицирован ли пользователь.
    // В реальном приложении это может быть проверка токена,
    // сессии или другого состояния.
    if (_authService.isAuthenticated) {
      // Если да, показываем главный экран.
      return const HomeScreen();
    }
    // Если нет, показываем экран аутентификации.
    return const AuthScreen();
  }
}
