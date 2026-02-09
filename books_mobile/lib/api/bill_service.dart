import '../models/bill.dart';
import 'api_service.dart';

class FacturaService {
  final ApiService _apiService = ApiService();

  /// Genera una factura a partir de un identificador de carrito.
  /// Debido a la estructura actual del backend, se envía un único ID
  /// de registro de shopping_carts, tal como lo espera el controlador.
  Future<Factura?> generarFacturaDesdeCarrito(int carritoId) async {
    final respuesta = await _apiService.post(
      "/bills",
      {"shoppingCart_id": carritoId},
      auth: true,
    );

    if (respuesta is Map && respuesta["data"] != null) {
      return Factura.desdeJson(respuesta["data"]);
    }

    return null;
  }
}
