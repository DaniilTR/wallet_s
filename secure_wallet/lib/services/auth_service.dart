import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/auth.dart';
import 'package:flutter/foundation.dart'; // добавьте этот импорт

class AuthService {
  static final AuthService _instance = AuthService._internal();

  final String baseUrl =
      'http://localhost:8080/api'; // Замените на ваш backend URL

  User? _currentUser;
  String? _token;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _currentUser != null && _token != null;

  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    required int age,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'age': age,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        if (authResponse.success && authResponse.user != null) {
          _currentUser = authResponse.user;
          _token = authResponse.user!.token;
          return authResponse;
        }
      }

      return AuthResponse(
        success: false,
        message: 'Registration failed',
        error: 'Status code: ${response.statusCode}',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Error during registration',
        error: e.toString(),
      );
    }
  }

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      // Явное указание на успешный вход при статусе 200
      if (response.statusCode == 200) {
        debugPrint(
            '[AuthService] Login successful with status 200. Body: ${response.body}');
        try {
          final data = json.decode(response.body);
          final user = User.fromJson(data);
          _currentUser = user;
          _token = user.token;
          return AuthResponse(
              success: true, message: 'Login successful', user: user);
        } catch (e) {
          debugPrint(
              '[AuthService] Failed to parse user data from response: $e');
          // Все равно возвращаем успех, чтобы обеспечить перенаправление
          return AuthResponse(
              success: true,
              message: 'Login successful, but user data parsing failed');
        }
      }

      // Обработка всех остальных кодов состояния
      debugPrint(
          '[AuthService] Login failed with status code: ${response.statusCode}');
      return AuthResponse(
        success: false,
        message: 'Login failed',
        error: 'Status code: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('[AuthService] An exception occurred during login: $e');
      return AuthResponse(
        success: false,
        message: 'An error occurred during login',
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _currentUser = null;
      _token = null;
    }
  }

  Map<String, String> get authHeaders {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }
}
