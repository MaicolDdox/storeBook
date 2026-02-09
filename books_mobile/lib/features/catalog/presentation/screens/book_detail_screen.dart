import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/catalog_provider.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final int bookId;

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(bookDetailProvider(widget.bookId));

    return Scaffold(
      appBar: AppBar(title: const Text('Book detail')),
      body: detailState.when(
        data: (book) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.author,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      Text(book.description),
                      const SizedBox(height: 12),
                      Text('Publisher: ${book.publisher ?? 'N/A'}'),
                      Text('Year: ${book.publishedYear ?? 'N/A'}'),
                      Text('Pages: ${book.pageCount ?? 'N/A'}'),
                      Text('Stock: ${book.stockQuantity}'),
                      const SizedBox(height: 16),
                      Text(
                        '\$${book.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity -= 1)
                                : null,
                            icon: const Icon(Symbols.remove),
                          ),
                          Text('$_quantity'),
                          IconButton(
                            onPressed: () => setState(() => _quantity += 1),
                            icon: const Icon(Symbols.add),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => _addToCart(book.id),
                            icon: const Icon(Symbols.shopping_cart),
                            label: const Text('Add to cart'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(int bookId) async {
    await ref
        .read(cartControllerProvider.notifier)
        .addItem(bookId, quantity: _quantity);
    final cartState = ref.read(cartControllerProvider);
    if (!mounted) return;

    final message = cartState.errorMessage ?? 'Book added to cart.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: cartState.errorMessage == null ? null : Colors.red,
      ),
    );
  }
}
