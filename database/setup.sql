-- FitMan MVP 1.0 - Database Setup Script
-- Создание базы данных и пользователя для FitMan

-- Создание базы данных (выполняется от имени postgres)
--замечание - не работает!
CREATE DATABASE fitman_mvp1_deepseek;

-- Создание пользователя
CREATE USER fitman_user WITH PASSWORD 'fitman';

-- Предоставление прав на базу данных
GRANT ALL PRIVILEGES ON DATABASE fitman_mvp1_deepseek TO fitman_user;

-- Подключение к созданной базе данных
--замечание - не работает!
\c fitman_mvp1_deepseek;

-- Предоставление прав на схемы и таблицы
GRANT ALL ON SCHEMA public TO fitman_user;

-- Предоставление прав на все таблицы в схеме public
GRANT ALL ON ALL TABLES IN SCHEMA public TO fitman_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO fitman_user;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO fitman_user;

-- Предоставление прав на будущие таблицы
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO fitman_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO fitman_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO fitman_user;

-- Создание расширений (если нужны)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Комментарий к базе данных
COMMENT ON DATABASE fitman_mvp1_deepseek IS 'Фитнес-менеджер MVP1 от DeepSeek - основная база данных';

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

-- Вывод информации о созданной базе
SELECT 
    '✅ База данных FitMan успешно создана' as message,
    current_database() as database_name,
    current_user as current_user;

