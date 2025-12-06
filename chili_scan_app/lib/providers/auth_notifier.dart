import 'dart:developer';

import 'package:chili_scan_app/common/exceptions/api_exception.dart';
import 'package:chili_scan_app/models/auth_state.dart' as local;
import 'package:chili_scan_app/models/universal_result.dart';
import 'package:chili_scan_app/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends AsyncNotifier {
  late AuthService _authService;

  @override
  local.AuthState build() {
    _authService = ref.read(authServiceProvider);

    return local.AuthState(
      isLoggedIn: _authService.isLoggedIn,
      user: _authService.currentUser,
      session: _authService.currentSession,
    );
  }

  Future<AppResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
      );

      log("Register response: $response");

      state = AsyncValue.data(
        local.AuthState(
          isLoggedIn: response.user != null,
          user: response.user,
          session: response.session,
        ),
      );

      return AppSuccess<AuthResponse>(response);
    } on ApiException catch (e) {
      log("Register error: ${e.message}");
      state = AsyncValue.error(e, StackTrace.current);
      return AppFailure(e.message);
    } catch (e) {
      log("Register error: $e");
      state = AsyncValue.error(e, StackTrace.current);
      return AppFailure(e.toString());
    }
  }

  Future<AppResult> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      log("Login Success: ${response.session?.accessToken}");

      state = AsyncValue.data(
        local.AuthState(
          isLoggedIn: response.user != null,
          user: response.user,
          session: response.session,
        ),
      );
      return AppSuccess<AuthResponse>(response);
    } on ApiException catch (e) {
      log("Login error: ${e.message}");
      // state = AsyncValue.error(e.message, StackTrace.current);
      state = AsyncValue.error(e, StackTrace.current);
      return AppFailure(e.message);
    } catch (e) {
      log("Login error: $e");
      state = AsyncValue.error(e, StackTrace.current);
      return AppFailure(e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AsyncValue.data(
      local.AuthState(isLoggedIn: false, user: null, session: null),
    );
  }
}

final authNotifierProvider = AsyncNotifierProvider(() => AuthNotifier());
