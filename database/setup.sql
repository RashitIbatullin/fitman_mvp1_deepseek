-- Удаление старых таблиц, если они существуют, для идемпотентности скрипта
DROP TABLE IF EXISTS
    users,
    roles,
    user_roles,
    user_settings,
    client_profiles,
    instructor_profiles,
    trainer_profiles,
    manager_profiles,
    goals_training,
    levels_training,
    work_schedules,
    client_schedule_preferences
CASCADE;

-- Общие требования к таблицам:
-- - id (BIGSERIAL PRIMARY KEY)
-- - company_id (BIGINT DEFAULT -1)
-- - created_at, updated_at (TIMESTAMPTZ)
-- - created_by, updated_by (BIGINT FK -> users(id))
-- - archived_at, archived_by (TIMESTAMPTZ, BIGINT FK -> users(id))

-- 1. Таблица ролей
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    icon VARCHAR(255),
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT,
    updated_by BIGINT,
    archived_at TIMESTAMPTZ,
    archived_by BIGINT
);

-- Начальные значения для ролей
INSERT INTO roles (name, title) VALUES
    ('client', 'Клиент'),
    ('instructor', 'Инструктор'),
    ('trainer', 'Тренер'),
    ('manager', 'Менеджер'),
    ('admin', 'Администратор');

-- 2. Основная таблица пользователей
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    login VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(255) UNIQUE,
    last_name VARCHAR(255),
    first_name VARCHAR(255),
    middle_name VARCHAR(255),
    gender SMALLINT,
    age INTEGER,
    photo_url VARCHAR(255),
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT,
    updated_by BIGINT,
    archived_at TIMESTAMPTZ,
    archived_by BIGINT
);

-- Добавление FK для created_by и updated_by после создания таблицы users
-- Это позволяет избежать циклической зависимости при создании
ALTER TABLE roles ADD CONSTRAINT fk_roles_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE roles ADD CONSTRAINT fk_roles_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE roles ADD CONSTRAINT fk_roles_archived_by FOREIGN KEY (archived_by) REFERENCES users(id);

ALTER TABLE users ADD CONSTRAINT fk_users_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE users ADD CONSTRAINT fk_users_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE users ADD CONSTRAINT fk_users_archived_by FOREIGN KEY (archived_by) REFERENCES users(id);


-- 3. Связующая таблица пользователи-роли
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id),
    PRIMARY KEY (user_id, role_id)
);

-- 4. Таблица настроек пользователя
CREATE TABLE user_settings (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    send_notifications BOOLEAN DEFAULT true,
    hour_notification INTEGER DEFAULT 2,
    notification_email BOOLEAN DEFAULT true,
    notification_push BOOLEAN DEFAULT true,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);

-- 5. Вспомогательные каталоги для профилей
CREATE TABLE goals_training (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);
INSERT INTO goals_training (name) VALUES ('Похудение'), ('Набор массы');

CREATE TABLE levels_training (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);
INSERT INTO levels_training (name) VALUES ('Начальный'), ('Продвинутый'), ('Экспертный');


-- 6. Таблицы профилей для ролей
CREATE TABLE client_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    goal_training_id BIGINT REFERENCES goals_training(id),
    level_training_id BIGINT REFERENCES levels_training(id),
    track_calories BOOLEAN DEFAULT true,
    coeff_activity DOUBLE PRECISION DEFAULT 1.2,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);

CREATE TABLE instructor_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    specialization VARCHAR(255),
    work_experience INTEGER,
    is_duty BOOLEAN DEFAULT false,
    can_replace_trainer BOOLEAN DEFAULT false,
    can_create_plan BOOLEAN DEFAULT false,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);

CREATE TABLE trainer_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    specialization VARCHAR(255),
    work_experience INTEGER,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);

CREATE TABLE manager_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    specialization VARCHAR(255),
    work_experience INTEGER,
    is_duty BOOLEAN DEFAULT false,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);

-- 7. Создание начальных пользователей для каждой роли
-- Logins/emails и пароли взяты из frontend/lib/screens/login_screen.dart
-- Хеши сгенерированы с помощью bcrypt для соответствующих паролей.
DO $$
DECLARE
    admin_id BIGINT;
    manager_id BIGINT;
    trainer_id BIGINT;
    instructor_id BIGINT;
    client_id BIGINT;
    admin_role_id BIGINT;
    manager_role_id BIGINT;
    trainer_role_id BIGINT;
    instructor_role_id BIGINT;
    client_role_id BIGINT;
