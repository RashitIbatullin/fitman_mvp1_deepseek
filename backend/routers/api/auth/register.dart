import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../../../db/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  return _handleRegister(context);
}

Future<Response> _handleRegister(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final firstName = body['firstName'] as String?;
    final lastName = body['lastName'] as String?;
    final role = body['role'] as String? ?? 'client';

    if (email == null || password == null || firstName == null || lastName == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'All fields are required'},
      );
    }

    // Проверка существования пользователя
    final existingUser = await Database.connection.execute(
      'SELECT id FROM users WHERE email = @email',
      parameters: {'email': email},
    );

    if (existingUser.isNotEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'User already exists'},
      );
    }

    // Создание пользователя
    final result = await Database.connection.execute(
      '''
      INSERT INTO users (email, password_hash, first_name, last_name, role)
      VALUES (@email, @passwordHash, @firstName, @lastName, @role)
      RETURNING id, email, first_name, last_name, role, created_at
      ''',
    );

    final user = result.first;
    final userId = user[0] as int;
    final userEmail = user[1] as String;
    final userFirstName = user[2] as String;
    final userLastName = user[3] as String;
    final userRole = user[4] as String;

    // Генерация JWT токена
    final jwt = JWT(
      {
        'sub': userId.toString(),
        'role': userRole,
        'iss': 'fitman',
        'aud': ['fitman_app'],
      },
      issuer: 'fitman',
      subject: userId.toString(),
      audience: Audience(['fitman_app']),
    );

    final token = jwt.sign(
      SecretKey('fitman_secret_key_2024'),
      expiresIn: Duration(hours: 24),
    );

    return Response.json(
      statusCode: 201,
      body: {
        'message': 'User created successfully',
        'token': token,
        'user': {
          'id': userId,
          'email': userEmail,
          'firstName': userFirstName,
          'lastName': userLastName,
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