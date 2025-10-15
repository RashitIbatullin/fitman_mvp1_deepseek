import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Аутентификация
  static Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('=== LOGIN RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=====================');

      // ВРЕМЕННАЯ ЗАГЛУШКА ДЛЯ РАЗРАБОТКИ
      // Если сервер возвращает только сообщение, создаем тестовые данные
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Проверяем, есть ли реальные данные
        if (data['token'] == null) {
          print('=== USING MOCK DATA ===');

          // Создаем тестового пользователя
          final mockUser = User(
            id: 1,
            email: email,
            firstName: 'Test',
            lastName: 'User',
            role: _determineRole(email),
          );

          // Создаем mock токен
          final mockToken = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';

          return AuthResponse(
            token: mockToken,
            user: mockUser,
          );
        } else {
          // Используем реальные данные если они есть
          final token = data?['token']?.toString() ?? '';
          final userData = data?['user'] ?? {};

          if (token.isEmpty) {
            throw Exception('No token received from server');
          }

          final user = User(
            id: userData?['id'] ?? 1,
            email: userData?['email']?.toString() ?? email,
            firstName: userData?['firstName']?.toString() ?? userData?['first_name']?.toString() ?? 'User',
            lastName: userData?['lastName']?.toString() ?? userData?['last_name']?.toString() ?? '',
            phone: userData?['phone']?.toString(),
            role: userData?['role']?.toString() ?? _determineRole(email),
          );

          return AuthResponse(token: token, user: user);
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData?['message'] ?? errorData?['error'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

// Вспомогательный метод для определения роли по email
  static String _determineRole(String email) {
    if (email.contains('admin')) return 'admin';
    if (email.contains('trainer')) return 'trainer';
    return 'client';
  }

  static Future<AuthResponse> register(
      String email,
      String password,
      String firstName,
      String lastName,
      String role,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
        }),
      );

      print('=== REGISTER RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('========================');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Всегда возвращаем либо mock данные, либо реальные
        final token = data?['token']?.toString() ?? 'mock_jwt_token_register_${DateTime.now().millisecondsSinceEpoch}';
        final userData = data?['user'] ?? {};

        final user = User(
          id: userData?['id'] ?? DateTime.now().millisecondsSinceEpoch,
          email: userData?['email']?.toString() ?? email,
          firstName: userData?['firstName']?.toString() ?? userData?['first_name']?.toString() ?? firstName,
          lastName: userData?['lastName']?.toString() ?? userData?['last_name']?.toString() ?? lastName,
          phone: userData?['phone']?.toString(),
          role: userData?['role']?.toString() ?? role,
        );

        return AuthResponse(token: token, user: user);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData?['message'] ?? errorData?['error'] ?? 'Registration failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  // Пользователи
  static Future<List<User>> getUsers({String? role}) async {
    final url = role != null ? '$baseUrl/api/users?role=$role' : '$baseUrl/api/users';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final users = data['users'] as List;
      return users.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Планы тренировок
  static Future<List<dynamic>> getTrainingPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/training/plans'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['plans'] as List;
    } else {
      // Заглушка для демонстрации
      return [
        {
          'id': 1,
          'name': 'Похудение для начинающих',
          'goal': 'weight_loss',
          'level': 'beginner',
          'description': 'Базовые упражнения для снижения веса'
        },
        {
          'id': 2,
          'name': 'Набор мышечной массы',
          'goal': 'muscle_gain',
          'level': 'intermediate',
          'description': 'Силовые тренировки для роста мышц'
        }
      ];
    }
  }

  // Расписание
  static Future<List<dynamic>> getSchedule() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/schedule'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['schedule'] as List;
    } else {
      // Заглушка для демонстрации
      return [
        {
          'id': 1,
          'training_plan_name': 'Похудение для начинающих',
          'start_time': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
          'end_time': DateTime.now().add(const Duration(hours: 3)).toIso8601String(),
          'status': 'scheduled',
          'trainer_name': 'Иван Тренеров'
        }
      ];
    }
  }

  // Чат
  static Future<List<dynamic>> getChatMessages(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/messages/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['messages'] as List;
    } else {
      return [];
    }
  }

  static Future<void> sendMessage(int receiverId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat/send'),
      headers: _headers,
      body: jsonEncode({
        'receiverId': receiverId,
        'message': message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }
}