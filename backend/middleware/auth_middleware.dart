import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthUser {
  final int id;
  final String role;

  AuthUser({required this.id, required this.role});
}

Future<AuthUser> requireUser(RequestContext context) async {
  final authHeader = context.request.headers['authorization'];

  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    throw AuthException('Authentication required');
  }

  final token = authHeader.substring(7);

  try {
    // Верификация токена с dart_jsonwebtoken
    final jwt = JWT.verify(
      token,
      SecretKey('fitman_secret_key_2024'),
      audience: Audience(['fitman_app']),
      issuer: 'fitman',
    );

    final payload = jwt.payload as Map<String, dynamic>;
    final userId = int.parse(payload['sub'] as String); // ⬅️ Парсим строку в int
    final role = payload['role'] as String;

    return AuthUser(id: userId, role: role);
  } catch (e) {
    throw AuthException('Invalid token: $e');
  }
}