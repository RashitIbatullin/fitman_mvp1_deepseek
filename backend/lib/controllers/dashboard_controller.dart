import 'dart:convert';
import 'package:shelf/shelf.dart';

class DashboardController {
  static Future<Response> getClientDashboardData(Request request) async {
    // TODO: Implement data fetching from database

    // Placeholder data
    final data = {
      'nextTraining': {
        'title': 'Силовая тренировка',
        'time': '2025-10-27T18:00:00',
      },
      'trainingProgress': {
        'completed': 5,
        'total': 8,
        'caloriesBurned': 1500,
        'attendance': 85,
      },
      'goalProgress': {
        'goal': 'Похудение',
        'currentWeight': 75,
        'targetWeight': 70,
        'avgDeficit': -350,
      },
      'achievements': [
        {'icon': 'star', 'color': 'amber'},
        {'icon': 'local_fire_department', 'color': 'red'},
        {'icon': 'fitness_center', 'color': 'blue'},
      ]
    };

    return Response.ok(jsonEncode(data));
  }
}
