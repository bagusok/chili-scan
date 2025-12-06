import 'dart:developer';

import 'package:chili_scan_app/common/env/env.dart';
import 'package:chili_scan_app/services/supabase_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider.autoDispose<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: Env.apiUrl));
  final supabaseProvider = ref.read(supabase);

  final session = supabaseProvider.auth.currentSession?.accessToken;

  dio.interceptors.add(AuthInterceptor(session));

  return dio;
});

class AuthInterceptor extends Interceptor {
  final String? token;

  AuthInterceptor(this.token);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (token != null && token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    log(
      'Requesting ${options.method} ${options.uri} with headers: ${options.headers}',
    );
    super.onRequest(options, handler);
  }
}
