import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:bcrypt/bcrypt.dart';
import '../config/database.dart';
import '../models/user_back.dart';

class UsersController {
  // Получить всех пользователей (только для админа)
  static Future<Response> getUsers(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;

      final users = await Database().getAllUsers();
      final usersJson = users.map((user) => user.toSafeJson()).toList();

      return Response.ok(jsonEncode({'users': usersJson}));
    } catch (e) {
      print('Get users error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Создать нового пользователя (только для админа)
  static Future<Response> createUser(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final email = data['email'] as String;
      final password = data['password'] as String;
      final firstName = data['firstName'] as String;
      final lastName = data['lastName'] as String;
      final role = data['role'] as String;
      final phone = data['phone'] as String?;

      // Проверяем существует ли пользователь
      final existingUser = await Database().getUserByEmail(email);
      if (existingUser != null) {
        return Response(400, body: jsonEncode({'error': 'User already exists'}));
      }

      // Хешируем пароль
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      // Создаем пользователя
      final newUser = User(
        id: 0,
        email: email,
        passwordHash: passwordHash,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phone: phone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdUser = await Database().createUser(newUser);

      return Response(201, body: jsonEncode({
        'message': 'User created successfully',
        'user': createdUser.toSafeJson()
      }));
    } catch (e) {
      print('Create user error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error: $e'}));
    }
  }

  // Получить пользователя по ID
  static Future<Response> getUserById(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid user ID'}));
      }

      final requestingUser = request.context['user'] as Map<String, dynamic>?;

      if (requestingUser?['role'] != 'admin' && requestingUser?['userId'] != userId) {
        return Response(403, body: jsonEncode({'error': 'Access denied'}));
      }

      final user = await Database().getUserById(userId);
      if (user == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }

      return Response.ok(jsonEncode({'user': user.toSafeJson()}));
    } catch (e) {
      print('Get user by ID error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Обновить пользователя
  static Future<Response> updateUser(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid user ID'}));
      }

      final requestingUser = request.context['user'] as Map<String, dynamic>?;

      if (requestingUser?['role'] != 'admin' && requestingUser?['userId'] != userId) {
        return Response(403, body: jsonEncode({'error': 'Access denied'}));
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final updatedUser = await Database().updateUser(
        userId,
        firstName: data['firstName'] as String?,
        lastName: data['lastName'] as String?,
        phone: data['phone'] as String?,
      );

      if (updatedUser == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }

      return Response.ok(jsonEncode({'user': updatedUser.toSafeJson()}));
    } catch (e) {
      print('Update user error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Удалить пользователя (только админ)
  static Future<Response> deleteUser(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid user ID'}));
      }

      final requestingUser = request.context['user'] as Map<String, dynamic>?;

      if (requestingUser?['userId'] == userId) {
        return Response(400, body: jsonEncode({'error': 'Cannot delete your own account'}));
      }

      final success = await Database().deleteUser(userId);
      if (!success) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }

      return Response(200, body: jsonEncode({'message': 'User deleted successfully'}));
    } catch (e) {
      print('Delete user error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Получить профиль текущего пользователя
  static Future<Response> getProfile(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      final userId = user['userId'] as int;
      final userData = await Database().getUserById(userId);

      if (userData == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }

      return Response.ok(jsonEncode({'user': userData.toSafeJson()}));
    } catch (e) {
      print('Get profile error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Получить тренера для клиента
  static Future<Response> getTrainerForClient(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      final trainer = await Database().getTrainerForClient(clientId);

      if (trainer == null) {
        return Response(404, body: jsonEncode({'error': 'Trainer not found for this client'}));
      }

      return Response.ok(jsonEncode({'trainer': trainer.toSafeJson()}));
    } catch (e) {
      print('Get trainer for client error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Получить инструктора для клиента
  static Future<Response> getInstructorForClient(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      final instructor = await Database().getInstructorForClient(clientId);

      if (instructor == null) {
        return Response(404, body: jsonEncode({'error': 'Instructor not found for this client'}));
      }

      return Response.ok(jsonEncode({'instructor': instructor.toSafeJson()}));
    } catch (e) {
      print('Get instructor for client error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Получить менеджера для клиента
  static Future<Response> getManagerForClient(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      final manager = await Database().getManagerForClient(clientId);

      if (manager == null) {
        return Response(404, body: jsonEncode({'error': 'Manager not found for this client'}));
      }

      return Response.ok(jsonEncode({'manager': manager.toSafeJson()}));
    } catch (e) {
      print('Get manager for client error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }
}