import 'package:chili_scan_app/providers/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoginProvider = Provider<bool>((Ref ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.value?.isLoggedIn ?? false;
});
