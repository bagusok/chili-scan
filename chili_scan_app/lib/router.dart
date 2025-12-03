import 'package:chili_scan_app/bottom_navigation.dart';
import 'package:chili_scan_app/pages/history_page.dart';
import 'package:chili_scan_app/pages/home_page.dart';
import 'package:chili_scan_app/pages/login_page.dart';
import 'package:chili_scan_app/pages/my_account.dart';
import 'package:chili_scan_app/pages/register_page.dart';
import 'package:chili_scan_app/pages/scanner_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider((ref) {
  return GoRouter(
    initialLocation: '/login',
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
                builder: (context, state) => HistoryPage(),
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
  );
});
