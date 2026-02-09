import 'genre_model.dart';

class CategoryModel {
  const CategoryModel({required this.id, required this.name, this.genre});

  final int id;
  final String name;
  final GenreModel? genre;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final genreJson = json['genre'] as Map<String, dynamic>?;

    return CategoryModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      genre: genreJson == null ? null : GenreModel.fromJson(genreJson),
    );
  }
}
