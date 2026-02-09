import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import 'order_detail_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _recipientController = TextEditingController();
  final _lineController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  final _countryController = TextEditingController(text: 'US');
  final _formKey = GlobalKey<FormState>();

  int? _selectedAddressId;
  String _paymentMethod = 'cash_on_delivery';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(ordersControllerProvider.notifier).loadAddresses();
      await ref.read(cartControllerProvider.notifier).loadCart();
      final addresses = ref.read(ordersControllerProvider).addresses;
      if (addresses.isNotEmpty && mounted) {
        setState(() {
          _selectedAddressId = addresses.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _lineController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersControllerProvider);
    final cartState = ref.watch(cartControllerProvider);
    final addresses = ordersState.addresses;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...cartState.cart.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${item.book.title} x${item.quantity}'),
                          ),
                          Text(
                            '\$${(item.totalPriceCents / 100).toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 20),
                  Text(
                    'Subtotal: \$${cartState.cart.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
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
                    'Shipping address',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (addresses.isEmpty)
                    const Text('No saved addresses. Add one below.')
                  else
                    RadioGroup<int>(
                      groupValue: _selectedAddressId,
                      onChanged: (value) =>
                          setState(() => _selectedAddressId = value),
                      child: Column(
                        children: addresses
                            .map(
                              (address) => RadioListTile<int>(
                                value: address.id,
                                title: Text(address.recipientName),
                                subtitle: Text(
                                  '${address.line1}, ${address.city}',
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  const Divider(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _recipientController,
                          decoration: const InputDecoration(
                            labelText: 'Recipient',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Recipient is required.'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _lineController,
                          decoration: const InputDecoration(
                            labelText: 'Address line',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Address line is required.'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'City is required.'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _postalController,
                          decoration: const InputDecoration(
                            labelText: 'Postal code',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Postal code is required.'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'Country code',
                          ),
                          validator: (value) =>
                              value == null || value.length != 2
                              ? 'Use a 2-letter country code.'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: _saveAddress,
                            icon: const Icon(Symbols.add_location),
                            label: const Text('Save address'),
                          ),
                        ),
                      ],
                    ),
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
                    'Payment method',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownMenu<String>(
                    key: ValueKey(_paymentMethod),
                    initialSelection: _paymentMethod,
                    expandedInsets: EdgeInsets.zero,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: 'cash_on_delivery',
                        label: 'Cash on delivery',
                      ),
                      DropdownMenuEntry(
                        value: 'bank_transfer',
                        label: 'Bank transfer',
                      ),
                      DropdownMenuEntry(value: 'card', label: 'Card (mock)'),
                    ],
                    onSelected: (value) {
                      if (value != null) {
                        setState(() => _paymentMethod = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: ordersState.isLoading ? null : _placeOrder,
                      icon: ordersState.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Symbols.payments),
                      label: const Text('Place order'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final created = await ref
        .read(ordersControllerProvider.notifier)
        .createAddress(
          recipientName: _recipientController.text.trim(),
          line1: _lineController.text.trim(),
          city: _cityController.text.trim(),
          postalCode: _postalController.text.trim(),
          country: _countryController.text.trim().toUpperCase(),
        );

    if (!mounted) return;

    if (created == null) {
      final message =
          ref.read(ordersControllerProvider).errorMessage ??
          'Unable to save address.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _selectedAddressId = created.id;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address saved successfully.')),
    );
  }

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select an address before placing the order.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final order = await ref
        .read(ordersControllerProvider.notifier)
        .checkout(
          addressId: _selectedAddressId!,
          paymentMethod: _paymentMethod,
        );

    if (!mounted) return;

    if (order == null) {
      final message =
          ref.read(ordersControllerProvider).errorMessage ??
          'Unable to place order.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      return;
    }

    await ref.read(cartControllerProvider.notifier).loadCart();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
    );
  }
}
