import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../../../db/database.dart';


Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  return _handleLogin(context);
}

Future<Response> _handleLogin(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (email == null || password == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Email and password are required'},
      );
    }

    // Поиск пользователя
    final result = await Database.connection.execute(
      'SELECT * FROM users WHERE email = @email AND archived_at IS NULL',
      parameters: {'email': email},
    );

    if (result.isEmpty) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Invalid credentials'},
      );
    }

    final user = result.first;
    // Структура: [id, email, password_hash, first_name, last_name, phone, role, created_at, updated_at, archived_at, company_id]
    final userId = user[0] as int;
    final passwordHash = user[2] as String;
    final userRole = user[6] as String;
    final firstName = user[3] as String;
    final lastName = user[4] as String;

    // Простая проверка пароля
    if (password != passwordHash) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Invalid credentials'},
      );
    }

    // Генерация JWT токена
    final token = _generateToken(userId, userRole);

    return Response.json(
      body: {
        'token': token,
        'user': {
          'id': userId,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'role': userRole,
        },
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error: $e'},
    );
  }
}

String _generateToken(int userId, String role) {
  final jwt = JWT(
    {
      'sub': userId.toString(),
      'role': role,
      'iss': 'fitman',
      'aud': ['fitman_app'],
    },
    issuer: 'fitman',
    subject: userId.toString(),
    audience: Audience(['fitman_app']),
  );

  return jwt.sign(
    SecretKey('fitman_secret_key_2024'),
    expiresIn: Duration(hours: 24),
  );
}