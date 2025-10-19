import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../models/training_plan.dart';

class TrainingController {
  static Future<Response> getTrainingPlans(Request request) async {
    try {
      // В MVP1 возвращаем моковые данные
      final mockPlans = [
        {
          'id': 1,
          'name': 'Похудение для начинающих',
          'goal': 'weight_loss',
          'level': 'beginner',
          'description': 'Базовые упражнения для снижения веса'
        },
        {
          'id': 2,
          'name': 'Набор мышечной массы',
          'goal': 'muscle_gain',
          'level': 'intermediate',
          'description': 'Силовые тренировки для роста мышц'
        },
        {
          'id': 3,
          'name': 'Поддержание формы',
          'goal': 'maintenance',
          'level': 'beginner',
          'description': 'Упражнения для поддержания текущей формы'
        }
      ];

      return Response.ok(jsonEncode({'plans': mockPlans}));
    } catch (e) {
      print('Get training plans error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> getExercises(Request request) async {
    try {
      // В MVP1 возвращаем моковые данные
      final mockExercises = [
        {
          'id': 1,
          'name': 'Бег на дорожке',
          'type': 'cardio',
          'description': 'Бег на беговой дорожке',
          'caloriesPerMinute': 8.5
        },
        {
          'id': 2,
          'name': 'Приседания',
          'type': 'strength',
          'description': 'Базовые приседания',
          'caloriesPerMinute': 5.0
        },
        {
          'id': 3,
          'name': 'Отжимания',
          'type': 'strength',
          'description': 'Классические отжимания',
          'caloriesPerMinute': 6.0
        }
      ];

      return Response.ok(jsonEncode({'exercises': mockExercises}));
    } catch (e) {
      print('Get exercises error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }
}