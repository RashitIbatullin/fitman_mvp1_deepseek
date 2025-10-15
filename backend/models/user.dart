// user.dart

class AuthResponse {
  final String? token;
  final User? user;
  final String? message;
  final bool success;

  AuthResponse({
    this.token,
    this.user,
    this.message,
    this.success = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: _parseString(json['token']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: _parseString(json['message']),
      success: json['success'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user?.toJson(),
      'message': message,
      'success': success,
    };
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? avatar;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseString(json['id']),
      email: _parseString(json['email']),
      name: _parseString(json['name']),
      phone: _parseString(json['phone']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      avatar: _parseString(json['avatar']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'avatar': avatar,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
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

// Дополнительные классы для работы с пользователями

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String? phone;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
    };
  }
}

class UpdateProfileRequest {
  final String? name;
  final String? phone;
  final String? avatar;

  UpdateProfileRequest({
    this.name,
    this.phone,
    this.avatar,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (avatar != null) data['avatar'] = avatar;
    return data;
  }
}
