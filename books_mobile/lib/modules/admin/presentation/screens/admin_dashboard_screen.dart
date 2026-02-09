import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_controller.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminControllerProvider.notifier).loadDashboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);
    final metrics = state.dashboardMetrics;

    if (state.isLoading && metrics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (metrics == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage ?? 'Unable to load dashboard metrics.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    final cards = <_MetricCardData>[
      _MetricCardData(title: 'Books', value: metrics.booksCount.toString()),
      _MetricCardData(
        title: 'Categories',
        value: metrics.categoriesCount.toString(),
      ),
      _MetricCardData(title: 'Orders', value: metrics.ordersCount.toString()),
      _MetricCardData(
        title: 'Pending Orders',
        value: metrics.pendingOrdersCount.toString(),
      ),
      _MetricCardData(
        title: 'Paid Revenue',
        value: '\$${metrics.paidRevenue.toStringAsFixed(2)}',
      ),
    ];

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(adminControllerProvider.notifier).loadDashboard(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
        ),
        itemCount: cards.length,
        itemBuilder: (_, index) {
          final card = cards[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    card.value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetricCardData {
  const _MetricCardData({required this.title, required this.value});

  final String title;
  final String value;
}
