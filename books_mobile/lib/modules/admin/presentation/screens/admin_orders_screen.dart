import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../shared/models/order_model.dart';
import '../providers/admin_controller.dart';
import 'admin_order_detail_screen.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  final _currency = NumberFormat.currency(symbol: '\$');
  static const _statuses = [
    '',
    'pending',
    'paid',
    'processing',
    'shipped',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminControllerProvider.notifier).loadOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);
    final orders = state.orders;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Manage Orders',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isLoading && orders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(adminControllerProvider.notifier)
                      .loadOrders(status: state.orderStatusFilter),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          'orders-filter-${state.orderStatusFilter}',
                        ),
                        initialValue: state.orderStatusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Status filter',
                        ),
                        items: _statuses
                            .map(
                              (status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(
                                  status.isEmpty ? 'All statuses' : status,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          ref
                              .read(adminControllerProvider.notifier)
                              .loadOrders(status: value);
                        },
                      ),
                      const SizedBox(height: 12),
                      if (state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (orders.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No orders found for the selected filter.',
                            ),
                          ),
                        )
                      else
                        ...orders.map(
                          (order) => _buildOrderCard(order, state.isSaving),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isSaving) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Symbols.receipt_long)),
        title: Text('Order #${order.id}'),
        subtitle: Text(
          '${order.userEmail ?? 'Unknown customer'}\nTotal: ${_currency.format(order.total)}',
        ),
        isThreeLine: true,
        trailing: DropdownButton<String>(
          value: order.status,
          items: _statuses
              .where((status) => status.isNotEmpty)
              .map(
                (status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                ),
              )
              .toList(),
          onChanged: isSaving
              ? null
              : (value) async {
                  if (value == null) {
                    return;
                  }
                  final messenger = ScaffoldMessenger.of(context);
                  final success = await ref
                      .read(adminControllerProvider.notifier)
                      .updateOrderStatus(orderId: order.id, status: value);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Order status updated successfully.'
                            : 'Unable to update order status.',
                      ),
                      backgroundColor: success ? null : Colors.red,
                    ),
                  );
                },
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AdminOrderDetailScreen(orderId: order.id),
            ),
          );
        },
      ),
    );
  }
}
