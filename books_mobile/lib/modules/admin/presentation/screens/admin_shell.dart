import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import 'admin_books_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_types_screen.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _selectedIndex = 0;

  final _pages = const [
    AdminDashboardScreen(),
    AdminTypesScreen(),
    AdminCategoriesScreen(),
    AdminBooksScreen(),
    AdminOrdersScreen(),
  ];

  final _items = const [
    _AdminNavItem(label: 'Dashboard', icon: Symbols.dashboard),
    _AdminNavItem(label: 'Types', icon: Symbols.category),
    _AdminNavItem(label: 'Categories', icon: Symbols.label),
    _AdminNavItem(label: 'Books', icon: Symbols.menu_book),
    _AdminNavItem(label: 'Orders', icon: Symbols.receipt_long),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 980;

    return Scaffold(
      appBar: AppBar(
        title: Text(_items[_selectedIndex].label),
        actions: [
          IconButton(
            tooltip: 'Client area',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Symbols.storefront),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              final navigator = Navigator.of(context);
              await ref.read(authControllerProvider.notifier).logout();
              if (!mounted) return;
              navigator.pop();
            },
            icon: const Icon(Symbols.logout),
          ),
        ],
      ),
      drawer: isWide ? null : _buildDrawer(),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: _items
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _pages[_selectedIndex]),
              ],
            )
          : _pages[_selectedIndex],
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: _items
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            const ListTile(
              title: Text(
                'Admin Panel',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const Divider(),
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                selected: index == _selectedIndex,
                onTap: () {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AdminNavItem {
  const _AdminNavItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
