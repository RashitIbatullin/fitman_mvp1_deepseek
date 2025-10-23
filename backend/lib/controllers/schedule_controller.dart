import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';

class ScheduleController {
  static Future<Response> getSchedule(Request request) async {
    try {
      final userPayload = request.context['user'] as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response.unauthorized('{"error": "Not authenticated"}');
      }

      final userId = userPayload['userId'] as int?;
      final userRole = userPayload['role'] as String?;

      if (userId == null || userRole == null) {
        return Response.badRequest(body: '{"error": "Invalid token payload"}');
      }

      final db = Database();
      final schedule = await db.getScheduleForUser(userId, userRole);

      // TODO: We need a way to serialize the schedule items to JSON.
      // For now, let's assume the schedule is a list of maps.
      return Response.ok(jsonEncode({'schedule': schedule}));

    } catch (e) {
      print('Get schedule error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> createSchedule(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      // Проверяем права (только тренер и админ могут создавать расписание)
      if (user['role'] != 'trainer' && user['role'] != 'admin') {
        return Response(403, body: jsonEncode({'error': 'Insufficient permissions'}));
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // В MVP1 просто возвращаем успех
      return Response(201, body: jsonEncode({
        'message': 'Schedule created successfully',
        'schedule_id': DateTime.now().millisecondsSinceEpoch
      }));
    } catch (e) {
      print('Create schedule error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }
}