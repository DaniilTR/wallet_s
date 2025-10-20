import 'package:flutter/material.dart';

// Класс для определения темы приложения
class AppTheme {
  // Основные цвета приложения
  static const Color primary = Color(0xFF0098EA); // Основной цвет
  static const Color secondary = Color(0xFF31A24C); // Вторичный цвет
  static const Color warning = Color(0xFFFFA500); // Цвет предупреждения
  static const Color danger = Color(0xFFE74C3C); // Цвет опасности
  static const Color success = Color(0xFF27AE60); // Цвет успеха

  // Светлая тема
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // Используем Material 3
      brightness: Brightness.light, // Яркость светлая
      primaryColor: primary, // Основной цвет
      scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Цвет фона
      // Тема для AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F7FA), // Цвет фона AppBar
        elevation: 0, // Без тени
        centerTitle: true, // Заголовок по центру
        // Стиль текста заголовка
        titleTextStyle: TextStyle(
          color: Color(0xFF1F2937), // Цвет текста
          fontSize: 18, // Размер шрифта
          fontWeight: FontWeight.w600, // Жирность шрифта
        ),
      ),
      // Тема для Card
      cardTheme: CardThemeData(
        color: Colors.white, // Цвет карточки
        elevation: 0, // Без тени
        // Форма карточки
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Скругление углов
          // Граница
          side: const BorderSide(
            color: Color(0xFFE5E7EB), // Цвет границы
            width: 1, // Ширина границы
          ),
        ),
      ),
      // Тема для ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // Цвет фона кнопки
          foregroundColor: Colors.white, // Цвет текста кнопки
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Отступы
          // Форма кнопки
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Скругление углов
          ),
          elevation: 0, // Без тени
        ),
      ),
      // Тема для OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: primary, width: 1.5), // Граница кнопки
          foregroundColor: primary, // Цвет текста кнопки
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Отступы
          // Форма кнопки
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Скругление углов
          ),
        ),
      ),
      // Тема для текста
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2937),
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2937),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF4B5563),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  // Темная тема
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true, // Используем Material 3
      brightness: Brightness.dark, // Яркость темная
      primaryColor: primary, // Основной цвет
      scaffoldBackgroundColor: const Color(0xFF0F1419), // Цвет фона
      // Тема для AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1F2E), // Цвет фона AppBar
        elevation: 0, // Без тени
        centerTitle: true, // Заголовок по центру
        // Стиль текста заголовка
        titleTextStyle: TextStyle(
          color: Color(0xFFF3F4F6), // Цвет текста
          fontSize: 18, // Размер шрифта
          fontWeight: FontWeight.w600, // Жирность шрифта
        ),
      ),
      // Тема для Card
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1F2E), // Цвет карточки
        elevation: 0, // Без тени
        // Форма карточки
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Скругление углов
          // Граница
          side: const BorderSide(
            color: Color(0xFF2D3748), // Цвет границы
            width: 1, // Ширина границы
          ),
        ),
      ),
    );
  }
}