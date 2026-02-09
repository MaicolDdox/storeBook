class GenreModel {
  const GenreModel({required this.id, required this.name, this.description});

  final int id;
  final String name;
  final String? description;

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
    );
  }
}
