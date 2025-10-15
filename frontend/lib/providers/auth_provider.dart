import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.data(null)) {
    _loadStoredUser();
  }

  // Загружаем сохраненного пользователя при инициализации
  Future<void> _loadStoredUser() async {
    try {
      await ApiService.init();
      final token = await _getStoredToken();
      if (token != null) {
        final userData = await _getStoredUser();
        if (userData != null) {
          state = AsyncValue.data(userData);
        }
      }
    } catch (e) {
      print('Error loading stored user: $e');
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
        id: userData['id'] ?? 0,
        email: userData['email'] ?? '',
        firstName: userData['firstName'] ?? '',
        lastName: userData['lastName'] ?? '',
        role: userData['role'] ?? 'client',
      );
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authResponse = await ApiService.login(email, password);
      await ApiService.saveToken(authResponse.token);

      // Сохраняем данные пользователя
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode({
        'id': authResponse.user.id,
        'email': authResponse.user.email,
        'firstName': authResponse.user.firstName,
        'lastName': authResponse.user.lastName,
        'role': authResponse.user.role,
      }));

      state = AsyncValue.data(authResponse.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
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

      // Сохраняем данные пользователя
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode({
        'id': authResponse.user.id,
        'email': authResponse.user.email,
        'firstName': authResponse.user.firstName,
        'lastName': authResponse.user.lastName,
        'role': authResponse.user.role,
      }));

      state = AsyncValue.data(authResponse.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
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