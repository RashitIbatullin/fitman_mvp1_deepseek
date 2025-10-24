
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:postgres/postgres.dart';
import '../config/database.dart';

class ClientPreferenceController {
  static Future<Response> saveClientPreferences(Request request) async {
    try {
      final body = await request.readAsString();
      final List<dynamic> preferencesData = jsonDecode(body);
      final db = Database();
      final connection = await db.connection;

      // Get client ID from request context (assuming it's set by auth middleware)
      final user = request.context['user'] as Map<String, dynamic>?;
      final clientId = user?['userId'] as int?;

      if (clientId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Client ID not found in token.'}));
      }

      await connection.runTx((ctx) async {
        // Delete existing preferences for the client to avoid conflicts and simplify update
        await ctx.execute(
          Sql.named('DELETE FROM client_schedule_preferences WHERE client_id = @clientId'),
          parameters: {'clientId': clientId},
        );

        for (var pref in preferencesData) {
          await ctx.execute(
            Sql.named('INSERT INTO client_schedule_preferences (client_id, day_of_week, preferred_start_time, preferred_end_time) VALUES (@clientId, @dayOfWeek, @preferredStartTime, @preferredEndTime)'),
            parameters: {
              'clientId': clientId,
              'dayOfWeek': pref['day_of_week'],
              'preferredStartTime': pref['preferred_start_time'],
              'preferredEndTime': pref['preferred_end_time'],
            },
          );
        }
      });

      return Response.ok(jsonEncode({'message': 'Client preferences saved successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Error saving client preferences: $e'}));
    }
  }

  static Future<Response> getClientPreferences(Request request) async {
    try {
      final db = Database();
      final connection = await db.connection;

      // Get client ID from request context (assuming it's set by auth middleware)
      final user = request.context['user'] as Map<String, dynamic>?;
      final clientId = user?['id'] as int?;

      if (clientId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Client ID not found in token.'}));
      }

      final result = await connection.execute(
        Sql.named('SELECT day_of_week, preferred_start_time, preferred_end_time FROM client_schedule_preferences WHERE client_id = @clientId ORDER BY day_of_week'),
        parameters: {'clientId': clientId},
      );

      final preferences = result.map((row) {
        final map = row.toColumnMap();
        // Convert Time objects to String for JSON serialization
        final preferredStartTime = map['preferred_start_time'] as Time;
        final preferredEndTime = map['preferred_end_time'] as Time;
        map['preferred_start_time'] = '${preferredStartTime.hour.toString().padLeft(2, '0')}:${preferredStartTime.minute.toString().padLeft(2, '0')}';
        map['preferred_end_time'] = '${preferredEndTime.hour.toString().padLeft(2, '0')}:${preferredEndTime.minute.toString().padLeft(2, '0')}';
        return map;
      }).toList();

      return Response.ok(jsonEncode(preferences));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Error getting client preferences: $e'}));
    }
  }
}
