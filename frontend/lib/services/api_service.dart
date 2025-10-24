import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_item.dart';
import '../models/user_front.dart';
import '../models/work_schedule.dart';
import '../models/client_schedule_preference.dart'; // Import ClientSchedulePreference

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

  // Получение списка клиентов для менеджера
  static Future<List<User>> getAssignedClients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/manager/clients'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load assigned clients with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get assigned clients error: $e');
      rethrow;
    }
  }

  // Получение списка инструкторов для менеджера
  static Future<List<User>> getAssignedInstructors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/manager/instructors'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load assigned instructors with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get assigned instructors error: $e');
      rethrow;
    }
  }

  // Получение списка тренеров для менеджера
  static Future<List<User>> getAssignedTrainers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/manager/trainers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load assigned trainers with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get assigned trainers error: $e');
      rethrow;
    }
  }

  // Получение списка клиентов для инструктора
  static Future<List<User>> getAssignedClientsForInstructor() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/instructor/clients'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load assigned clients for instructor with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get assigned clients for instructor error: $e');
      rethrow;
    }
  }

  // Получение списка тренеров для инструктора
  static Future<List<User>> getAssignedTrainersForInstructor() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/instructor/trainers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load assigned trainers for instructor with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get assigned trainers for instructor error: $e');
      rethrow;
    }
  }

  // Получение менеджера для инструктора
  static Future<User> getAssignedManagerForInstructor() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/instructor/manager'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load assigned manager for instructor with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get assigned manager for instructor error: $e');
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
  static Future<List<ScheduleItem>> getSchedule() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/schedule'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final scheduleList = data['schedule'] as List;
      return scheduleList.map((item) => ScheduleItem.fromJson(item)).toList();
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

  // Получение ID клиентов, назначенных менеджеру
  static Future<List<int>> getAssignedClientIds(int managerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/managers/$managerId/clients/ids'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<int>().toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load assigned client IDs');
      }
    } catch (e) {
      print('Get assigned client IDs error: $e');
      rethrow;
    }
  }

  // Назначение клиентов менеджеру
  static Future<void> assignClientsToManager(int managerId, List<int> clientIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/managers/$managerId/clients'),
        headers: _headers,
        body: jsonEncode({'client_ids': clientIds}),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to assign clients');
      }
    } catch (e) {
      print('Assign clients error: $e');
      rethrow;
    }
  }

  // Получение ID инструкторов, назначенных менеджеру
  static Future<List<int>> getAssignedInstructorIds(int managerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/managers/$managerId/instructors/ids'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<int>().toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load assigned instructor IDs');
      }
    } catch (e) {
      print('Get assigned instructor IDs error: $e');
      rethrow;
    }
  }

  // Назначение инструкторов менеджеру
  static Future<void> assignInstructorsToManager(int managerId, List<int> instructorIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/managers/$managerId/instructors'),
        headers: _headers,
        body: jsonEncode({'instructor_ids': instructorIds}),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to assign instructors');
      }
    } catch (e) {
      print('Assign instructors error: $e');
      rethrow;
    }
  }

  // Получение ID тренеров, назначенных менеджеру
  static Future<List<int>> getAssignedTrainerIds(int managerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/managers/$managerId/trainers/ids'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<int>().toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load assigned trainer IDs');
      }
    } catch (e) {
      print('Get assigned trainer IDs error: $e');
      rethrow;
    }
  }

  // Назначение тренеров менеджеру
  static Future<void> assignTrainersToManager(int managerId, List<int> trainerIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/managers/$managerId/trainers'),
        headers: _headers,
        body: jsonEncode({'trainer_ids': trainerIds}),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to assign trainers');
      }
    } catch (e) {
      print('Assign trainers error: $e');
      rethrow;
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

  // Получение данных для дашборда клиента
  static Future<Map<String, dynamic>> getClientDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dashboard/client'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load dashboard data with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get client dashboard data error: $e');
      rethrow;
    }
  }

  // Получение тренера для клиента
  static Future<User> getTrainerForClient() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/trainer'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['trainer']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load trainer data with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get trainer for client error: $e');
      rethrow;
    }
  }

  // Получение инструктора для клиента
  static Future<User> getInstructorForClient() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/instructor'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['instructor']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load instructor data with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get instructor for client error: $e');
      rethrow;
    }
  }

  // Получение менеджера для клиента
  static Future<User> getManagerForClient() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/manager'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['manager']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load manager data with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get manager for client error: $e');
      rethrow;
    }
  }

  // Получение данных антропометрии для клиента
  static Future<Map<String, dynamic>> getAnthropometryData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/anthropometry'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load anthropometry data with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get anthropometry data error: $e');
      rethrow;
    }
  }

  // Получение данных отслеживания калорий для клиента
  static Future<List<dynamic>> getCalorieTrackingData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/calorie-tracking'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load calorie tracking data with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get calorie tracking data error: $e');
      rethrow;
    }
  }

  // Получение данных прогресса для клиента
  static Future<Map<String, dynamic>> getProgressData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/progress'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load progress data with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get progress data error: $e');
      rethrow;
    }
  }

  // Получение расписания работы центра
  static Future<List<WorkSchedule>> getWorkSchedules() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/work-schedules'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WorkSchedule.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load work schedules with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get work schedules error: $e');
      rethrow;
    }
  }

  // Обновление расписания работы центра
  static Future<void> updateWorkSchedule(WorkSchedule schedule) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/work-schedules'),
        headers: _headers,
        body: jsonEncode(schedule.toJson()),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update work schedule with status ${response.statusCode}');
      }
    } catch (e) {
      print('Update work schedule error: $e');
      rethrow;
    }
  }

  // Сохранение предпочтений клиента
  static Future<void> saveClientPreferences(List<ClientSchedulePreference> preferences) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/client/preferences'),
        headers: _headers,
        body: jsonEncode(preferences.map((p) => p.toJson()).toList()),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to save client preferences with status ${response.statusCode}');
      }
    } catch (e) {
      print('Save client preferences error: $e');
      rethrow;
    }
  }

  // Получение предпочтений клиента
  static Future<List<ClientSchedulePreference>> getClientPreferences() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/preferences'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ClientSchedulePreference.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load client preferences with status ${response.statusCode}');
      }
    } catch (e) {
      print('Get client preferences error: $e');
      rethrow;
    }
  }
}
