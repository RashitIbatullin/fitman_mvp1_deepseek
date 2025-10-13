#!/bin/bash

# FitMan Release Package Creator
# Создание релизного пакета для распространения

set -e  # Выход при ошибке

PROJECT_NAME="fitman-mvp1"
VERSION="1.0.0"
RELEASE_DIR="${PROJECT_NAME}-v${VERSION}"
ZIP_FILE="${PROJECT_NAME}-v${VERSION}.zip"

echo "📦 Creating FitMan Release Package v${VERSION}"
echo "=============================================="

# Создание временной директории
echo "📁 Creating release directory..."
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# Копирование основных файлов
echo "📄 Copying project files..."
cp README.md "$RELEASE_DIR/"
cp .gitignore "$RELEASE_DIR/"

# Копирование backend
echo "🔧 Copying backend..."
mkdir -p "$RELEASE_DIR/backend"
cp -r backend/* "$RELEASE_DIR/backend/"

# Копирование frontend
echo "📱 Copying frontend..."
mkdir -p "$RELEASE_DIR/frontend"
cp -r frontend/* "$RELEASE_DIR/frontend/"

# Копирование дополнительных файлов
echo "🗄️  Copying database scripts..."
mkdir -p "$RELEASE_DIR/database"
cp -r database/* "$RELEASE_DIR/database/"

echo "📚 Copying documentation..."
mkdir -p "$RELEASE_DIR/docs"
cp -r docs/* "$RELEASE_DIR/docs/"

echo "⚡ Copying scripts..."
mkdir -p "$RELEASE_DIR/scripts"
cp -r scripts/* "$RELEASE_DIR/scripts/"

# Очистка временных файлов
echo "🧹 Cleaning temporary files..."
find "$RELEASE_DIR" -name "*.DS_Store" -delete
find "$RELEASE_DIR" -name "*.log" -delete
find "$RELEASE_DIR" -name "build" -type d -exec rm -rf {} + 2>/dev/null || true
find "$RELEASE_DIR" -name ".dart_tool" -type d -exec rm -rf {} + 2>/dev/null || true
find "$RELEASE_DIR" -name ".pub-cache" -type d -exec rm -rf {} + 2>/dev/null || true
find "$RELEASE_DIR" -name ".flutter-plugins" -delete 2>/dev/null || true
find "$RELEASE_DIR" -name ".flutter-plugins-dependencies" -delete 2>/dev/null || true

# Создание ZIP архива
echo "🗜️  Creating ZIP archive..."
rm -f "$ZIP_FILE"
zip -r "$ZIP_FILE" "$RELEASE_DIR"

# Очистка временной директории
echo "🧹 Cleaning up..."
rm -rf "$RELEASE_DIR"

# Вывод информации
echo ""
echo "✅ Release package created: $ZIP_FILE"
echo "📊 File size: $(du -h "$ZIP_FILE" | cut -f1)"
echo ""
echo "🚀 To deploy:"
echo "   1. Extract $ZIP_FILE"
echo "   2. Run: ./scripts/setup_database.sh"
echo "   3. Run: ./scripts/start_backend.sh"
echo "   4. Run: ./scripts/start_frontend.sh"
echo ""
echo "🎉 FitMan MVP 1.0 is ready for distribution!"