import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';

// Экран аутентификации (логин/регистрация).
// Подсказка: чтобы поменять цвета элементов, используйте AppTheme из config/theme.dart

/// Экран аутентификации пользователя.
///
/// Содержит две вкладки: вход (Sign In) и регистрация (Sign Up).
/// Для каждой вкладки есть отдельная форма с полями и валидацией.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerUsernameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  int _selectedAge = 18;

  @override
  void dispose() {
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withOpacity(0.1),
              const Color(0xFF627EEA).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildTabButtons(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _isLogin ? _buildLoginForm() : _buildRegisterForm(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Шапка экрана с иконкой кошелька, названием приложения и подзаголовком.
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Secure Wallet',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your crypto, your control',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  /// Переключатели вкладок между входом (Sign In) и регистрацией (Sign Up).
  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = true),
              child: Column(
                children: [
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isLogin ? AppTheme.primary : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLogin)
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = false),
              child: Column(
                children: [
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          !_isLogin ? AppTheme.primary : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_isLogin)
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------------------------------------------------------------------------------------------------------------
  /// ---------------------------------------------------------------------------------------------------------------------
  /// Форма входа: поля Username и Password + кнопка входа.
  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _loginUsernameController,
          label: 'Username',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _loginPasswordController,
          label: 'Password',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Форма регистрации: ник, email, пароль/подтверждение, выбор возраста, предупреждение и кнопка.
  Widget _buildRegisterForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _registerUsernameController,
          label: 'Username',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _registerEmailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _registerPasswordController,
          label: 'Password',
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _registerConfirmPasswordController,
          label: 'Confirm Password',
        ),
        const SizedBox(height: 16),
        _buildAgeSelector(),
        const SizedBox(height: 16),
        _buildAgeWarning(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Универсальное текстовое поле с иконкой слева и состояниями рамки.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  /// Поле ввода пароля с возможностью показать/скрыть символы.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  /// Селектор возраста при регистрации: позволяет выбрать значение 18–100 лет.
  Widget _buildAgeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Your Age:',
            style: TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _selectedAge > 18
                    ? () => setState(() => _selectedAge--)
                    : null,
              ),
              Text(
                '$_selectedAge',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _selectedAge < 100
                    ? () => setState(() => _selectedAge++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Информационный баннер о соответствии возрастным требованиям.
  Widget _buildAgeWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _selectedAge >= 18 ? AppTheme.success : AppTheme.danger,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _selectedAge >= 18 ? AppTheme.success : AppTheme.danger,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _selectedAge >= 18 ? Icons.check_circle : Icons.info,
            color: _selectedAge >= 18 ? AppTheme.success : AppTheme.danger,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selectedAge >= 18
                  ? 'You meet age requirements'
                  : 'You must be at least 18 years old',
              style: TextStyle(
                color: _selectedAge >= 18 ? AppTheme.success : AppTheme.danger,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Обработка нажатия на кнопку входа: валидация, запрос к AuthService и переход на Home.
  Future<void> _handleLogin() async {
    if (_loginUsernameController.text.isEmpty ||
        _loginPasswordController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    final response = await _authService.login(
      username: _loginUsernameController.text,
      password: _loginPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (response.success) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      _showError(response.error ?? response.message);
    }
  }

  /// Обработка нажатия на кнопку регистрации: валидация полей и отправка данных в AuthService.
  Future<void> _handleRegister() async {
    if (_registerUsernameController.text.isEmpty ||
        _registerEmailController.text.isEmpty ||
        _registerPasswordController.text.isEmpty ||
        _registerConfirmPasswordController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    if (_registerPasswordController.text !=
        _registerConfirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    if (_selectedAge < 18) {
      _showError('You must be at least 18 years old');
      return;
    }

    if (!_registerEmailController.text.contains('@')) {
      _showError('Please enter a valid email');
      return;
    }

    setState(() => _isLoading = true);

    final response = await _authService.register(
      username: _registerUsernameController.text,
      email: _registerEmailController.text,
      password: _registerPasswordController.text,
      age: _selectedAge,
    );

    setState(() => _isLoading = false);

    if (response.success) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      _showError(response.error ?? response.message);
    }
  }

  /// Показать Snackbar с ошибкой.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.danger,
      ),
    );
  }
}
