import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_helmet/shelf_helmet.dart';
import '../lib/routes/router.dart';
import '../lib/config/database.dart';

void main(List<String> args) async {
  // Инициализируем базу данных
  try {
    await Database().initializeDatabase();
    print('✅ Database initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize database: $e');
    exit(1);
  }

  final handler = const Pipeline()
      .addMiddleware(helmet())
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router);

  final server = await io.serve(handler, 'localhost', 8080);

  print('🚀 FitMan Dart backend running on http://${server.address.host}:${server.port}');
  print('📝 API Health: http://localhost:8080/api/health');

  // Обработка graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    print('\n🛑 Shutting down server...');
    await server.close();
    await Database().disconnect();
    exit(0);
  });
}