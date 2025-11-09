// Модель пользователя и ответы аутентификации
// User — данные профиля; AuthResponse — результат login/register
class User {
  final String id;
  final String username;
  final String email;
  final int age;
  final DateTime createdAt;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.age,
    required this.createdAt,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      age: json['age'],
      createdAt: DateTime.parse(json['createdAt']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'age': age,
      'createdAt': createdAt.toIso8601String(),
      'token': token,
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? error;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      error: json['error'],
    );
  }
}
