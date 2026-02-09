class GenreModel {
  const GenreModel({required this.id, required this.name});

  final int id;
  final String name;

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
    );
  }
}
