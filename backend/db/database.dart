import 'package:postgres/postgres.dart';

class Database {
  static late Connection _connection;

  static Future<void> initialize() async {
    // Создаем Endpoint для подключения
    final endpoint = Endpoint(
      host: 'localhost',
      port: 5432,
      database: 'fitman_db',
      username: 'fitman_user',
      password: 'fitman_password',
    );

    // Открываем соединение через статический метод
    _connection = await Connection.open(endpoint);

    print('✅ Connected to PostgreSQL database');
    await _runMigrations();
  }

  static Future<void> _runMigrations() async {
    // Таблица пользователей
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id BIGSERIAL PRIMARY KEY,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        phone VARCHAR(20),
        role VARCHAR(20) NOT NULL DEFAULT 'client',
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW(),
        archived_at TIMESTAMP NULL,
        company_id BIGINT DEFAULT -1
      )
    ''');

    // Таблица планов тренировок
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS training_plan_templates (
        id BIGSERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        goal VARCHAR(50) NOT NULL,
        level VARCHAR(50) NOT NULL,
        exercises JSONB,
        created_by BIGINT REFERENCES users(id),
        created_at TIMESTAMP DEFAULT NOW(),
        company_id BIGINT DEFAULT -1
      )
    ''');

    // Таблица назначений планов клиентам
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS client_training_plans (
        id BIGSERIAL PRIMARY KEY,
        client_id BIGINT REFERENCES users(id) NOT NULL,
        training_plan_id BIGINT REFERENCES training_plan_templates(id) NOT NULL,
        assigned_by BIGINT REFERENCES users(id) NOT NULL,
        assigned_at TIMESTAMP DEFAULT NOW(),
        is_active BOOLEAN DEFAULT true,
        company_id BIGINT DEFAULT -1
      )
    ''');

    // Таблица расписания
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS schedule (
        id BIGSERIAL PRIMARY KEY,
        client_id BIGINT REFERENCES users(id) NOT NULL,
        trainer_id BIGINT REFERENCES users(id) NOT NULL,
        training_plan_id BIGINT REFERENCES training_plan_templates(id),
        start_time TIMESTAMP NOT NULL,
        end_time TIMESTAMP NOT NULL,
        status VARCHAR(20) DEFAULT 'scheduled',
        created_at TIMESTAMP DEFAULT NOW(),
        company_id BIGINT DEFAULT -1
      )
    ''');

    // Таблица занятий
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS lessons (
        id BIGSERIAL PRIMARY KEY,
        schedule_id BIGINT REFERENCES schedule(id) NOT NULL,
        client_id BIGINT REFERENCES users(id) NOT NULL,
        trainer_id BIGINT REFERENCES users(id) NOT NULL,
        start_fact_at TIMESTAMP,
        finish_fact_at TIMESTAMP,
        complete VARCHAR(20) DEFAULT 'scheduled',
        note TEXT,
        calories_spent REAL,
        created_at TIMESTAMP DEFAULT NOW(),
        company_id BIGINT DEFAULT -1
      )
    ''');

    // Таблица учета калорий
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS track_calories (
        id BIGSERIAL PRIMARY KEY,
        client_id BIGINT REFERENCES users(id) NOT NULL,
        lesson_id BIGINT REFERENCES lessons(id),
        weight DOUBLE PRECISION,
        calories_in REAL,
        calories_out REAL,
        measured_at TIMESTAMP DEFAULT NOW(),
        created_at TIMESTAMP DEFAULT NOW(),
        company_id BIGINT DEFAULT -1
      )
    ''');

    // Таблица сообщений чата
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        id BIGSERIAL PRIMARY KEY,
        sender_id BIGINT REFERENCES users(id) NOT NULL,
        receiver_id BIGINT REFERENCES users(id) NOT NULL,
        message TEXT NOT NULL,
        sent_at TIMESTAMP DEFAULT NOW(),
        read_at TIMESTAMP NULL,
        company_id BIGINT DEFAULT -1
      )
    ''');

    // Создание индексов
    await _createIndexes();

    // Создание тестовых данных
    await _createTestData();
  }

  static Future<void> _createIndexes() async {
    final indexes = [
      'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)',
      'CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)',
      'CREATE INDEX IF NOT EXISTS idx_schedule_client ON schedule(client_id)',
      'CREATE INDEX IF NOT EXISTS idx_schedule_trainer ON schedule(trainer_id)',
      'CREATE INDEX IF NOT EXISTS idx_chat_messages_users ON chat_messages(sender_id, receiver_id)',
      'CREATE INDEX IF NOT EXISTS idx_client_plans ON client_training_plans(client_id, is_active)',
    ];

    for (final index in indexes) {
      await _connection.execute(index);
    }
    print('✅ Database indexes created');
  }

  static Future<void> _createTestData() async {
    // Проверяем, есть ли уже данные
    final usersCount = await _connection.execute('SELECT COUNT(*) FROM users');
    if (usersCount.isNotEmpty && (usersCount.first[0] as int) > 0) {
      print('✅ Test data already exists');
      return;
    }

    print('📝 Creating test data...');

    // Создаем тестового администратора
    await _connection.execute('''
      INSERT INTO users (email, password_hash, first_name, last_name, role)
      VALUES ('admin@fitman.ru', 'admin123', 'Администратор', 'Системы', 'admin')
    ''');

    // Создаем тестового тренера
    final trainerResult = await _connection.execute('''
      INSERT INTO users (email, password_hash, first_name, last_name, role)
      VALUES ('trainer@fitman.ru', 'trainer123', 'Иван', 'Тренеров', 'trainer')
      RETURNING id
    ''');

    final trainerId = trainerResult.first[0] as int;

    // Создаем тестового клиента
    await _connection.execute('''
      INSERT INTO users (email, password_hash, first_name, last_name, role)
      VALUES ('client@fitman.ru', 'client123', 'Алексей', 'Клиентов', 'client')
    ''');

    // Создаем тестовые планы тренировок
    await _connection.execute('''
      INSERT INTO training_plan_templates (name, description, goal, level, exercises, created_by)
      VALUES 
      ('Похудение для начинающих', 'Базовые упражнения для снижения веса', 'weight_loss', 'beginner', @exercises1, @trainerId),
      ('Набор мышечной массы', 'Силовые тренировки для роста мышц', 'muscle_gain', 'intermediate', @exercises2, @trainerId)
    ''', parameters: {
      'exercises1': '{"exercises": [{"name": "Бег", "duration": 30}, {"name": "Приседания", "reps": 15}]}',
      'exercises2': '{"exercises": [{"name": "Жим лежа", "reps": 10}, {"name": "Становая тяга", "reps": 8}]}',
      'trainerId': trainerId,
    });

    print('✅ Test data created successfully');
    print('👤 Test users:');
    print('   Admin: admin@fitman.ru / admin123');
    print('   Trainer: trainer@fitman.ru / trainer123');
    print('   Client: client@fitman.ru / client123');
  }

  static Connection get connection => _connection;
}