import '../models/shopping_cart.dart';
import 'api_service.dart';

class CarritoService {
  final ApiService _apiService = ApiService();

  /// Obtiene todos los items del carrito, con libro y usuario.
  Future<List<ItemCarrito>> obtenerCarrito() async {
    final respuesta = await _apiService.get("/shopping_carts", auth: true);

    if (respuesta is Map && respuesta["data"] is List) {
      return (respuesta["data"] as List)
          .map((e) => ItemCarrito.desdeJson(e))
          .toList();
    }

    return [];
  }

  /// Agrega un libro al carrito para el usuario autenticado.
  Future<Map<String, dynamic>> agregarLibroAlCarrito(int libroId) async {
    final respuesta = await _apiService.post(
      "/shopping_carts",
      {"book_id": libroId},
      auth: true,
    );

    return respuesta as Map<String, dynamic>;
  }

  /// Elimina un item del carrito por su identificador.
  Future<Map<String, dynamic>?> eliminarItemCarrito(int itemId) async {
    final respuesta = await _apiService.delete("/shopping_carts/$itemId", auth: true);

    if (respuesta == null) return null;
    return respuesta as Map<String, dynamic>;
  }

  /// Vacia el carrito recorriendo cada item y llamando a la API de borrado.
  /// Si algun item falla al eliminarse, se continua con el resto.
  Future<void> vaciarCarrito() async {
    final items = await obtenerCarrito();
    for (final item in items) {
      try {
        await eliminarItemCarrito(item.id);
      } catch (_) {
        // Ignoramos errores individuales para seguir limpiando el carrito.
      }
    }
  }
}
