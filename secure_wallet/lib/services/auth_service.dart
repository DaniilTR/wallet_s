import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' show log;
import 'package:secure_wallet/models/auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  final String baseUrl = 'http://localhost:8080/api'; // Замените на ваш backend URL
  
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

      // Treat 200/201 as success and be tolerant to response shape, to allow immediate navigation post-registration
      if (response.statusCode == 201 || response.statusCode == 200) {
        log('[AuthService] Register successful with status ${response.statusCode}. Body: ${response.body}');
        try {
          final data = json.decode(response.body);
          if (data is Map<String, dynamic>) {
            if (data.containsKey('success') || data.containsKey('user')) {
              final authResponse = AuthResponse.fromJson(data);
              if (authResponse.user != null) {
                _currentUser = authResponse.user;
                _token = authResponse.user!.token;
              }
              return AuthResponse(
                success: true,
                message: authResponse.message.isNotEmpty ? authResponse.message : 'Registration successful',
                user: authResponse.user,
                statusCode: response.statusCode,
              );
            } else {
              // Attempt to parse directly as User
              try {
                final user = User.fromJson(data);
                _currentUser = user;
                _token = user.token;
                return AuthResponse(success: true, message: 'Registration successful', user: user, statusCode: response.statusCode);
              } catch (_) {
                // Fall through to generic success
              }
            }
          }
          // Generic success when parsing didn't fit expected schema
          return AuthResponse(success: true, message: 'Registration successful', statusCode: response.statusCode);
        } catch (e) {
          log('[AuthService] Failed to parse register response: $e');
          return AuthResponse(success: true, message: 'Registration successful, but response parsing failed', statusCode: response.statusCode);
        }
      }

      // If user already exists (409), attempt automatic login
      if (response.statusCode == 409) {
        log('[AuthService] Register conflict (409). User may already exist. Trying auto login...');
        final loginResp = await login(username: username, password: password);
        if (loginResp.success) {
          // Return success so UI navigates to Home
          return AuthResponse(
            success: true,
            message: 'Logged in to existing account',
            user: loginResp.user,
            statusCode: 200,
          );
        }
        // Otherwise provide descriptive 409 error
        String details = '';
        final headerMsg = response.headers['x-log-message'] ?? response.headers['X-Log-Message'] ?? '';
        try {
          final parsed = json.decode(response.body);
          if (parsed is Map<String, dynamic>) {
            details = (parsed['message'] ?? parsed['error'] ?? parsed['detail'] ?? '').toString();
          } else if (parsed is String) {
            details = parsed;
          }
        } catch (_) {
          // ignore parse errors
        }
        const friendly = 'User already exists';
        return AuthResponse(
          success: false,
          message: friendly,
          error: 'HTTP 409: ${details.isNotEmpty ? details : friendly}${headerMsg.isNotEmpty ? ' | $headerMsg' : ''}',
          statusCode: 409,
        );
      }

      // Explicitly handle 500 as failure (no navigation)
      if (response.statusCode == 500) {
        log('[AuthService] Register server error (500). Body: ${response.body}');
        String details = '';
        final headerMsg = response.headers['x-log-message'] ?? response.headers['X-Log-Message'] ?? '';
        try {
          final parsed = json.decode(response.body);
          if (parsed is Map<String, dynamic>) {
            details = (parsed['message'] ?? parsed['error'] ?? parsed['detail'] ?? '').toString();
          } else if (parsed is String) {
            details = parsed;
          }
        } catch (_) {
          // ignore parse errors
        }
  const friendly = 'Server error during registration';
        return AuthResponse(
          success: false,
          message: friendly,
          error: 'HTTP 500: ${details.isNotEmpty ? details : friendly}${headerMsg.isNotEmpty ? ' | $headerMsg' : ''}',
          statusCode: 500,
        );
      }

      log('[AuthService] Register failed with status code: ${response.statusCode}');
      final headerMsg = response.headers['x-log-message'] ?? response.headers['X-Log-Message'] ?? '';
      return AuthResponse(
        success: false,
        message: 'Registration failed',
        error: 'Status code: ${response.statusCode}${headerMsg.isNotEmpty ? ' | $headerMsg' : ''}',
        statusCode: response.statusCode,
      );
    } catch (e) {
      log('[AuthService] An exception occurred during register: $e');
      // Do not navigate on exceptions
      return AuthResponse(
        success: false,
        message: 'An error occurred during registration',
        error: e.toString(),
        statusCode: 0,
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
        log('[AuthService] Login successful with status 200. Body: ${response.body}');
        try {
          final data = json.decode(response.body);
          // Бэкенд возвращает { jwt: "..." }. Сохраним токен и продолжим.
          if (data is Map<String, dynamic> && data['jwt'] is String) {
            _token = data['jwt'] as String;
          }
          // Попытка распарсить пользователя (если когда-нибудь сервер начнёт отдавать юзера)
          try {
            final user = User.fromJson(data);
            _currentUser ??= user;
            _token ??= user.token;
          } catch (_) {
            // Игнорируем — для навигации достаточно токена
          }
          return AuthResponse(success: true, message: 'Login successful', user: _currentUser, statusCode: 200);
        } catch (e) {
          log('[AuthService] Failed to parse login response: $e');
          // Возвращаем успех для навигации, даже если парсинг не удался
          return AuthResponse(success: true, message: 'Login successful', statusCode: 200);
        }
      }

      // Обработка всех остальных кодов состояния
  log('[AuthService] Login failed with status code: ${response.statusCode}');
      return AuthResponse(
        success: false,
        message: 'Login failed',
        error: 'Status code: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } catch (e) {
  log('[AuthService] An exception occurred during login: $e');
      return AuthResponse(
        success: false,
        message: 'An error occurred during login',
        error: e.toString(),
        statusCode: 0,
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
      log('Logout error: $e');
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
