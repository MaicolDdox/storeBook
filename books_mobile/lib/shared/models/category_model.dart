import 'genre_model.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.genre,
  });

  final int id;
  final String name;
  final String? slug;
  final String? description;
  final GenreModel? genre;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final genreJson = json['genre'] as Map<String, dynamic>?;

    return CategoryModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      genre: genreJson == null ? null : GenreModel.fromJson(genreJson),
    );
  }
}
