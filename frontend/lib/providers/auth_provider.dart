import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_front.dart';
import '../services/api_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _loadStoredUser();
  }

  // Загружаем сохраненного пользователя при инициализации
  Future<void> _loadStoredUser() async {
    try {
      final token = await _getStoredToken();
      if (token != null) {
        final userData = await _getStoredUser();
        if (userData != null) {
          state = AsyncValue.data(userData);
          return;
        }
      }
      state = const AsyncValue.data(null);
    } catch (e) {
      print('Error loading stored user: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<User?> _getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      final userData = jsonDecode(userJson);

      return User(
        id: userData['id'] is int ? userData['id'] : int.parse(userData['id'].toString()),
        email: userData['email']?.toString() ?? '',
        passwordHash: userData['passwordHash']?.toString() ?? '',
        firstName: userData['firstName']?.toString() ?? '',
        lastName: userData['lastName']?.toString() ?? '',
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
      );
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authResponse = await ApiService.login(email, password);
      await ApiService.saveToken(authResponse.token);

      // Сохраняем данные пользователя с ВСЕМИ полями
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode({
        'id': authResponse.user.id,
        'email': authResponse.user.email,
        'passwordHash': authResponse.user.passwordHash,
        'firstName': authResponse.user.firstName,
        'lastName': authResponse.user.lastName,
        'middleName': authResponse.user.middleName,
        'role': authResponse.user.role,
        'phone': authResponse.user.phone,
        'gender': authResponse.user.gender,
        'age': authResponse.user.age,
        'sendNotification': authResponse.user.sendNotification,
        'hourNotification': authResponse.user.hourNotification,
        'trackCalories': authResponse.user.trackCalories,
        'coeffActivity': authResponse.user.coeffActivity,
        'createdAt': authResponse.user.createdAt.toIso8601String(),
        'updatedAt': authResponse.user.updatedAt.toIso8601String(),
      }));

      state = AsyncValue.data(authResponse.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> register(
      String email,
      String password,
      String firstName,
      String lastName,
      String role,
      ) async {
    state = const AsyncValue.loading();
    try {
      final authResponse = await ApiService.register(
        email, password, firstName, lastName, role,
      );
      await ApiService.saveToken(authResponse.token);

      // Сохраняем данные пользователя с ВСЕМИ полями
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode({
        'id': authResponse.user.id,
        'email': authResponse.user.email,
        'passwordHash': authResponse.user.passwordHash,
        'firstName': authResponse.user.firstName,
        'lastName': authResponse.user.lastName,
        'middleName': authResponse.user.middleName,
        'role': authResponse.user.role,
        'phone': authResponse.user.phone,
        'gender': authResponse.user.gender,
        'age': authResponse.user.age,
        'sendNotification': authResponse.user.sendNotification,
        'hourNotification': authResponse.user.hourNotification,
        'trackCalories': authResponse.user.trackCalories,
        'coeffActivity': authResponse.user.coeffActivity,
        'createdAt': authResponse.user.createdAt.toIso8601String(),
        'updatedAt': authResponse.user.updatedAt.toIso8601String(),
      }));

      state = AsyncValue.data(authResponse.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void logout() async {
    await ApiService.clearToken();

    // Удаляем данные пользователя
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');

    state = const AsyncValue.data(null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>(
      (ref) => AuthNotifier(),
);