import 'package:shelf/shelf.dart';
import '../controllers/auth_controller.dart';

Middleware requireAuth() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401, body: '{"error": "Authentication required"}');
      }

      final token = authHeader.substring(7);
      final payload = AuthController.verifyToken(token);

      if (payload == null) {
        return Response(401, body: '{"error": "Invalid or expired token"}');
      }

      // Добавляем данные пользователя в request
      final updatedRequest = request.change(
          context: {'user': payload}
      );

      return innerHandler(updatedRequest);
    };
  };
}

Middleware requireRole(String role) {
  return (Handler innerHandler) {
    return (Request request) async {
      final user = request.context['user'] as Map<String, dynamic>?;

      if (user == null || user['role'] != role) {
        return Response(403, body: '{"error": "Insufficient permissions"}');
      }

      return innerHandler(request);
    };
  };
}