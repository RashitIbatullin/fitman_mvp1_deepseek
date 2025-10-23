import 'package:fitman_app/screens/trainer_dashboard.dart';
import 'package:fitman_app/screens/unknown_role_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'admin_dashboard.dart';
import 'register_screen.dart';
import 'client_dashboard.dart';
import 'manager_dashboard.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Тестовые данные для быстрого входа
    _emailController.text = 'client@fitman.ru';
    _passwordController.text = 'client123';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Редирект при успешной аутентификации с учетом роли
    if (authState.hasValue && authState.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final user = authState.value!;
        Widget targetScreen;

        switch (user.role) {
          case 'admin':
            targetScreen = const AdminDashboard();
            break;
          case 'trainer':
            targetScreen = const TrainerDashboard();
            break;
          case 'client':
            targetScreen = const ClientDashboard();
            break;
          case 'manager':
            targetScreen = const ManagerDashboard();
            break;
          default:
            targetScreen = const UnknownRoleScreen();
        }

        print('Redirecting to: ${user.role} dashboard');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
              (route) => false,
        );
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход в систему'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports_gymnastics,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Фитнес-менеджер',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  if (!value.contains('@')) {
                    return 'Введите корректный email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (value.length < 6) {
                    return 'Пароль должен быть не менее 6 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (authState.isLoading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Войти',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              if (authState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    authState.error.toString(),
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Нет аккаунта?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Зарегистрируйтесь'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Тестовые пользователи:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildTestUserChip('admin@fitman.ru', 'admin123', 'Админ'),
                  _buildTestUserChip('trainer@fitman.ru', 'trainer123', 'Тренер'),
                  _buildTestUserChip('manager@fitman.ru', 'manager123', 'Менеджер'),
                  _buildTestUserChip('client@fitman.ru', 'client123', 'Клиент'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestUserChip(String email, String password, String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _emailController.text = email;
        _passwordController.text = password;
        _handleLogin();
      },
      backgroundColor: Colors.blue.shade100,
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}