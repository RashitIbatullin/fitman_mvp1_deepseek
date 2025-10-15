import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../db/database.dart';

void main(List<String> args) async {
  // Инициализация базы данных
  await Database.initialize();
  print('✅ Database initialized successfully');

  // Запуск сервера
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  // Создаем handler с CORS middleware
  final handler = const Pipeline()
      .addMiddleware(corsMiddleware)
      .addHandler(_router);

  final server = await serve(handler, 'localhost', port);

  print('🚀 Server running on http://localhost:${server.port}');
}

// CORS Middleware - теперь это сам Middleware, а не функция
Middleware get corsMiddleware {
  return (handler) {
    return (context) async {
      // Обработка preflight запросов
      if (context.request.method == HttpMethod.options) {
        return Response(
          headers: {
            'Access-Control-Allow-Origin': 'http://localhost:3000',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Max-Age': '86400',
          },
        );
      }

      // Обработка основного запроса
      final response = await handler(context);

      // Добавляем CORS headers
      return response.copyWith(
        headers: {
          ...response.headers,
          'Access-Control-Allow-Origin': 'http://localhost:3000',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        },
      );
    };
  };
}

// Основной router
Future<Response> _router(RequestContext context) async {
  final path = context.request.url.path;

  try {
    if (path == 'api/auth/login' && context.request.method == HttpMethod.post) {
      return _handleLogin(context);
    } else if (path == 'api/auth/register' && context.request.method == HttpMethod.post) {
      return _handleRegister(context);
    } else if (path == 'api/users' && context.request.method == HttpMethod.get) {
      return _handleGetUsers(context);
    } else if (path == 'api/training/plans' && context.request.method == HttpMethod.get) {
      return _handleGetTrainingPlans(context);
    } else if (path == 'api/schedule' && context.request.method == HttpMethod.get) {
      return _handleGetSchedule(context);
    } else {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Endpoint not found: $path'},
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error: $e'},
    );
  }
}

// Обработчики endpoints
Future<Response> _handleLogin(RequestContext context) async {
  // Здесь будет логика из routes/api/auth/login.dart
  return Response.json(body: {'message': 'Login endpoint'});
}

Future<Response> _handleRegister(RequestContext context) async {
  // Здесь будет логика из routes/api/auth/register.dart
  return Response.json(body: {'message': 'Register endpoint'});
}

Future<Response> _handleGetUsers(RequestContext context) async {
  // Здесь будет логика из routes/api/users/index.dart
  return Response.json(body: {'users': []});
}

Future<Response> _handleGetTrainingPlans(RequestContext context) async {
  // Здесь будет логика из routes/api/training/plans.dart
  return Response.json(body: {'plans': []});
}

Future<Response> _handleGetSchedule(RequestContext context) async {
  // Здесь будет логика из routes/api/schedule/index.dart
  return Response.json(body: {'schedule': []});
}