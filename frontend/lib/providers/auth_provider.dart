import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authResponse = await ApiService.login(email, password);
      await ApiService.saveToken(authResponse.token);
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
      state = AsyncValue.data(authResponse.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  void logout() {
    ApiService.clearToken();
    state = const AsyncValue.data(null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>(
  (ref) => AuthNotifier(),
);