import '../models/category.dart';
import 'api_service.dart';

class CategoriaService {
  final ApiService _api = ApiService();

  Future<List<Categoria>> obtenerCategorias() async {
    final respuesta = await _api.get("/categories", auth: true);

    if (respuesta is List) {
      return respuesta.map((e) => Categoria.desdeJson(e)).toList();
    }

    if (respuesta is Map && respuesta["data"] is List) {
      return (respuesta["data"] as List)
          .map((e) => Categoria.desdeJson(e))
          .toList();
    }

    return [];
  }
}