BEGIN
    -- Получаем ID ролей
    SELECT id INTO admin_role_id FROM roles WHERE name = 'admin';
    SELECT id INTO manager_role_id FROM roles WHERE name = 'manager';
    SELECT id INTO trainer_role_id FROM roles WHERE name = 'trainer';
    SELECT id INTO instructor_role_id FROM roles WHERE name = 'instructor';
    SELECT id INTO client_role_id FROM roles WHERE name = 'client';

    -- Создание Администратора (пароль: admin123)
    INSERT INTO users (login, password_hash, email, last_name, first_name, gender, age)
    VALUES ('admin@fitman.ru', '$2a$10$RATHndPnw7mQZOOfAb3RHeaGhV8Aul2U4BXx2C94pDr4EqV58uEUW', 'admin@fitman.ru', 'Администратор', 'Админ', 1, 30)
    RETURNING id INTO admin_id;
    INSERT INTO user_roles (user_id, role_id, created_by, updated_by) VALUES (admin_id, admin_role_id, admin_id, admin_id);
    
    -- Устанавливаем created_by/updated_by для самого первого пользователя и справочников
    UPDATE users SET created_by = admin_id, updated_by = admin_id WHERE id = admin_id;
    UPDATE roles SET created_by = admin_id, updated_by = admin_id;
    UPDATE goals_training SET created_by = admin_id, updated_by = admin_id;
    UPDATE levels_training SET created_by = admin_id, updated_by = admin_id;

    -- Создание Менеджера (пароль: manager123)
    INSERT INTO users (login, password_hash, email, last_name, first_name, gender, age, created_by, updated_by)
    VALUES ('manager@fitman.ru', '$2a$10$gH1uvOKi0oiI4nwhiapDgeKZjHx2Oo0OiojVABKYL5DWBaxOAKDWa', 'manager@fitman.ru', 'Менеджеров', 'Менеджер', 1, 28, admin_id, admin_id)
    RETURNING id INTO manager_id;
    INSERT INTO user_roles (user_id, role_id, created_by, updated_by) VALUES (manager_id, manager_role_id, admin_id, admin_id);
    INSERT INTO manager_profiles (user_id, specialization, work_experience, created_by, updated_by) VALUES (manager_id, 'Управление', 3, admin_id, admin_id);

    -- Создание Тренера (пароль: trainer123)
    INSERT INTO users (login, password_hash, email, last_name, first_name, gender, age, created_by, updated_by)
    VALUES ('trainer@fitman.ru', '$2a$10$eMnEUxZ5YndkG8KJjfrDrugj0UbvaoRkBeopAVnzWgo18kmQIs6PG', 'trainer@fitman.ru', 'Тренеров', 'Тренер', 1, 25, admin_id, admin_id)
    RETURNING id INTO trainer_id;
    INSERT INTO user_roles (user_id, role_id, created_by, updated_by) VALUES (trainer_id, trainer_role_id, admin_id, admin_id);
    INSERT INTO trainer_profiles (user_id, specialization, work_experience, created_by, updated_by) VALUES (trainer_id, 'Силовой тренинг', 5, admin_id, admin_id);

    -- Создание Инструктора (пароль: instructor123)
    INSERT INTO users (login, password_hash, email, last_name, first_name, gender, age, created_by, updated_by)
    VALUES ('instructor@fitman.ru', '$2a$10$zo5j5Qm0OJAZkiwVWfIHyeSSs831kV95YsNIK0/8/rlm3WvXxY6Mi', 'instructor@fitman.ru', 'Инструкторов', 'Инструктор', 2, 22, admin_id, admin_id)
    RETURNING id INTO instructor_id;
    INSERT INTO user_roles (user_id, role_id, created_by, updated_by) VALUES (instructor_id, instructor_role_id, admin_id, admin_id);
    INSERT INTO instructor_profiles (user_id, specialization, work_experience, created_by, updated_by) VALUES (instructor_id, 'Групповые занятия', 2, admin_id, admin_id);

    -- Создание Клиента (пароль: client123)
    INSERT INTO users (login, password_hash, email, last_name, first_name, gender, age, created_by, updated_by)
    VALUES ('client@fitman.ru', '$2a$10$Ho/wfV6sIt9DetDJ3.NQY.u7lMnKUGpfzZO0Qc5rzs/2UskxxDLoW', 'client@fitman.ru', 'Клиентов', 'Клиент', 2, 29, admin_id, admin_id)
    RETURNING id INTO client_id;
    INSERT INTO user_roles (user_id, role_id, created_by, updated_by) VALUES (client_id, client_role_id, admin_id, admin_id);
    INSERT INTO client_profiles (user_id, goal_training_id, level_training_id, created_by, updated_by) VALUES (client_id, 1, 1, admin_id, admin_id);
    INSERT INTO user_settings (user_id, created_by, updated_by) VALUES (client_id, admin_id, admin_id);

-- Создание таблицы work_schedules
CREATE TABLE work_schedules (
    id BIGSERIAL PRIMARY KEY,
    day_of_week INT NOT NULL UNIQUE,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_day_off BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by BIGINT,
    updated_by BIGINT,
    archived_at TIMESTAMP WITH TIME ZONE,
    archived_by BIGINT,
    company_id BIGINT DEFAULT -1
);

COMMENT ON TABLE work_schedules IS 'Расписание работы центра';

-- Вставка начальных данных в work_schedules
INSERT INTO work_schedules (day_of_week, start_time, end_time, is_day_off) VALUES
(1, '09:00', '21:00', false),
(2, '09:00', '21:00', false),
(3, '09:00', '21:00', false),
(4, '09:00', '21:00', false),
(5, '09:00', '21:00', false),
(6, '09:00', '21:00', false),
(7, '09:00', '21:00', false);

-- Создание таблицы client_schedule_preferences
CREATE TABLE client_schedule_preferences (
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL REFERENCES users(id),
    day_of_week INT NOT NULL,
    preferred_start_time TIME NOT NULL,
    preferred_end_time TIME NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by BIGINT,
    updated_by BIGINT,
    archived_at TIMESTAMP WITH TIME ZONE,
    archived_by BIGINT,
    company_id BIGINT DEFAULT -1,
    UNIQUE (client_id, day_of_week) -- A client can only have one preference per day
);

COMMENT ON TABLE client_schedule_preferences IS 'Предпочтения клиента по расписанию';

END $$;