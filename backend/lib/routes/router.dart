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

// Middleware для проверки роли 'trainer' или 'admin'
Middleware _requireTrainerOrAdmin() {
  return (Handler innerHandler) {
    return (Request request) {
      final user = request.context['user'] as Map<String, dynamic>?;
      final role = user?['role'] as String?;
      if (user == null || (role != 'trainer' && role != 'admin')) {
        return Response.forbidden('{"error": "Trainer or Admin access required"}');
      }
      return innerHandler(request);
    };
  };
}

// Оборачиваем хендлеры в цепочку middleware
Handler _adminHandler(Handler handler) {
  // Сначала аутентификация, потом проверка роли
  return requireAuth()(requireRole('admin')(handler));
}

Handler _trainerHandler(Handler handler) {
  // Сначала аутентификация, потом проверка роли
  return requireAuth()(_requireTrainerOrAdmin()(handler));
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