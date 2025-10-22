import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'widgets/auth_checker.dart'; // Импортируем наш новый виджет

/// Главная функция приложения.
void main() {
  // Запускает приложение, передавая корневой виджет [MyApp].
  runApp(const MyApp());
}

/// [MyApp] — это виджет без состояния (StatelessWidget), который настраивает тему и начальный экран
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
