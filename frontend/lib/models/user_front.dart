class User {
  final int id;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String role;
  final String? phone;
  final String? gender;
  final int? age;
  final bool sendNotification;
  final int hourNotification;
  final bool trackCalories;
  final double coeffActivity;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.role,
    this.phone,
    this.gender,
    this.age,
    this.sendNotification = true,
    this.hourNotification = 1,
    this.trackCalories = true,
    this.coeffActivity = 1.2,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      email: map['email'].toString(),
      passwordHash: map['password_hash'].toString(),
      firstName: map['first_name'].toString(),
      lastName: map['last_name'].toString(),
      middleName: map['middle_name']?.toString(),
      role: map['role'].toString(),
      phone: map['phone']?.toString(),
      gender: map['gender']?.toString(),
      age: map['age'] != null ? int.tryParse(map['age'].toString()) : null,
      sendNotification: map['send_notification']?.toString() == 'true',
      hourNotification: map['hour_notification'] != null ? int.tryParse(map['hour_notification'].toString()) ?? 1 : 1,
      trackCalories: map['track_calories']?.toString() == 'true',
      coeffActivity: map['coeff_activity'] != null ? double.tryParse(map['coeff_activity'].toString()) ?? 1.2 : 1.2,
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
      'middleName': middleName,
      'role': role,
      'phone': phone,
      'gender': gender,
      'age': age,
      'sendNotification': sendNotification,
      'hourNotification': hourNotification,
      'trackCalories': trackCalories,
      'coeffActivity': coeffActivity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSafeJson() {
    final json = toJson();
    json.remove('passwordHash');
    return json;
  }

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$lastName $firstName $middleName';
    }
    return '$lastName $firstName';
  }

  String get shortName {
    final middleInitial = middleName != null && middleName!.isNotEmpty
        ? ' ${middleName![0]}.'
        : '';
    return '$lastName ${firstName[0]}.$middleInitial';
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? {};

    return AuthResponse(
      token: json['token'] ?? '',
      user: User(
        id: userData['id'] is int ? userData['id'] : int.parse(userData['id'].toString()),
        email: userData['email']?.toString() ?? '',
        passwordHash: userData['passwordHash']?.toString() ?? '',
        firstName: userData['firstName']?.toString() ?? userData['first_name']?.toString() ?? '',
        lastName: userData['lastName']?.toString() ?? userData['last_name']?.toString() ?? '',
        middleName: userData['middleName']?.toString(),
        role: userData['role']?.toString() ?? 'client',
        phone: userData['phone']?.toString(),
        gender: userData['gender']?.toString(),
        age: userData['age'] != null ? int.tryParse(userData['age'].toString()) : null,
        sendNotification: userData['sendNotification']?.toString() == 'true',
        hourNotification: userData['hourNotification'] != null ? int.tryParse(userData['hourNotification'].toString()) ?? 1 : 1,
        trackCalories: userData['trackCalories']?.toString() == 'true',
        coeffActivity: userData['coeffActivity'] != null ? double.tryParse(userData['coeffActivity'].toString()) ?? 1.2 : 1.2,
        createdAt: userData['createdAt'] is DateTime
            ? userData['createdAt']
            : DateTime.parse(userData['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
        updatedAt: userData['updatedAt'] is DateTime
            ? userData['updatedAt']
            : DateTime.parse(userData['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      ),
    );
  }
}

class CreateUserRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String role;
  final String? phone;
  final String? gender;
  final int? age;
  final bool sendNotification;
  final int hourNotification;
  final bool trackCalories;
  final double coeffActivity;

  CreateUserRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.role,
    this.phone,
    this.gender,
    this.age,
    this.sendNotification = true,
    this.hourNotification = 1,
    this.trackCalories = true,
    this.coeffActivity = 1.2,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String?,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      sendNotification: json['sendNotification'] ?? true,
      hourNotification: json['hourNotification'] ?? 1,
      trackCalories: json['trackCalories'] ?? true,
      coeffActivity: json['coeffActivity']?.toDouble() ?? 1.2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'role': role,
      'phone': phone,
      'gender': gender,
      'age': age,
      'sendNotification': sendNotification,
      'hourNotification': hourNotification,
      'trackCalories': trackCalories,
      'coeffActivity': coeffActivity,
    };
  }
}