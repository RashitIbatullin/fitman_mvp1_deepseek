class User {
  final int id;  // Изменили String на int
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? avatar;

  User({
    required this.id,  // Теперь int
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.avatar,
  });

  // Геттер для полного имени
  String get name => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),  // Используем новый метод для int
      email: _parseString(json['email']),
      firstName: _parseString(json['firstName'] ?? json['first_name'] ?? ''),
      lastName: _parseString(json['lastName'] ?? json['last_name'] ?? ''),
      phone: _parseString(json['phone']),
      role: _parseString(json['role']),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
      avatar: _parseString(json['avatar']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'avatar': avatar,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatar: avatar ?? this.avatar,
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  // Добавляем метод для парсинга int
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

class AuthResponse {
  final String? token;
  final User? user;
  final String? message;

  AuthResponse({
    this.token,
    this.user,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: _parseString(json['token']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: _parseString(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user?.toJson(),
      'message': message,
     };
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String? phone;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'phone': phone,
    };
  }
}