import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_helmet/shelf_helmet.dart';
import '../lib/routes/router.dart';
import '../lib/config/database.dart';
import  '../lib/config/app_config.dart';
import '../lib/middleware/cors_middleware.dart';

void main(List<String> args) async {
  // Инициализируем базу данных
  try {
    await Database().initializeDatabase();
    print('✅ Database initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize database: $e');
    exit(1);
  }

  // Создаем pipeline с middleware
  final handler = const Pipeline()
      .addMiddleware(helmet())
      .addMiddleware(corsHeaders())
      .addMiddleware(corsMiddleware())
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await io.serve(
      handler,
      AppConfig.serverHost,
      AppConfig.serverPort
  );

  print('🚀 FitMan Dart backend MVP1 running on http://${server.address.host}:${server.port}');
  print('📝 API Health: http://localhost:${AppConfig.serverPort}/api/health');
  print('🔐 Auth endpoints:');
  print('   POST http://localhost:${AppConfig.serverPort}/api/auth/login');
  print('   POST http://localhost:${AppConfig.serverPort}/api/auth/register');
  print('   GET  http://localhost:${AppConfig.serverPort}/api/auth/check');
  print('👥 User management (Admin only):');
  print('   GET  http://localhost:${AppConfig.serverPort}/api/users');
  print('   POST http://localhost:${AppConfig.serverPort}/api/users');
  print('📊 Training endpoints:');
  print('   GET http://localhost:${AppConfig.serverPort}/api/training/plans');
  print('📅 Schedule endpoints:');
  print('   GET http://localhost:${AppConfig.serverPort}/api/schedule');

  // Обработка graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    print('\n🛑 Shutting down server...');
    await server.close();
    await Database().disconnect();
    exit(0);
  });
}