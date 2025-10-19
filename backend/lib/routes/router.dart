import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import '../controllers/auth_controller.dart';
import '../controllers/users_controller.dart';
import '../middleware/auth_middleware.dart';

// Создаем обертки для protected routes
Handler _protectedHandler(Handler handler) {
  return requireAuth()(handler);
}

Handler _adminHandler(Handler handler) {
  return (Request request) async {
    // Сначала проверяем аутентификацию
    final authResponse = await requireAuth()(handler)(request);
    if (authResponse.statusCode != 200) {
      return authResponse;
    }

    // Затем проверяем роль
    final user = request.context['user'] as Map<String, dynamic>?;
    if (user == null || user['role'] != 'admin') {
      return Response(403, body: '{"error": "Admin access required"}');
    }

    return handler(request);
  };
}

final Router router = Router()
// Public routes
  ..get('/api/health', (_) => Response.ok('{"status": "OK", "message": "FitMan Dart API"}'))
  ..post('/api/auth/login', AuthController.login)
  ..post('/api/auth/register', AuthController.register)

// Protected routes - применяем middleware через обертки
  ..get('/api/users', (Request request) => _adminHandler(UsersController.getUsers)(request))
  ..get('/api/users/<id>', (Request request, String id) => _protectedHandler((Request req) => UsersController.getUserById(req, id))(request))
  ..put('/api/users/<id>', (Request request, String id) => _protectedHandler((Request req) => UsersController.updateUser(req, id))(request))
  ..delete('/api/users/<id>', (Request request, String id) => _adminHandler((Request req) => UsersController.deleteUser(req, id))(request));