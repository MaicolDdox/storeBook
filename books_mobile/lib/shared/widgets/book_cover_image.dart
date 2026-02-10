import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/utils/resolve_book_image_url.dart';
import '../models/book_model.dart';

class BookCoverImage extends StatelessWidget {
  const BookCoverImage({
    super.key,
    required this.book,
    this.width = 52,
    this.height = 72,
    this.borderRadius = 10,
    this.fit = BoxFit.cover,
  });

  final BookModel book;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;
  static String? _lastFailingUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveBookImageUrl(book);
    if (resolvedUrl == null) {
      return _PlaceholderCover(
        width: width,
        height: height,
        borderRadius: borderRadius,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _PlaceholderCover(
            width: width,
            height: height,
            borderRadius: borderRadius,
            isLoading: true,
          );
        },
        errorBuilder: (_, __, ___) {
          if (kDebugMode) {
            debugPrint('[Catalog] Failed to load book cover: $resolvedUrl');
            _lastFailingUrl = resolvedUrl;
          }
          return _PlaceholderCover(
            width: width,
            height: height,
            borderRadius: borderRadius,
            errorCaption: kDebugMode
                ? 'Image failed to load\n${_lastFailingUrl ?? ''}'
                : null,
          );
        },
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover({
    required this.width,
    required this.height,
    required this.borderRadius,
    this.isLoading = false,
    this.errorCaption,
  });

  final double width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final String? errorCaption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9F1FA),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Symbols.menu_book, color: Color(0xFF00ABE4)),
                  if (errorCaption != null && errorCaption!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      errorCaption!,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF385A72),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
