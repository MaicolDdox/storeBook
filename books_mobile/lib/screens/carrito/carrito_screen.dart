import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../api/shopping_cart_service.dart';
import '../../models/shopping_cart.dart';
import '../pagos/pago_screen.dart';

/// Pantalla que muestra el carrito de compras del usuario.
/// Permite eliminar items y navegar al flujo de pago.
class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final CarritoService _carritoService = CarritoService();

  bool _cargando = true;
  List<ItemCarrito> _items = [];
  String? _mensajeError;

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  Future<void> _cargarCarrito() async {
    setState(() {
      _cargando = true;
      _mensajeError = null;
    });

    try {
      final items = await _carritoService.obtenerCarrito();
      setState(() {
        _items = items;
      });
    } catch (e) {
      setState(() {
        _mensajeError = "No se pudo cargar el carrito.";
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  int get _totalCarrito {
    return _items.fold(0, (suma, item) => suma + item.precio);
  }

  Future<void> _eliminarItem(ItemCarrito item) async {
    await _carritoService.eliminarItemCarrito(item.id);
    await _cargarCarrito();
  }

  Future<void> _irAPago() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tu carrito esta vacio.")),
      );
      return;
    }

    final primerIdCarrito = _items.first.id;

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PagoScreen(
          carritoIdReferencia: primerIdCarrito,
          total: _totalCarrito,
        ),
      ),
    );

    // Si el pago fue exitoso y el dialogo devolvio true, recargamos para ver el carrito vacio.
    if (resultado == true) {
      await _cargarCarrito();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pago procesado. Tu carrito fue vaciado.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tu carrito",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[100],
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _mensajeError != null
              ? _ErrorWidget(mensaje: _mensajeError!, onRetry: _cargarCarrito)
              : _items.isEmpty
                  ? _CarritoVacio(onRefresh: _cargarCarrito)
                  : Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _cargarCarrito,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                final libro = item.libro;
                                final imagenUrl = libro.fotoUrlCompleta;

                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: imagenUrl != null
                                            ? Image.network(
                                                imagenUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const _PlaceholderThumb(),
                                              )
                                            : const _PlaceholderThumb(),
                                      ),
                                    ),
                                    title: Text(
                                      libro.titulo,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "\$${item.precio}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.redAccent,
                                      onPressed: () => _eliminarItem(item),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "\$$_totalCarrito",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _irAPago,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    "Ir a pagar",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _PlaceholderThumb extends StatelessWidget {
  const _PlaceholderThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent.withOpacity(0.08),
      child: Icon(
        Icons.menu_book_outlined,
        color: Colors.blueAccent.withOpacity(0.6),
      ),
    );
  }
}

class _CarritoVacio extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _CarritoVacio({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.blueAccent.withOpacity(0.6),
                ),
                const SizedBox(height: 12),
                Text(
                  "Tu carrito esta vacio.",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Explora el catalogo y agrega algunos libros.",
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String mensaje;
  final Future<void> Function() onRetry;

  const _ErrorWidget({required this.mensaje, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mensaje,
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}
