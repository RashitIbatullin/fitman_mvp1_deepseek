#!/bin/bash

# FitMan Frontend Startup Script
# Запуск Flutter приложения

set -e  # Выход при ошибке

echo "🚀 Starting FitMan Frontend..."
echo "================================"

# Проверка установки Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter SDK is not installed or not in PATH"
    echo "Please install Flutter SDK from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter SDK found: $(flutter --version | head -n1)"

# Переход в директорию frontend
cd "$(dirname "$0")/../frontend"

# Проверка существования pubspec.yaml
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found in frontend directory"
    exit 1
fi

echo "📦 Installing dependencies..."
flutter pub get

echo "🔨 Building application..."
flutter clean
flutter pub get

echo "📱 Starting Flutter application..."
echo "The app will open in your default device/emulator"
echo "Press Ctrl+C to stop the application"
echo "================================"

# Запуск приложения
flutter run