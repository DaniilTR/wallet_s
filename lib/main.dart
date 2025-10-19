import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/home_screen.dart';

// Главная функция приложения
void main() {
  runApp(const MyApp());
}

// Корневой виджет приложения
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Wallet', // Название приложения
      theme: AppTheme.lightTheme, // Светлая тема
      darkTheme: AppTheme.darkTheme, // Темная тема
      themeMode: ThemeMode.system, // Режим темы следует системным настройкам
      home: const HomeScreen(), // Главный экран
      debugShowCheckedModeBanner: false, // Отключить баннер отладки
    );
  }
}
