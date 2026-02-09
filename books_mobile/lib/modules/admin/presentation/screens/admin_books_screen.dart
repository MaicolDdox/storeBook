import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../shared/models/book_model.dart';
import '../providers/admin_controller.dart';
import 'admin_book_form_screen.dart';

class AdminBooksScreen extends ConsumerStatefulWidget {
  const AdminBooksScreen({super.key});

  @override
  ConsumerState<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends ConsumerState<AdminBooksScreen> {
  final _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final controller = ref.read(adminControllerProvider.notifier);
      await controller.loadTypes();
      await controller.loadCategories();
      await controller.loadBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);
    final books = state.books
        .where(
          (book) =>
              _searchTerm.isEmpty ||
              book.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
              book.author.toLowerCase().contains(_searchTerm.toLowerCase()),
        )
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Manage Books',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openForm,
                icon: const Icon(Symbols.add),
                label: const Text('Add Book'),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isLoading && state.books.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(adminControllerProvider.notifier).loadBooks(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search books',
                          prefixIcon: Icon(Symbols.search),
                        ),
                        onChanged: (value) {
                          setState(() => _searchTerm = value.trim());
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
                      if (books.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No books found. Create your first book.',
                            ),
                          ),
                        )
                      else
                        ...books.map(
                          (book) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: _BookCoverThumb(book: book),
                              title: Text(book.title),
                              subtitle: Text(
                                '${book.author}\n${book.category?.genre?.name ?? 'No type'} | ${book.category?.name ?? 'No category'}\n\$${book.price.toStringAsFixed(2)} | Stock: ${book.stockQuantity}',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit book',
                                    onPressed: () => _openForm(book: book),
                                    icon: const Icon(Symbols.edit_square),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete book',
                                    onPressed: () => _confirmDelete(book),
                                    icon: const Icon(Symbols.delete),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _openForm({BookModel? book}) async {
    ref.read(adminControllerProvider.notifier).clearValidationErrors();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminBookFormScreen(book: book)),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            book == null
                ? 'Book created successfully.'
                : 'Book updated successfully.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(BookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Delete "${book.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final success = await ref
        .read(adminControllerProvider.notifier)
        .deleteBook(book.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Book deleted successfully.' : 'Unable to delete book.',
        ),
        backgroundColor: success ? null : Colors.red,
      ),
    );
  }
}

class _BookCoverThumb extends StatelessWidget {
  const _BookCoverThumb({required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    final imageUrl = book.coverImageUrl ?? book.coverImage;

    if (imageUrl == null || imageUrl.isEmpty) {
      return const CircleAvatar(child: Icon(Symbols.book_2));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 42,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const CircleAvatar(child: Icon(Symbols.broken_image)),
      ),
    );
  }
}
