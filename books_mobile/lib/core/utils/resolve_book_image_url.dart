import '../../shared/models/book_model.dart';
import 'resolve_image_url.dart';

String? resolveBookImageUrl(BookModel book) {
  final rawValue = _firstNonEmpty([
    book.imageUrl,
    book.coverImageUrl,
    book.coverImage,
    book.imagePath,
  ]);

  return resolveImageUrl(rawValue);
}

String? _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }

  return null;
}
