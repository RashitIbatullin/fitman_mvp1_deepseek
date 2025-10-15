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
      // Используем mock бэкенд вместо реального API
      final data = await MockBackend.login(email, password);
      final user = User(
        id: data['user']['id'],
        email: data['user']['email'],
        firstName: data['user']['firstName'],
        lastName: data['user']['lastName'],
        role: data['user']['role'],
      );

      return AuthResponse(token: data['token'], user: user);

    } catch (e) {
      print('Login error: $e');
      rethrow;
  }
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

class MockBackend {
  static final Map<String, dynamic> _users = {
    'admin@fitman.ru': {
      'id': 1,
      'email': 'admin@fitman.ru',
      'firstName': 'Админ',
      'lastName': 'Системный',
      'role': 'admin',
      'password': 'admin123'
    },
    'trainer@fitman.ru': {
      'id': 2,
      'email': 'trainer@fitman.ru',
      'firstName': 'Иван',
      'lastName': 'Тренеров',
      'role': 'trainer',
      'password': 'trainer123'
    },
    'client@fitman.ru': {
      'id': 3,
      'email': 'client@fitman.ru',
      'firstName': 'Анна',
      'lastName': 'Клиентова',
      'role': 'client',
      'password': 'client123'
    }
  };

  static Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1)); // Имитация задержки сети

    final user = _users[email];
    if (user == null || user['password'] != password) {
      throw Exception('Invalid email or password');
    }

    return {
      'token': 'mock_jwt_token_${user['id']}',
      'user': {
        'id': user['id'],
        'email': user['email'],
        'firstName': user['firstName'],
        'lastName': user['lastName'],
        'role': user['role']
      }
    };
  }

  static Future<Map<String, dynamic>> register(
      String email, String password, String firstName, String lastName, String role
      ) async {
    await Future.delayed(Duration(seconds: 1));

    if (_users.containsKey(email)) {
      throw Exception('User already exists');
    }

    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'password': password
    };

    _users[email] = newUser;

    return {
      'token': 'mock_jwt_token_${newUser['id']}',
      'user': {
        'id': newUser['id'],
        'email': newUser['email'],
        'firstName': newUser['firstName'],
        'lastName': newUser['lastName'],
        'role': newUser['role']
      }
    };
  }
}