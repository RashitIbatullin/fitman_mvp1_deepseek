#!/bin/bash

# FitMan Database Setup Script
# Настройка PostgreSQL базы данных

set -e  # Выход при ошибке

echo "🗄️  Setting up FitMan Database..."
echo "================================"

# Проверка установки PostgreSQL
if ! command -v psql &> /dev/null; then
    echo "❌ Error: PostgreSQL is not installed or not in PATH"
    echo "Please install PostgreSQL from: https://www.postgresql.org/download/"
    exit 1
fi

echo "✅ PostgreSQL found: $(psql --version)"

# Проверка подключения к PostgreSQL
if ! psql -U postgres -c "SELECT version();" &> /dev/null; then
    echo "❌ Error: Cannot connect to PostgreSQL as user 'postgres'"
    echo "Please ensure PostgreSQL is running and accessible"
    exit 1
fi

echo "✅ Connected to PostgreSQL successfully"

# Переход в директорию database
cd "$(dirname "$0")/../database"

# Проверка существования setup.sql
if [ ! -f "setup.sql" ]; then
    echo "❌ Error: setup.sql not found in database directory"
    exit 1
fi

echo "📋 Executing database setup script..."
psql -U postgres -f setup.sql

echo "✅ Database setup completed successfully!"
echo ""
echo "📊 Database Information:"
echo "   Name: fitman_mvp1_deepseek"
echo "   User: fitman_user"
echo "   Password: fitman"
echo "   Host: localhost"
echo "   Port: 5432"
echo ""
echo "You can now start the backend and frontend applications."