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
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }

  static Future<AuthResponse> register(
    String email, 
    String password, 
    String firstName, 
    String lastName, 
    String role,
  ) async {
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

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Registration failed');
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