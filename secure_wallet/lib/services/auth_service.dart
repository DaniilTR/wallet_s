import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/auth.dart';

// Сервис аутентификации: register/login/logout и хранение текущего пользователя/токена

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
        final data = json.decode(response.body);
        final auth = AuthResponse.fromJson(data);
        if (auth.success && auth.user != null) {
          _currentUser = auth.user;
          _token = auth.user!.token;
          return auth;
        }
        return AuthResponse(success: false, message: 'Invalid auth response');
      }

      // Обработка всех остальных кодов состояния
      print(
          '[AuthService] Login failed with status code: ${response.statusCode}');
      return AuthResponse(
        success: false,
        message: 'Login failed',
        error: 'Status code: ${response.statusCode}',
      );
    } catch (e) {
      print('[AuthService] An exception occurred during login: $e');
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
      print('Logout error: $e');
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
