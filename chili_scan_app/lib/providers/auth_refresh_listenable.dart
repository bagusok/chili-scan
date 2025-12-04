import 'package:chili_scan_app/providers/is_login_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRefreshListenable extends ChangeNotifier {
  late final ProviderSubscription<bool> _subscription;

  AuthRefreshListenable(Ref ref) {
    // Listen to authTokenProvider's state changes (token di SharedPrefs)
    _subscription = ref.listen(isLoginProvider, (_, __) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final authChangeNotifierProvider = Provider<AuthRefreshListenable>((ref) {
  return AuthRefreshListenable(ref);
});
