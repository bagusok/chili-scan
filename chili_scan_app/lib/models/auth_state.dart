import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final bool isLoggedIn;
  final User? user;
  final Session? session;

  const AuthState({
    required this.isLoggedIn,
    required this.user,
    required this.session,
  });

  AuthState copyWith({bool? isLoggedIn, User? user, Session? session}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      session: session ?? this.session,
    );
  }

  factory AuthState.initial() =>
      const AuthState(isLoggedIn: false, user: null, session: null);
}
