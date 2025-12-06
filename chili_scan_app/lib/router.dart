import 'package:chili_scan_app/bottom_navigation.dart';
import 'package:chili_scan_app/models/predict_history_model.dart';
import 'package:chili_scan_app/pages/history_page.dart';
import 'package:chili_scan_app/pages/home_page.dart';
import 'package:chili_scan_app/pages/login_page.dart';
import 'package:chili_scan_app/pages/my_account.dart';
import 'package:chili_scan_app/pages/prediction_detail_page.dart';
import 'package:chili_scan_app/pages/register_page.dart';
import 'package:chili_scan_app/pages/scanner_page.dart';
import 'package:chili_scan_app/providers/auth_notifier.dart';
import 'package:chili_scan_app/providers/auth_refresh_listenable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider((ref) {
  final a = ref.read(authChangeNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: a,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavigation(navigationShell: navigationShell);
        },
        branches: [
          // TAB HOME
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // TAB SEARCH
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryPage(),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      if (id == null || id.isEmpty) {
                        return const PredictionDetailPage.missing();
                      }

                      final history = state.extra;
                      return PredictionDetailPage(
                        historyId: id,
                        initialHistory: history is PredictHistoryModel
                            ? history
                            : null,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // TAB PROFILE
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-account',
                builder: (context, state) => MyAccountPage(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),

      GoRoute(path: '/scanner', builder: (_, __) => const ScannerPage()),
    ],
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final isLoggedIn = auth.value?.isLoggedIn ?? false;
      final goingToLogin =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !goingToLogin) {
        return '/login';
      } else if (isLoggedIn && goingToLogin) {
        return '/home';
      }

      return null;
    },
  );
});
