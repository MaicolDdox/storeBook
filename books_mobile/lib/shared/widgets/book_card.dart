import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/utils/resolve_book_image_url.dart';
import '../models/book_model.dart';
import 'book_cover_image.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onDetailsPressed,
    required this.onAddToCartPressed,
    this.isAddToCartLoading = false,
  });

  final BookModel book;
  final VoidCallback onDetailsPressed;
  final VoidCallback onAddToCartPressed;
  final bool isAddToCartLoading;
  static final Set<int> _loggedBookIds = <int>{};
  static int _loggedImageCount = 0;

  @override
  Widget build(BuildContext context) {
    _logResolvedImageUrl();

    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);
    final authorStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF526170));
    final descriptionStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF445462));
    final priceStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: const Color(0xFF002748),
      fontWeight: FontWeight.w900,
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCoverImage(
              book: book,
              width: double.infinity,
              height: 220,
              borderRadius: 14,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 12),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
            const SizedBox(height: 4),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: authorStyle,
            ),
            const SizedBox(height: 10),
            Text(
              book.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: descriptionStyle,
            ),
            const SizedBox(height: 14),
            Text('\$${book.price.toStringAsFixed(2)}', style: priceStyle),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDetailsPressed,
                    child: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: isAddToCartLoading ? null : onAddToCartPressed,
                  tooltip: 'Add to cart',
                  icon: isAddToCartLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Symbols.add_shopping_cart),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _logResolvedImageUrl() {
    if (!kDebugMode ||
        _loggedImageCount >= 3 ||
        _loggedBookIds.contains(book.id)) {
      return;
    }

    _loggedBookIds.add(book.id);
    _loggedImageCount += 1;
    final resolvedUrl = resolveBookImageUrl(book);

    debugPrint(
      '[Catalog] Book ${book.id} resolved image URL: ${resolvedUrl ?? 'null'}',
    );
  }
}
