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

-- Вывод информации о созданной базе
SELECT 
    '✅ База данных FitMan успешно создана' as message,
    current_database() as database_name,
    current_user as current_user;