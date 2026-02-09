import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../orders/presentation/screens/checkout_screen.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(cartControllerProvider.notifier).loadCart(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    if (state.isLoading && state.cart.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.cart.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.cart.items.isEmpty) {
      return const Center(child: Text('Your cart is empty.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...state.cart.items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Symbols.book_2)),
              title: Text(item.book.title),
              subtitle: Text(
                '\$${(item.totalPriceCents / 100).toStringAsFixed(2)}',
              ),
              trailing: SizedBox(
                width: 124,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: item.quantity > 1
                          ? () => controller.updateItem(
                              item.id,
                              item.quantity - 1,
                            )
                          : null,
                      icon: const Icon(Symbols.remove),
                    ),
                    Text('${item.quantity}'),
                    IconButton(
                      onPressed: () =>
                          controller.updateItem(item.id, item.quantity + 1),
                      icon: const Icon(Symbols.add),
                    ),
                  ],
                ),
              ),
              onLongPress: () => controller.removeItem(item.id),
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subtotal: \$${state.cart.subtotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    );
                  },
                  icon: const Icon(Symbols.payments),
                  label: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
