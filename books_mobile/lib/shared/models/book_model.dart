import 'category_model.dart';

class BookModel {
  const BookModel({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.priceCents,
    required this.stockQuantity,
    required this.status,
    this.coverImage,
    this.coverImageUrl,
    this.publisher,
    this.publishedYear,
    this.pageCount,
    this.category,
  });

  final int id;
  final String title;
  final String? coverImage;
  final String? coverImageUrl;
  final String description;
  final String author;
  final String? publisher;
  final int? publishedYear;
  final int? pageCount;
  final int priceCents;
  final int stockQuantity;
  final String status;
  final CategoryModel? category;

  double get price => priceCents / 100;

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'] as Map<String, dynamic>?;

    return BookModel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      coverImage: json['cover_image'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      description: (json['description'] ?? '') as String,
      author: (json['author'] ?? '') as String,
      publisher: json['publisher'] as String?,
      publishedYear: (json['published_year'] as num?)?.toInt(),
      pageCount: (json['page_count'] as num?)?.toInt(),
      priceCents: (json['price_cents'] as num? ?? 0).toInt(),
      stockQuantity: (json['stock_quantity'] as num? ?? 0).toInt(),
      status: (json['status'] ?? 'available') as String,
      category: categoryJson == null
          ? null
          : CategoryModel.fromJson(categoryJson),
    );
  }
}
