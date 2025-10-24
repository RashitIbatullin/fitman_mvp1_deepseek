import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';

class CalorieTrackingController {
  static Future<Response> getCalorieTrackingDataForClient(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      final data = await Database().getCalorieTrackingData(clientId);

      return Response.ok(jsonEncode(data));
    } catch (e) {
      print('Get calorie tracking data error: $e');
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }
}
