import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../../shared/models/book_model.dart';
import '../../../../shared/widgets/book_card.dart';
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
    final cartState = ref.watch(cartControllerProvider);

    return RefreshIndicator(
      onRefresh: controller.refreshBooks,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount = _columnCountForWidth(constraints.maxWidth);

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: _CatalogFilters(
                    searchController: _searchController,
                    state: state,
                    onSearch: controller.searchBooks,
                    onCategorySelected: controller.setCategory,
                    onGenreSelected: controller.setGenre,
                  ),
                ),
              ),
              if (state.isLoading && state.books.isEmpty)
                _buildLoadingSliver(columnCount)
              else if (state.errorMessage != null && state.books.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _CatalogErrorState(
                    message: state.errorMessage!,
                    onRetry: controller.refreshBooks,
                  ),
                )
              else if (state.books.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _CatalogEmptyState(onRefresh: controller.refreshBooks),
                )
              else
                _buildBooksSliver(
                  books: state.books,
                  columnCount: columnCount,
                  isCartActionLoading: cartState.isLoading,
                ),
              if (state.isLoading && state.books.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  SliverPadding _buildBooksSliver({
    required List<BookModel> books,
    required int columnCount,
    required bool isCartActionLoading,
  }) {
    if (columnCount == 1) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final book = books[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: BookCard(
                book: book,
                isAddToCartLoading: isCartActionLoading,
                onDetailsPressed: () => _openBookDetail(book.id),
                onAddToCartPressed: () => _addToCart(book.id),
              ),
            );
          }, childCount: books.length),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          mainAxisExtent: 430,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final book = books[index];
          return BookCard(
            book: book,
            isAddToCartLoading: isCartActionLoading,
            onDetailsPressed: () => _openBookDetail(book.id),
            onAddToCartPressed: () => _addToCart(book.id),
          );
        }, childCount: books.length),
      ),
    );
  }

  SliverPadding _buildLoadingSliver(int columnCount) {
    final itemCount = columnCount == 1 ? 3 : columnCount * 2;
    if (columnCount == 1) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: _BookCardSkeleton(),
            ),
            childCount: itemCount,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          mainAxisExtent: 430,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const _BookCardSkeleton(),
          childCount: itemCount,
        ),
      ),
    );
  }

  int _columnCountForWidth(double width) {
    if (width >= 1400) return 4;
    if (width >= 980) return 3;
    if (width >= 720) return 2;
    return 1;
  }

  void _openBookDetail(int bookId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: bookId)));
  }

  Future<void> _addToCart(int bookId) async {
    final authenticated = await _ensureAuthenticated();
    if (!authenticated) {
      return;
    }

    await ref.read(cartControllerProvider.notifier).addItem(bookId);
    final cartState = ref.read(cartControllerProvider);
    if (!mounted) return;

    if (cartState.errorStatusCode == 401) {
      await ref.read(authControllerProvider.notifier).logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add books to your cart.'),
        ),
      );
      return;
    }

    final message = cartState.errorMessage ?? 'Book added to cart.';
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: cartState.errorMessage == null ? null : Colors.red,
      ),
    );
  }

  Future<bool> _ensureAuthenticated() async {
    final authState = ref.read(authControllerProvider);
    if (authState.isAuthenticated) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    final loginResult = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LoginScreen(popOnSuccess: true)),
    );
    return loginResult == true ||
        ref.read(authControllerProvider).isAuthenticated;
  }
}

class _CatalogFilters extends StatelessWidget {
  const _CatalogFilters({
    required this.searchController,
    required this.state,
    required this.onSearch,
    required this.onCategorySelected,
    required this.onGenreSelected,
  });

  final TextEditingController searchController;
  final CatalogState state;
  final ValueChanged<String> onSearch;
  final ValueChanged<int?> onCategorySelected;
  final ValueChanged<int?> onGenreSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackedFilters = constraints.maxWidth < 560;
        final categoryFilter = DropdownMenu<int?>(
          key: ValueKey(state.selectedCategoryId),
          initialSelection: state.selectedCategoryId,
          expandedInsets: EdgeInsets.zero,
          label: const Text('Category'),
          dropdownMenuEntries: [
            const DropdownMenuEntry<int?>(value: null, label: 'All'),
            ...state.categories.map(
              (category) => DropdownMenuEntry<int?>(
                value: category.id,
                label: category.name,
              ),
            ),
          ],
          onSelected: onCategorySelected,
        );
        final genreFilter = DropdownMenu<int?>(
          key: ValueKey(state.selectedGenreId),
          initialSelection: state.selectedGenreId,
          expandedInsets: EdgeInsets.zero,
          label: const Text('Genre'),
          dropdownMenuEntries: [
            const DropdownMenuEntry<int?>(value: null, label: 'All'),
            ...state.genres.map(
              (genre) =>
                  DropdownMenuEntry<int?>(value: genre.id, label: genre.name),
            ),
          ],
          onSelected: onGenreSelected,
        );

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search books',
                    prefixIcon: Icon(Symbols.search),
                  ),
                  onSubmitted: onSearch,
                ),
                const SizedBox(height: 10),
                if (stackedFilters) ...[
                  SizedBox(width: double.infinity, child: categoryFilter),
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: genreFilter),
                ] else
                  Row(
                    children: [
                      Expanded(child: categoryFilter),
                      const SizedBox(width: 8),
                      Expanded(child: genreFilter),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CatalogEmptyState extends StatelessWidget {
  const _CatalogEmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.menu_book, size: 42, color: Color(0xFF00ABE4)),
            const SizedBox(height: 12),
            const Text(
              'No books match the selected filters.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => onRefresh(),
              icon: const Icon(Symbols.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogErrorState extends StatelessWidget {
  const _CatalogErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.wifi_off, size: 42, color: Color(0xFF003A66)),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Symbols.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCardSkeleton extends StatelessWidget {
  const _BookCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SkeletonBox(height: 220),
            SizedBox(height: 12),
            _SkeletonBox(height: 20, width: 220),
            SizedBox(height: 8),
            _SkeletonBox(height: 14, width: 160),
            SizedBox(height: 12),
            _SkeletonBox(height: 14),
            SizedBox(height: 8),
            _SkeletonBox(height: 14, width: 240),
            SizedBox(height: 14),
            _SkeletonBox(height: 30, width: 96),
            SizedBox(height: 12),
            _SkeletonBox(height: 38),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFDDE9F5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
