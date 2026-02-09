import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import 'main_shell.dart';

class StoreBookApp extends ConsumerWidget {
  const StoreBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StoreBook',
      theme: AppTheme.light,
      routes: {RegisterScreen.routeName: (_) => const RegisterScreen()},
      home: _resolveHome(authState),
    );
  }

  Widget _resolveHome(AuthState authState) {
    if (authState.isBootstrapping) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.isAuthenticated) {
      return const MainShell();
    }

    return const LoginScreen();
  }
}
