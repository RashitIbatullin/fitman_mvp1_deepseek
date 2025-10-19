import 'dart:convert';
import 'package:shelf/shelf.dart';

class ScheduleController {
  static Future<Response> getSchedule(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      // В MVP1 возвращаем моковые данные расписания
      final mockSchedule = [
        {
          'id': 1,
          'training_plan_name': 'Похудение для начинающих',
          'start_time': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
          'end_time': DateTime.now().add(const Duration(hours: 3)).toIso8601String(),
          'status': 'scheduled',
          'trainer_name': 'Иван Тренеров'
        },
        {
          'id': 2,
          'training_plan_name': 'Силовая тренировка',
          'start_time': DateTime.now().add(const Duration(days: 1, hours: 10)).toIso8601String(),
          'end_time': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
          'status': 'scheduled',
          'trainer_name': 'Петр Инструкторов'
        }
      ];

      return Response.ok(jsonEncode({'schedule': mockSchedule}));
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