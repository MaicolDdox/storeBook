import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/admin_controller.dart';

class AdminOrderDetailScreen extends ConsumerStatefulWidget {
  const AdminOrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  ConsumerState<AdminOrderDetailScreen> createState() =>
      _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState
    extends ConsumerState<AdminOrderDetailScreen> {
  final _currency = NumberFormat.currency(symbol: '\$');
  static const _statuses = [
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
      () =>
          ref.read(adminControllerProvider.notifier).loadOrder(widget.orderId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);
    final order = state.selectedOrder;

    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId}')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Order details unavailable.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(order.userName ?? 'N/A'),
                        Text(order.userEmail ?? 'N/A'),
                        const SizedBox(height: 10),
                        Text('Payment status: ${order.paymentStatus}'),
                        Text(
                          'Placed at: ${order.placedAt?.toLocal().toString() ?? order.createdAt?.toLocal().toString() ?? 'N/A'}',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                key: ValueKey(
                                  'order-status-${order.id}-${order.status}',
                                ),
                                initialValue: order.status,
                                decoration: const InputDecoration(
                                  labelText: 'Order status',
                                ),
                                items: _statuses
                                    .map(
                                      (status) => DropdownMenuItem<String>(
                                        value: status,
                                        child: Text(status),
                                      ),
                                    )
                                    .toList(),
                                onChanged: state.isSaving
                                    ? null
                                    : (value) async {
                                        if (value == null) {
                                          return;
                                        }
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final success = await ref
                                            .read(
                                              adminControllerProvider.notifier,
                                            )
                                            .updateOrderStatus(
                                              orderId: order.id,
                                              status: value,
                                            );
                                        if (!mounted) return;
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? 'Order status updated successfully.'
                                                  : 'Unable to update order status.',
                                            ),
                                            backgroundColor: success
                                                ? null
                                                : Colors.red,
                                          ),
                                        );
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        ...order.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.title} x${item.quantity}',
                                  ),
                                ),
                                Text(
                                  _currency.format(item.totalPriceCents / 100),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Text(
                              _currency.format(order.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (order.address != null) ...[
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      title: Text(order.address!.recipientName),
                      subtitle: Text(
                        '${order.address!.line1}, ${order.address!.city}, ${order.address!.postalCode}, ${order.address!.country}',
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
