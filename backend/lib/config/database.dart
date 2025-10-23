import 'dart:async';

import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';

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
  
                                          // Загружаем переменные окружения
  
                                          final env = DotEnv()..load();
  
                              
  
                                          // Создаем Endpoint для подключения
  
                                          final endpoint = Endpoint(
  
                                            host: env['DB_HOST'] ?? 'localhost',
  
                                            port: int.tryParse(env['DB_PORT'] ?? '5432') ?? 5432,
  
                                            database: env['DB_NAME'] ?? 'fitman_mvp1_deepseek',
  
                                            username: env['DB_USER'] ?? 'postgres',
  
                                            password: env['DB_PASS'] ?? 'postgres',
  
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

  // Получить клиентов для менеджера
  Future<List<User>> getClientsForManager(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT u.* FROM users u
          INNER JOIN manager_clients mc ON u.id = mc.client_id
          WHERE mc.manager_id = @managerId
          ORDER BY u.last_name, u.first_name
        '''),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => User.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getClientsForManager error: $e');
      rethrow;
    }
  }

  // Назначить клиентов менеджеру
  Future<void> assignClientsToManager(int managerId, List<int> clientIds) async {
    final conn = await connection;
    await conn.execute('BEGIN');
    try {
      // Удаляем старые назначения
      await conn.execute(
        Sql.named('DELETE FROM manager_clients WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );

      // Добавляем новые назначения
      if (clientIds.isNotEmpty) {
        for (final clientId in clientIds) {
          await conn.execute(
            Sql.named('INSERT INTO manager_clients (manager_id, client_id) VALUES (@managerId, @clientId)'),
            parameters: {'managerId': managerId, 'clientId': clientId},
          );
        }
      }
      await conn.execute('COMMIT');
    } catch (e) {
      await conn.execute('ROLLBACK');
      print('❌ assignClientsToManager error: $e');
      rethrow;
    }
  }

  // Получить ID назначенных клиентов для менеджера
  Future<List<int>> getAssignedClientIds(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('SELECT client_id FROM manager_clients WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => row[0] as int).toList();
    } catch (e) {
      print('❌ getAssignedClientIds error: $e');
      rethrow;
    }
  }

  // Получить инструкторов для менеджера
  Future<List<User>> getInstructorsForManager(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT u.* FROM users u
          INNER JOIN manager_instructors mi ON u.id = mi.instructor_id
          WHERE mi.manager_id = @managerId AND u.role = 'instructor'
          ORDER BY u.last_name, u.first_name
        '''),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => User.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getInstructorsForManager error: $e');
      rethrow;
    }
  }

  // Получить тренеров для менеджера
  Future<List<User>> getTrainersForManager(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT u.* FROM users u
          INNER JOIN manager_trainers mt ON u.id = mt.trainer_id
          WHERE mt.manager_id = @managerId AND u.role = 'trainer'
          ORDER BY u.last_name, u.first_name
        '''),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => User.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getTrainersForManager error: $e');
      rethrow;
    }
  }

  // Назначить инструкторов менеджеру
  Future<void> assignInstructorsToManager(int managerId, List<int> instructorIds) async {
    final conn = await connection;
    await conn.execute('BEGIN');
    try {
      // Удаляем старые назначения
      await conn.execute(
        Sql.named('DELETE FROM manager_instructors WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );

      // Добавляем новые назначения
      if (instructorIds.isNotEmpty) {
        for (final instructorId in instructorIds) {
          await conn.execute(
            Sql.named('INSERT INTO manager_instructors (manager_id, instructor_id) VALUES (@managerId, @instructorId)'),
            parameters: {'managerId': managerId, 'instructorId': instructorId},
          );
        }
      }
      await conn.execute('COMMIT');
    } catch (e) {
      await conn.execute('ROLLBACK');
      print('❌ assignInstructorsToManager error: $e');
      rethrow;
    }
  }

  // Получить ID назначенных инструкторов для менеджера
  Future<List<int>> getAssignedInstructorIds(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('SELECT instructor_id FROM manager_instructors WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => row[0] as int).toList();
    } catch (e) {
      print('❌ getAssignedInstructorIds error: $e');
      rethrow;
    }
  }

  // Назначить тренеров менеджеру
  Future<void> assignTrainersToManager(int managerId, List<int> trainerIds) async {
    final conn = await connection;
    await conn.execute('BEGIN');
    try {
      // Удаляем старые назначения
      await conn.execute(
        Sql.named('DELETE FROM manager_trainers WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );

      // Добавляем новые назначения
      if (trainerIds.isNotEmpty) {
        for (final trainerId in trainerIds) {
          await conn.execute(
            Sql.named('INSERT INTO manager_trainers (manager_id, trainer_id) VALUES (@managerId, @trainerId)'),
            parameters: {'managerId': managerId, 'trainerId': trainerId},
          );
        }
      }
      await conn.execute('COMMIT');
    } catch (e) {
      await conn.execute('ROLLBACK');
      print('❌ assignTrainersToManager error: $e');
      rethrow;
    }
  }

  // Получить ID назначенных тренеров для менеджера
  Future<List<int>> getAssignedTrainerIds(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('SELECT trainer_id FROM manager_trainers WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => row[0] as int).toList();
    } catch (e) {
      print('❌ getAssignedTrainerIds error: $e');
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
          role VARCHAR(20) NOT NULL CHECK (role IN ('client', 'trainer', 'admin', 'manager')),
          phone VARCHAR(20),
          created_at TIMESTAMP DEFAULT NOW(),
          updated_at TIMESTAMP DEFAULT NOW()
        )
      ''');

      // Создаем таблицу профилей менеджеров
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS manager_profiles (
          user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
          specialization VARCHAR(255),
          work_experience INTEGER,
          is_duty BOOLEAN DEFAULT false
        )
      ''');

      // Создаем таблицу связей менеджер-клиент
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS manager_clients (
          manager_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          client_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          PRIMARY KEY (manager_id, client_id)
        )
      ''');

      // Создаем таблицу связей менеджер-инструктор
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS manager_instructors (
          manager_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          instructor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          PRIMARY KEY (manager_id, instructor_id)
        )
      ''');

      // Создаем таблицу связей менеджер-тренер
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS manager_trainers (
          manager_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          trainer_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          PRIMARY KEY (manager_id, trainer_id)
        )
      ''');

      // Создаем таблицу шаблонов упражнений
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS exercises_templates (
          id SERIAL PRIMARY KEY,
          name VARCHAR(100) NOT NULL,
          repeat_qty INTEGER,
          duration_exec REAL,
          duration_rest REAL,
          calories_out REAL,
          is_group BOOLEAN DEFAULT false,
          type_exercis_id INTEGER, -- Связь с каталогом типов упражнений
          note VARCHAR(255),
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