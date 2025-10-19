class AppConfig {
  // JWT настройки
  static const String jwtSecret = 'fitman-super-secret-key-2024-mvp1';
  static const int jwtExpiryHours = 24;
  
  // Настройки базы данных
  static const String dbHost = 'localhost';
  static const int dbPort = 5432;
  static const String dbName = 'fitman_mvp1_deepseek';
  static const String dbUser = 'postgres';
  static const String dbPassword = 'postgres';
  
  // Настройки сервера
  static const int serverPort = 8080;
  static const String serverHost = 'localhost';
  
  // Настройки безопасности
  static const int bcryptRounds = 12;
  static const int minPasswordLength = 6;
  
  // Допустимые роли пользователей
  static const List<String> allowedRoles = ['client', 'trainer', 'admin'];
  
  // Настройки CORS
  static const List<String> allowedOrigins = [
    'http://localhost:3000',
    'http://localhost:8080',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:8080'
  ];
  
  // Валидация email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
  
  // Валидация роли
  static bool isValidRole(String role) {
    return allowedRoles.contains(role);
  }
  
  // Валидация пароля
  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
  }
  
  // Получить настройки подключения к БД в виде строки
  static String get databaseConnectionString {
    return 'postgres://$dbUser:$dbPassword@$dbHost:$dbPort/$dbName';
  }
}