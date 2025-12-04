import 'package:chili_scan_app/common/constants/theme.dart';
import 'package:chili_scan_app/common/env/env.dart';
import 'package:chili_scan_app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ToastificationWrapper(
      child: MaterialApp.router(
        theme: themeLight,
        debugShowCheckedModeBanner: false,
        routerConfig: ref.watch(goRouterProvider),
      ),
    );
  }
}
