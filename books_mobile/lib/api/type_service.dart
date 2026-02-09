import '../models/type.dart';
import 'api_service.dart';

class TipoService {
  final ApiService _api = ApiService();

  Future<List<TipoLibro>> obtenerTipos() async {
    final respuesta = await _api.get("/types", auth: true);

    if (respuesta is List) {
      return respuesta.map((e) => TipoLibro.desdeJson(e)).toList();
    }

    if (respuesta is Map && respuesta["data"] is List) {
      return (respuesta["data"] as List)
          .map((e) => TipoLibro.desdeJson(e))
          .toList();
    }

    return [];
  }
}
