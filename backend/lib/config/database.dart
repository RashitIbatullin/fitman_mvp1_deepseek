import 'dart:async';

import 'package:postgres/postgres.dart';

import '../models/user_back.dart';

class Database {
  static final Database _instance = Database._internal();
  factory Database() => _instance;
  Database._internal();

  Connection? _connection;
  bool _isConnecting = false;
  Completer<void>? _connectionCompleter;

  Future<Connection> get connection async {
    if (_connection != null) {
      return _connection!;
    }

    if (_isConnecting && _connectionCompleter != null) {
      await _connectionCompleter!.future;
      return _connection!;
    }

    await connect();
    return _connection!;
  }

  Future<void> connect() async {
    if (_connection != null) return;

    _isConnecting = true;
    _connectionCompleter = Completer<void>();

    try {
      // Создаем Endpoint для подключения
      final endpoint = Endpoint(
        host: 'localhost',
        port: 5432,
        database: 'fitman_mvp1_deepseek',
        username: 'postgres',
        password: 'postgres',
      );

      print('🔄 Connecting to PostgreSQL database...');
      // Открываем соединение через статический метод
      _connection = await Connection.open(endpoint, settings: ConnectionSettings(sslMode: SslMode.disable));
      print('✅ Connected to PostgreSQL database');

      _connectionCompleter!.complete();
    } catch (e) {
      print('❌ Database connection error: $e');
      _connectionCompleter!.completeError(e);
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
    _connectionCompleter = null;
  }

  // === USER METHODS ===

  // Получить всех пользователей
  Future<List<User>> getAllUsers() async {
    try {
      final conn = await connection;
      final results = await conn.execute('''
        SELECT id, email, password_hash, first_name, last_name, role, phone, created_at, updated_at 
        FROM users 
        ORDER BY created_at DESC
      ''');

      return results.map((row) => User.fromMap({
        'id': row[0],
        'email': row[1],
        'password_hash': row[2],
        'first_name': row[3],
        'last_name': row[4],
        'role': row[5],
        'phone': row[6],
        'created_at': row[7],
        'updated_at': row[8],
      })).toList();
    } catch (e) {
      print('❌ getAllUsers error: $e');
      rethrow;
    }
  }

  // Получить пользователя по email
  Future<User?> getUserByEmail(String email) async {
    try {
      final conn = await connection;

      final sql = '''
        SELECT id, email, password_hash, first_name, last_name, role, phone, created_at, updated_at 
        FROM users 
        WHERE email = @email
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'email': email,
        },
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return User.fromMap({
        'id': row[0],
        'email': row[1],
        'password_hash': row[2],
        'first_name': row[3],
        'last_name': row[4],
        'role': row[5],
        'phone': row[6],
        'created_at': row[7],
        'updated_at': row[8],
      });
    } catch (e) {
      print('❌ getUserByEmail error: $e');
      rethrow;
    }
  }

  // Получить пользователя по ID
  Future<User?> getUserById(int id) async {
    try {
      final conn = await connection;

      final sql = '''
        SELECT id, email, password_hash, first_name, last_name, role, phone, created_at, updated_at 
        FROM users 
        WHERE id = @id
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'id': id,
        },
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return User.fromMap({
        'id': row[0],
        'email': row[1],
        'password_hash': row[2],
        'first_name': row[3],
        'last_name': row[4],
        'role': row[5],
        'phone': row[6],
        'created_at': row[7],
        'updated_at': row[8],
      });
    } catch (e) {
      print('❌ getUserById error: $e');
      rethrow;
    }
  }

  // Создать пользователя
  Future<User> createUser(User user) async {
    try {
      final conn = await connection;

      final sql = '''
        INSERT INTO users (email, password_hash, first_name, last_name, role, phone, created_at, updated_at)
        VALUES (@email, @password_hash, @first_name, @last_name, @role, @phone, @created_at, @updated_at)
        RETURNING id, email, password_hash, first_name, last_name, role, phone, created_at, updated_at
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'email': user.email,
          'password_hash': user.passwordHash,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'role': user.role,
          'phone': user.phone,
          'created_at': user.createdAt,
          'updated_at': user.updatedAt,
        },
      );

      final row = results.first;
      return User.fromMap({
        'id': row[0],
        'email': row[1],
        'password_hash': row[2],
        'first_name': row[3],
        'last_name': row[4],
        'role': row[5],
        'phone': row[6],
        'created_at': row[7],
        'updated_at': row[8],
      });
    } catch (e) {
      print('❌ createUser error: $e');
      rethrow;
    }
  }

  // Обновить пользователя
  Future<User?> updateUser(
      int id, {
        String? firstName,
        String? lastName,
        String? phone,
      }) async {
    try {
      final conn = await connection;

      // Получаем текущего пользователя
      final currentUser = await getUserById(id);
      if (currentUser == null) return null;

      // Строим динамический запрос
      final updates = <String, dynamic>{};
      final setParts = <String>[];

      if (firstName != null) {
        updates['first_name'] = firstName;
        setParts.add('first_name = @first_name');
      }
      if (lastName != null) {
        updates['last_name'] = lastName;
        setParts.add('last_name = @last_name');
      }
      if (phone != null) {
        updates['phone'] = phone;
        setParts.add('phone = @phone');
      }

      if (setParts.isEmpty) {
        return currentUser;
      }

      updates['updated_at'] = DateTime.now();
      setParts.add('updated_at = @updated_at');

      updates['id'] = id;

      final sql = '''
        UPDATE users 
        SET ${setParts.join(', ')}
        WHERE id = @id
        RETURNING id, email, password_hash, first_name, last_name, role, phone, created_at, updated_at
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: updates,
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return User.fromMap({
        'id': row[0],
        'email': row[1],
        'password_hash': row[2],
        'first_name': row[3],
        'last_name': row[4],
        'role': row[5],
        'phone': row[6],
        'created_at': row[7],
        'updated_at': row[8],
      });
    } catch (e) {
      print('❌ updateUser error: $e');
      rethrow;
    }
  }

  // Удалить пользователя
  Future<bool> deleteUser(int id) async {
    try {
      final conn = await connection;

      final sql = '''
        DELETE FROM users 
        WHERE id = @id
        RETURNING id
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'id': id,
        },
      );

      return results.isNotEmpty;
    } catch (e) {
      print('❌ deleteUser error: $e');
      rethrow;
    }
  }

  // Инициализация базы данных (создание таблиц если не существуют)
  Future<void> initializeDatabase() async {
    try {
      final conn = await connection;

      // Создаем таблицу users если не существует
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          email VARCHAR(255) UNIQUE NOT NULL,
          password_hash VARCHAR(255) NOT NULL,
          first_name VARCHAR(100) NOT NULL,
          last_name VARCHAR(100) NOT NULL,
          role VARCHAR(20) NOT NULL CHECK (role IN ('client', 'trainer', 'admin')),
          phone VARCHAR(20),
          created_at TIMESTAMP DEFAULT NOW(),
          updated_at TIMESTAMP DEFAULT NOW()
        )
      ''');

      print('✅ Database tables initialized');
    } catch (e) {
      print('❌ Database initialization error: $e');
      rethrow;
    }
  }
}