import '../core/config/app_config.dart';

class Libro {
  final int id;
  final int categoriaId;
  final String titulo;
  final String? foto;
  final String descripcionLarga;
  final String autor;
  final String editorial;
  final String year;
  final String numeroPaginas;
  final int stock;
  final int precio;
  final String estado;

  Libro({
    required this.id,
    required this.categoriaId,
    required this.titulo,
    this.foto,
    required this.descripcionLarga,
    required this.autor,
    required this.editorial,
    required this.year,
    required this.numeroPaginas,
    required this.stock,
    required this.precio,
    required this.estado,
  });

  factory Libro.desdeJson(Map<String, dynamic> json) {
    return Libro(
      id: json["id"],
      categoriaId: json["category_id"],
      titulo: json["titulo"],
      foto: json["foto"],
      descripcionLarga: json["descripccion_larga"],
      autor: json["autor"],
      editorial: json["editorial"],
      year: json["year"],
      numeroPaginas: json["numero_paginas"],
      stock: json["stock"],
      precio: json["precio"],
      estado: json["estado"],
    );
  }

  /// Devuelve la URL completa de la foto usando el host base del backend.
  String? get fotoUrlCompleta => AppConfig.buildImageUrl(foto);
}
