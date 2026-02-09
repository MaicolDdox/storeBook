import 'book.dart';

class ItemCarrito {
  final int id;
  final int libroId;
  final int usuarioId;
  final int precio;
  final Libro libro;

  ItemCarrito({
    required this.id,
    required this.libroId,
    required this.usuarioId,
    required this.precio,
    required this.libro,
  });

  factory ItemCarrito.desdeJson(Map<String, dynamic> json) {
    return ItemCarrito(
      id: json["id"],
      libroId: json["book_id"],
      usuarioId: json["user_id"],
      precio: json["precio"],
      libro: Libro.desdeJson(json["book"]),
    );
  }
}
