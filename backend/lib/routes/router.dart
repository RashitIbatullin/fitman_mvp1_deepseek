import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import '../controllers/auth_controller.dart';
import '../controllers/users_controller.dart';
import '../controllers/training_controller.dart';
import '../controllers/schedule_controller.dart';
import '../middleware/auth_middleware.dart';

// Создаем обертки для protected routes
Handler _protectedHandler(Handler handler) {
  return requireAuth()(handler);
}

Handler _adminHandler(Handler handler) {
  return (Request request) async {
    final authResponse = await requireAuth()(handler)(request);
    if (authResponse.statusCode != 200) {
      return authResponse;
    }

    final user = request.context['user'] as Map<String, dynamic>?;
    if (user == null || user['role'] != 'admin') {
      return Response(403, body: '{"error": "Admin access required"}');
    }

    return handler(request);
  };
}

Handler _trainerHandler(Handler handler) {
  return (Request request) async {
    final authResponse = await requireAuth()(handler)(request);
    if (authResponse.statusCode != 200) {
      return authResponse;
    }

    final user = request.context['user'] as Map<String, dynamic>?;
    if (user == null || (user['role'] != 'trainer' && user['role'] != 'admin')) {
      return Response(403, body: '{"error": "Trainer access required"}');
    }

    return handler(request);
  };
}

// Создаем и экспортируем роутер
final Router router = Router()
// Public routes
  ..get('/api/health', (_) => Response.ok('{"status": "OK", "message": "FitMan Dart API MVP1"}'))
  ..post('/api/auth/login', AuthController.login)
  ..post('/api/auth/register', AuthController.register)

// Protected routes - общие
  ..get('/api/auth/check', (Request request) => _protectedHandler(AuthController.checkAuth)(request))
  ..get('/api/profile', (Request request) => _protectedHandler(UsersController.getProfile)(request))

// User management routes (только для админа)
  ..get('/api/users', (Request request) => _adminHandler(UsersController.getUsers)(request))
  ..post('/api/users', (Request request) => _adminHandler(UsersController.createUser)(request))
  ..get('/api/users/<id>', (Request request, String id) => _protectedHandler((Request req) => UsersController.getUserById(req, id))(request))
  ..put('/api/users/<id>', (Request request, String id) => _protectedHandler((Request req) => UsersController.updateUser(req, id))(request))
  ..delete('/api/users/<id>', (Request request, String id) => _adminHandler((Request req) => UsersController.deleteUser(req, id))(request))

// Training routes
  ..get('/api/training/plans', (Request request) => _protectedHandler(TrainingController.getTrainingPlans)(request))
  ..get('/api/training/exercises', (Request request) => _protectedHandler(TrainingController.getExercises)(request))

// Schedule routes
  ..get('/api/schedule', (Request request) => _protectedHandler(ScheduleController.getSchedule)(request))
  ..post('/api/schedule', (Request request) => _trainerHandler(ScheduleController.createSchedule)(request));