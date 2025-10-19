import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../middleware/auth_middleware.dart';

class UsersController {
  // Получить всех пользователей (только для админа)
  static Future<Response> getUsers(Request request) async {
    try {
      // Проверяем роль пользователя из контекста
      final user = request.context['user'] as Map<String, dynamic>?;
      
      if (user == null || user['role'] != 'admin') {
        return Response(403, body: jsonEncode({'error': 'Admin access required'}));
      }
      
      final users = await Database().getAllUsers();
      final usersJson = users.map((user) => user.toSafeJson()).toList();
      
      return Response.ok(jsonEncode({'users': usersJson}));
      
    } catch (e) {
      print('Get users error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
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
      
      // Пользователь может получать только свои данные, кроме админа
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
      
      // Пользователь может обновлять только свои данные, кроме админа
      if (requestingUser?['role'] != 'admin' && requestingUser?['userId'] != userId) {
        return Response(403, body: jsonEncode({'error': 'Access denied'}));
      }
      
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      // Разрешаем обновлять только определенные поля
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
      
      if (requestingUser?['role'] != 'admin') {
        return Response(403, body: jsonEncode({'error': 'Admin access required'}));
      }
      
      // Нельзя удалить самого себя
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
}