import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../screens/admin_access_denied_screen.dart';

final _hasStoredTokenProvider = FutureProvider<bool>((ref) async {
  final token = await ref.watch(authRepositoryProvider).readToken();
  return token != null && token.isNotEmpty;
});

class AdminRouteGuard extends ConsumerWidget {
  const AdminRouteGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final hasStoredToken = ref.watch(_hasStoredTokenProvider);

    if (authState.isBootstrapping || hasStoredToken.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final canAccess =
        (hasStoredToken.value ?? false) &&
        authState.isAuthenticated &&
        authState.isAdmin;

    if (!canAccess) {
      return const AdminAccessDeniedScreen();
    }

    return child;
  }
}
