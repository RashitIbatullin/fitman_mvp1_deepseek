import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/database.dart';
import '../config/app_config.dart';
import '../models/user_back.dart';

class AuthController {
  static Future<Response> login(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final email = data['email'] as String;
      final password = data['password'] as String;

      print('🔐 Login attempt for: $email');

      // Валидация email
      if (!AppConfig.isValidEmail(email)) {
        return Response(400, body: jsonEncode({'error': 'Invalid email format'}));
      }

      final user = await Database().getUserByEmail(email);

      if (user == null) {
        print('❌ User not found: $email');
        return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
      }

      print('📊 User found: ${user.email}');
      print('🔑 Stored hash: ${user.passwordHash}');
      print('🔑 Hash length: ${user.passwordHash.length}');

      // Отладочная информация
      print('=== DEBUG INFO ===');
      print('Input password: $password');
      print('Stored hash: ${user.passwordHash}');
      print('Hash starts with: ${user.passwordHash.substring(0, 7)}');
      print('Hash length: ${user.passwordHash.length}');

      final isValidPassword = BCrypt.checkpw(password, user.passwordHash);

      print('Password valid: $isValidPassword');

      if (!isValidPassword) {
        print('❌ Invalid password for user: $email');

        // Дополнительная проверка - попробуем сгенерировать хеш и сравнить
        final testHash = BCrypt.hashpw(password, BCrypt.gensalt());
        print('Test hash for comparison: $testHash');

        return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
      }

      final token = _generateJwtToken(user);
      final response = {
        'token': token,
        'user': user.toSafeJson()
      };

      print('✅ Login successful for: $email');
      return Response.ok(jsonEncode(response));
    } catch (e) {
      print('💥 Login error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error: $e'}));
    }
  }

  static Future<Response> register(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final email = data['email'] as String;
      final password = data['password'] as String;
      final firstName = data['firstName'] as String;
      final lastName = data['lastName'] as String;
      final role = data['role'] as String? ?? 'client';

      // Валидация данных
      if (!AppConfig.isValidEmail(email)) {
        return Response(400, body: jsonEncode({'error': 'Invalid email format'}));
      }

      if (!AppConfig.isValidPassword(password)) {
        return Response(400, body: jsonEncode({'error': 'Password must be at least ${AppConfig.minPasswordLength} characters'}));
      }

      if (!AppConfig.isValidRole(role)) {
        return Response(400, body: jsonEncode({'error': 'Invalid role. Allowed roles: ${AppConfig.allowedRoles.join(', ')}'}));
      }

      final existingUser = await Database().getUserByEmail(email);
      if (existingUser != null) {
        return Response(400, body: jsonEncode({'error': 'User already exists'}));
      }

      // ИСПРАВЛЕННАЯ СТРОКА: используем стандартный gensalt() без параметров
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      final newUser = User(
        id: 0,
        email: email,
        passwordHash: passwordHash,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phone: data['phone'] as String?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdUser = await Database().createUser(newUser);
      final token = _generateJwtToken(createdUser);

      final response = {
        'token': token,
        'user': createdUser.toSafeJson()
      };

      return Response(201, body: jsonEncode(response));
    } catch (e) {
      return Response(500, body: jsonEncode({'error': 'Internal server error: $e'}));
    }
  }

  static String _generateJwtToken(User user) {
    final jwt = JWT({
      'userId': user.id,
      'email': user.email,
      'role': user.role,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'exp': (DateTime.now().add(Duration(hours: AppConfig.jwtExpiryHours)).millisecondsSinceEpoch / 1000).round(),
    });

    return jwt.sign(SecretKey(AppConfig.jwtSecret));
  }

  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(AppConfig.jwtSecret));
      return jwt.payload;
    } catch (e) {
      return null;
    }
  }

  static Future<Response> checkAuth(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      return Response.ok(jsonEncode({
        'authenticated': true,
        'user': user
      }));
    } catch (e) {
      return Response(500, body: jsonEncode({'error': 'Internal server error: $e'}));
    }
  }
}