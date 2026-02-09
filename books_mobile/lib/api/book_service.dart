import '../models/book.dart';
import 'api_service.dart';

class LibroService {
  final ApiService _api = ApiService();

  Future<List<Libro>> obtenerLibros() async {
    final respuesta = await _api.get("/books", auth: true);

    if (respuesta is List) {
      return respuesta.map((e) => Libro.desdeJson(e)).toList();
    }

    if (respuesta is Map && respuesta["data"] is List) {
      return (respuesta["data"] as List)
          .map((e) => Libro.desdeJson(e))
          .toList();
    }

    return [];
  }
}
