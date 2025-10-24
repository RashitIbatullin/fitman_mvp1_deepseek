import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import '../../config/database.dart';

class WorkScheduleController {
  static Future<Response> getWorkSchedules(Request request) async {
    try {
      final db = Database();
      final connection = await db.connection;
      final result = await connection.execute('SELECT * FROM work_schedules ORDER BY day_of_week');
      final schedules = result.map((row) {
        final map = row.toColumnMap();
        final startTime = map['start_time'] as Time;
        final endTime = map['end_time'] as Time;
        map['start_time'] = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
        map['end_time'] = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
        // Convert DateTime objects to ISO 8601 strings
        if (map['created_at'] is DateTime) {
          map['created_at'] = (map['created_at'] as DateTime).toIso8601String();
        }
        if (map['updated_at'] is DateTime) {
          map['updated_at'] = (map['updated_at'] as DateTime).toIso8601String();
        }
        if (map['archived_at'] is DateTime) {
          map['archived_at'] = (map['archived_at'] as DateTime).toIso8601String();
        }
        return map;
      }).toList();
      return Response.ok(jsonEncode(schedules));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Error getting work schedules: $e'}));
    }
  }

  static Future<Response> createWorkSchedule(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final db = Database();
      final connection = await db.connection;
      await connection.execute(
        Sql.named('INSERT INTO work_schedules (day_of_week, start_time, end_time, is_day_off) VALUES (@dayOfWeek, @startTime, @endTime, @isDayOff)'),
        parameters: {
          'dayOfWeek': data['day_of_week'],
          'startTime': data['start_time'],
          'endTime': data['end_time'],
          'isDayOff': data['is_day_off'],
        },
      );
      return Response.ok(jsonEncode({'message': 'Work schedule created successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Error creating work schedule: $e'}));
    }
  }

  static Future<Response> updateWorkSchedule(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final db = Database();
      final connection = await db.connection;
      print('UPDATE work_schedules SET day_of_week = @dayOfWeek, start_time = @startTime, end_time = @endTime, is_day_off = @isDayOff, updated_at = NOW() WHERE id = @id');
      print(data);
      await connection.execute(
          Sql.named('UPDATE work_schedules SET day_of_week = @dayOfWeek, start_time = @startTime, end_time = @endTime, is_day_off = @isDayOff, updated_at = NOW() WHERE id = @id'),
          parameters: {
            'id': data['id'] as int,
            'dayOfWeek': data['day_of_week'],
            'startTime': data['start_time'],
            'endTime': data['end_time'],
            'isDayOff': data['is_day_off'],
          }
      );

      return Response.ok(jsonEncode({'message': 'Work schedule updated successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Error updating work schedule: $e'}));
    }
  }

  static Future<Response> deleteWorkSchedule(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final db = Database();
      final connection = await db.connection;
      print('UPDATE work_schedules SET archived_at = NOW() WHERE id = @id');
      print(data);
      await connection.execute(
        Sql.named('UPDATE work_schedules SET archived_at = NOW() WHERE id = @id'),
        parameters: {
          'id': data['id'] as int,
        },
      );
      return Response.ok(jsonEncode({'message': 'Work schedule deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Error deleting work schedule: $e'}));
    }
  }
}