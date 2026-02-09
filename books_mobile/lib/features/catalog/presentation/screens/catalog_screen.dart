import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import 'book_detail_screen.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(catalogControllerProvider.notifier).loadInitial(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogControllerProvider);
    final controller = ref.read(catalogControllerProvider.notifier);

    return RefreshIndicator(
      onRefresh: controller.refreshBooks,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search books',
                      prefixIcon: Icon(Symbols.search),
                    ),
                    onSubmitted: controller.searchBooks,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownMenu<int?>(
                          key: ValueKey(state.selectedCategoryId),
                          initialSelection: state.selectedCategoryId,
                          expandedInsets: EdgeInsets.zero,
                          label: const Text('Category'),
                          dropdownMenuEntries: [
                            const DropdownMenuEntry<int?>(
                              value: null,
                              label: 'All',
                            ),
                            ...state.categories.map(
                              (category) => DropdownMenuEntry<int?>(
                                value: category.id,
                                label: category.name,
                              ),
                            ),
                          ],
                          onSelected: controller.setCategory,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownMenu<int?>(
                          key: ValueKey(state.selectedGenreId),
                          initialSelection: state.selectedGenreId,
                          expandedInsets: EdgeInsets.zero,
                          label: const Text('Genre'),
                          dropdownMenuEntries: [
                            const DropdownMenuEntry<int?>(
                              value: null,
                              label: 'All',
                            ),
                            ...state.genres.map(
                              (genre) => DropdownMenuEntry<int?>(
                                value: genre.id,
                                label: genre.name,
                              ),
                            ),
                          ],
                          onSelected: controller.setGenre,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (state.isLoading && state.books.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (state.errorMessage != null)
            _ErrorMessage(message: state.errorMessage!)
          else if (state.books.isEmpty)
            const _EmptyState()
          else
            ...state.books.map(
              (book) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(child: Icon(Symbols.book_2)),
                  title: Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${book.author}\n\$${book.price.toStringAsFixed(2)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Symbols.add_shopping_cart),
                    onPressed: () => _addToCart(book.id),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(bookId: book.id),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _addToCart(int bookId) async {
    await ref.read(cartControllerProvider.notifier).addItem(bookId);
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text('No books available for the selected filters.'),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
