import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/database.dart';
import '../models/user.dart';

class AuthController {
  static final String _jwtSecret = 'fitman-super-secret-key-2024';

  static Future<Response> login(Request request) async {
    try {
      final body = await request.readAsString();
      print('📨 Login request body: $body');

      final data = jsonDecode(body) as Map<String, dynamic>;

      final email = data['email'] as String;
      final password = data['password'] as String;

      print('🔍 Searching user with email: $email');

      // Находим пользователя в базе
      final user = await Database().getUserByEmail(email);
      print('📊 User found: ${user != null}');

      if (user == null) {
        print('❌ User not found for email: $email');
        return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
      }

      // Проверяем пароль
      print('🔐 Checking password...');
      //final isValidPassword = BCrypt.checkpw(password, user.passwordHash);
      final isValidPassword = password == user.passwordHash;
      print('✅ Password valid: $isValidPassword');

      if (!isValidPassword) {
        print('❌ Invalid password for user: $email');
        return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
      }

      // Генерируем JWT токен
      print('🎫 Generating JWT token...');
      final token = _generateJwtToken(user);
      print('✅ Token generated successfully');

      final response = {
        'token': token,
        'user': user.toSafeJson()
      };

      print('📤 Sending response: ${jsonEncode(response)}');

      return Response.ok(jsonEncode(response));

    } catch (e, stackTrace) {
      print('💥 LOGIN ERROR: $e');
      print('📋 Stack trace: $stackTrace');
      return Response(500, body: jsonEncode({'error': 'Internal server error: $e'}));
    }
  }

  static Future<Response> register(Request request) async {
    try {
      final body = await request.readAsString();
      print('📨 Register request body: $body');

      final data = jsonDecode(body) as Map<String, dynamic>;

      final email = data['email'] as String;
      final password = data['password'] as String;
      final firstName = data['firstName'] as String;
      final lastName = data['lastName'] as String;
      final role = data['role'] as String? ?? 'client';

      print('🔍 Checking if user exists: $email');

      // Проверяем существует ли пользователь
      final existingUser = await Database().getUserByEmail(email);
      if (existingUser != null) {
        print('❌ User already exists: $email');
        return Response(400, body: jsonEncode({'error': 'User already exists'}));
      }

      // Хешируем пароль
      print('🔐 Hashing password...');
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
      print('✅ Password hashed');

      // Создаем пользователя
      print('👤 Creating user...');
      final newUser = User(
        id: 0, // БД сама назначит ID
        email: email,
        passwordHash: passwordHash,
        firstName: firstName,
        lastName: lastName,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdUser = await Database().createUser(newUser);
      print('✅ User created with ID: ${createdUser.id}');

      final token = _generateJwtToken(createdUser);
      print('🎫 JWT token generated');

      final response = {
        'token': token,
        'user': createdUser.toSafeJson()
      };

      print('📤 Sending register response');
      return Response(201, body: jsonEncode(response));

    } catch (e, stackTrace) {
      print('💥 REGISTER ERROR: $e');
      print('📋 Stack trace: $stackTrace');
      return Response(500, body: jsonEncode({'error': 'Internal server error: $e'}));
    }
  }

  static String _generateJwtToken(User user) {
    final jwt = JWT({
      'userId': user.id,
      'email': user.email,
      'role': user.role,
      'exp': DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch,
    });

    return jwt.sign(SecretKey(_jwtSecret));
  }

  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      return jwt.payload;
    } catch (e) {
      return null;
    }
  }
}