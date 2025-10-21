import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_front.dart';

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']?.toString() ?? '';
        final userData = data['user'] ?? {};

        if (token.isEmpty) {
          throw Exception('No token received from server');
        }

        final user = User(
          id: userData['id'] is int ? userData['id'] : int.parse(userData['id']?.toString() ?? '0'),
          email: userData['email']?.toString() ?? email,
          passwordHash: userData['passwordHash']?.toString() ?? '',
          firstName: userData['firstName']?.toString() ?? userData['first_name']?.toString() ?? 'User',
          lastName: userData['lastName']?.toString() ?? userData['last_name']?.toString() ?? '',
          middleName: userData['middleName']?.toString(),
          role: userData['role']?.toString() ?? 'client',
          phone: userData['phone']?.toString(),
          gender: userData['gender']?.toString(),
          age: userData['age'] != null ? int.tryParse(userData['age'].toString()) : null,
          sendNotification: userData['sendNotification']?.toString() == 'true',
          hourNotification: userData['hourNotification'] != null ? int.tryParse(userData['hourNotification'].toString()) ?? 1 : 1,
          trackCalories: userData['trackCalories']?.toString() == 'true',
          coeffActivity: userData['coeffActivity'] != null ? double.tryParse(userData['coeffActivity'].toString()) ?? 1.2 : 1.2,
          createdAt: userData['createdAt'] is DateTime
              ? userData['createdAt']
              : DateTime.parse(userData['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
          updatedAt: userData['updatedAt'] is DateTime
              ? userData['updatedAt']
              : DateTime.parse(userData['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
        );

        return AuthResponse(token: token, user: user);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? errorData['error'] ?? 'Login failed with status ${response.statusCode}');
      }
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']?.toString() ?? '';
        final userData = data['user'] ?? {};

        if (token.isEmpty) {
          throw Exception('No token received from server');
        }

        final user = User(
          id: userData['id'] is int ? userData['id'] : int.parse(userData['id']?.toString() ?? '0'),
          email: userData['email']?.toString() ?? email,
          passwordHash: userData['passwordHash']?.toString() ?? '',
          firstName: userData['firstName']?.toString() ?? userData['first_name']?.toString() ?? firstName,
          lastName: userData['lastName']?.toString() ?? userData['last_name']?.toString() ?? lastName,
          middleName: userData['middleName']?.toString(),
          role: userData['role']?.toString() ?? role,
          phone: userData['phone']?.toString(),
          gender: userData['gender']?.toString(),
          age: userData['age'] != null ? int.tryParse(userData['age'].toString()) : null,
          sendNotification: userData['sendNotification']?.toString() == 'true',
          hourNotification: userData['hourNotification'] != null ? int.tryParse(userData['hourNotification'].toString()) ?? 1 : 1,
          trackCalories: userData['trackCalories']?.toString() == 'true',
          coeffActivity: userData['coeffActivity'] != null ? double.tryParse(userData['coeffActivity'].toString()) ?? 1.2 : 1.2,
          createdAt: userData['createdAt'] is DateTime
              ? userData['createdAt']
              : DateTime.parse(userData['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
          updatedAt: userData['updatedAt'] is DateTime
              ? userData['updatedAt']
              : DateTime.parse(userData['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
        );

        return AuthResponse(token: token, user: user);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? errorData['error'] ?? 'Registration failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  // Создание пользователя (для админа)
  static Future<Map<String, dynamic>> createUser(CreateUserRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create user with status ${response.statusCode}');
      }
    } catch (e) {
      print('Create user error: $e');
      rethrow;
    }
  }

  // Получение списка пользователей (для админа)
  static Future<List<User>> getUsers({String? role}) async {
    try {
      final url = role != null ? '$baseUrl/api/users?role=$role' : '$baseUrl/api/users';
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] as List;
        return users.map((userData) {
          return User(
            id: userData['id'] is int ? userData['id'] : int.parse(userData['id']?.toString() ?? '0'),
            email: userData['email']?.toString() ?? '',
            passwordHash: userData['passwordHash']?.toString() ?? '',
            firstName: userData['firstName']?.toString() ?? '',
            lastName: userData['lastName']?.toString() ?? '',
            middleName: userData['middleName']?.toString(),
            role: userData['role']?.toString() ?? 'client',
            phone: userData['phone']?.toString(),
            gender: userData['gender']?.toString(),
            age: userData['age'] != null ? int.tryParse(userData['age'].toString()) : null,
            sendNotification: userData['sendNotification']?.toString() == 'true',
            hourNotification: userData['hourNotification'] != null ? int.tryParse(userData['hourNotification'].toString()) ?? 1 : 1,
            trackCalories: userData['trackCalories']?.toString() == 'true',
            coeffActivity: userData['coeffActivity'] != null ? double.tryParse(userData['coeffActivity'].toString()) ?? 1.2 : 1.2,
            createdAt: DateTime.parse(userData['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
            updatedAt: DateTime.parse(userData['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
          );
        }).toList();
      } else {
        throw Exception('Failed to load users with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get users error: $e');
      rethrow;
    }
  }

  // Получение планов тренировок
  static Future<List<dynamic>> getTrainingPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/training/plans'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['plans'] as List;
    } else {
      throw Exception('Failed to load training plans with status ${response.statusCode}');
    }
  }

  // Получение расписания
  static Future<List<dynamic>> getSchedule() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/schedule'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['schedule'] as List;
    } else {
      throw Exception('Failed to load schedule with status ${response.statusCode}');
    }
  }

  // Получение сообщений чата
  static Future<List<dynamic>> getChatMessages(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/messages/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['messages'] as List;
    } else {
      throw Exception('Failed to load chat messages with status ${response.statusCode}');
    }
  }

  // Отправка сообщения
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
      throw Exception('Failed to send message with status ${response.statusCode}');
    }
  }
}