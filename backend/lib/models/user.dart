class User {
  final int id;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String role;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  // Для создания из данных БД
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      email: map['email'].toString(),
      passwordHash: map['password_hash'].toString(),
      firstName: map['first_name'].toString(),
      lastName: map['last_name'].toString(),
      role: map['role'].toString(),
      phone: map['phone']?.toString(),
      createdAt: map['created_at'] is DateTime
          ? map['created_at']
          : DateTime.parse(map['created_at'].toString()),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at']
          : DateTime.parse(map['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Убираем пароль из JSON для безопасности
  Map<String, dynamic> toSafeJson() {
    final json = toJson();
    return json; // passwordHash уже не включается в toJson()
  }

  // Для обновления пользователя
  User copyWith({
    String? firstName,
    String? lastName,
    String? phone,
  }) {
    return User(
      id: id,
      email: email,
      passwordHash: passwordHash,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}