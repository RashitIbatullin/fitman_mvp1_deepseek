import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import '../controllers/auth_controller.dart';
import '../controllers/users_controller.dart';
import '../controllers/training_controller.dart';
import '../controllers/schedule_controller.dart';
import '../controllers/manager_controller.dart';
import '../controllers/instructor_controller.dart';
import '../middleware/auth_middleware.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/anthropometry_controller.dart';
import '../controllers/calorie_tracking_controller.dart';
import '../controllers/progress_controller.dart';

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

// Middleware для проверки роли 'manager' или 'admin'
Middleware _requireManagerOrAdmin() {
  return (Handler innerHandler) {
    return (Request request) {
      final user = request.context['user'] as Map<String, dynamic>?;
      final role = user?['role'] as String?;
      if (user == null || (role != 'manager' && role != 'admin')) {
        return Response.forbidden('{"error": "Manager or Admin access required"}');
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

Handler _managerHandler(Handler handler) {
  // Сначала аутентификация, потом проверка роли
  return requireAuth()(_requireManagerOrAdmin()(handler));
}

// Middleware для проверки роли 'instructor' или 'admin'
Middleware _requireInstructorOrAdmin() {
  return (Handler innerHandler) {
    return (Request request) {
      final user = request.context['user'] as Map<String, dynamic>?;
      final role = user?['role'] as String?;
      if (user == null || (role != 'instructor' && role != 'admin')) {
        return Response.forbidden('{"error": "Instructor or Admin access required"}');
      }
      return innerHandler(request);
    };
  };
}

Handler _instructorHandler(Handler handler) {
  // Сначала аутентификация, потом проверка роли
  return requireAuth()(_requireInstructorOrAdmin()(handler));
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
  ..post('/api/schedule', (Request request) => _trainerHandler(ScheduleController.createSchedule)(request))

// Manager routes
  ..get('/api/manager/clients', (Request request) => _managerHandler(ManagerController.getAssignedClients)(request))
  ..get('/api/manager/instructors', (Request request) => _managerHandler(ManagerController.getAssignedInstructors)(request))
  ..get('/api/manager/trainers', (Request request) => _managerHandler(ManagerController.getAssignedTrainers)(request))
  ..post('/api/managers/<id>/clients', (Request request, String id) => _adminHandler((Request req) => ManagerController.assignClients(req, id))(request))
  ..get('/api/managers/<id>/clients/ids', (Request request, String id) => _adminHandler((Request req) => ManagerController.getAssignedClientIds(req, id))(request))
  ..post('/api/managers/<id>/instructors', (Request request, String id) => _adminHandler((Request req) => ManagerController.assignInstructors(req, id))(request))
  ..get('/api/managers/<id>/instructors/ids', (Request request, String id) => _adminHandler((Request req) => ManagerController.getAssignedInstructorIds(req, id))(request))
  ..post('/api/managers/<id>/trainers', (Request request, String id) => _adminHandler((Request req) => ManagerController.assignTrainers(req, id))(request))
  ..get('/api/managers/<id>/trainers/ids', (Request request, String id) => _adminHandler((Request req) => ManagerController.getAssignedTrainerIds(req, id))(request))

// Instructor routes
  ..get('/api/instructor/clients', (Request request) => _instructorHandler(InstructorController.getAssignedClients)(request))
  ..get('/api/instructor/trainers', (Request request) => _instructorHandler(InstructorController.getAssignedTrainers)(request))
  ..get('/api/instructor/manager', (Request request) => _instructorHandler(InstructorController.getAssignedManager)(request))

// Dashboard routes
  ..get('/api/dashboard/client', (Request request) => _protectedHandler(DashboardController.getClientDashboardData)(request))

// Client routes
  ..get('/api/client/trainer', (Request request) => _protectedHandler(UsersController.getTrainerForClient)(request))
  ..get('/api/client/instructor', (Request request) => _protectedHandler(UsersController.getInstructorForClient)(request))
  ..get('/api/client/manager', (Request request) => _protectedHandler(UsersController.getManagerForClient)(request))
  ..get('/api/client/anthropometry', (Request request) => _protectedHandler(AnthropometryController.getAnthropometryDataForClient)(request))
  ..get('/api/client/calorie-tracking', (Request request) => _protectedHandler(CalorieTrackingController.getCalorieTrackingDataForClient)(request))
  ..get('/api/client/progress', (Request request) => _protectedHandler(ProgressController.getProgressDataForClient)(request));