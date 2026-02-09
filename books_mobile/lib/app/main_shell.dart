import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../modules/admin/presentation/screens/admin_shell.dart';
import '../modules/admin/presentation/widgets/admin_route_guard.dart';
import '../modules/client/presentation/screens/cart_screen.dart';
import '../modules/client/presentation/screens/catalog_screen.dart';
import '../modules/client/presentation/screens/orders_list_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final _pages = const [CatalogScreen(), CartScreen(), OrdersListScreen()];

  @override
  Widget build(BuildContext context) {
    final titles = ['Catalog', 'Cart', 'Orders'];
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          if (authState.isAdmin)
            IconButton(
              tooltip: 'Admin panel',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminRouteGuard(child: AdminShell()),
                  ),
                );
              },
              icon: const Icon(Symbols.admin_panel_settings),
            ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(Symbols.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Symbols.storefront),
            selectedIcon: Icon(Symbols.storefront),
            label: 'Catalog',
          ),
          NavigationDestination(
            icon: Icon(Symbols.shopping_cart),
            selectedIcon: Icon(Symbols.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Symbols.receipt_long),
            selectedIcon: Icon(Symbols.receipt_long),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
