import 'package:chili_scan_app/common/exceptions/api_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  late final SupabaseClient _supabaseClient;

  AuthService(this._supabaseClient);

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      return response;
    } catch (e) {
      if (e is AuthException) {
        throw ApiException(error: "Auth Supabase Error", message: e.message);
      } else {
        throw ApiException(error: "Unknown Error", message: e.toString());
      }
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      if (e is AuthException) {
        throw ApiException(error: "Auth Supabase Error", message: e.message);
      } else {
        throw ApiException(error: "Unknown Error", message: e.toString());
      }
    }
  }

  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
  }

  User? get currentUser => _supabaseClient.auth.currentUser;

  Session? get currentSession => _supabaseClient.auth.currentSession;

  bool get isLoggedIn => currentUser != null;
}

final authServiceProvider = Provider.autoDispose<AuthService>((ref) {
  final supabaseClient = Supabase.instance.client;
  return AuthService(supabaseClient);
});
