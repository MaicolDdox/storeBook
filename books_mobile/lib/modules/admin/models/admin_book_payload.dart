import 'admin_image_selection.dart';

class AdminBookPayload {
  const AdminBookPayload({
    required this.categoryId,
    required this.title,
    required this.description,
    required this.author,
    required this.stockQuantity,
    required this.priceCents,
    required this.status,
    this.publisher,
    this.publishedYear,
    this.pageCount,
    this.image,
    this.removeImage = false,
  });

  final int categoryId;
  final String title;
  final String description;
  final String author;
  final String? publisher;
  final int? publishedYear;
  final int? pageCount;
  final int stockQuantity;
  final int priceCents;
  final String status;
  final AdminImageSelection? image;
  final bool removeImage;
}
