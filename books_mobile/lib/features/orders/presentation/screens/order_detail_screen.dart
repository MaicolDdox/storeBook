import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/orders_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final _currency = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(ordersControllerProvider.notifier).loadOrder(widget.orderId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersControllerProvider);
    final order = state.selectedOrder;

    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId}')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
          ? const Center(child: Text('Order details unavailable.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text('Status: ${order.status}'),
                    subtitle: Text('Payment: ${order.paymentStatus}'),
                    trailing: Text(
                      _currency.format(order.total),
                      style: const TextStyle(fontWeight: FontWeight.w800),
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
                        const Text(
                          'Items',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
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
                                ),
                              ],
                            ),
                          ),
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
                        '${order.address!.line1}, ${order.address!.city}, ${order.address!.postalCode}',
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
