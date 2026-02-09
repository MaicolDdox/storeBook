import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../api/shopping_cart_service.dart';
import '../../models/book.dart';

/// Pantalla de detalle de libro.
/// Permite ver informacion completa y agregar al carrito.
class DetalleLibroScreen extends StatefulWidget {
  final Libro libro;

  const DetalleLibroScreen({super.key, required this.libro});

  @override
  State<DetalleLibroScreen> createState() => _DetalleLibroScreenState();
}

class _DetalleLibroScreenState extends State<DetalleLibroScreen> {
  final CarritoService _carritoService = CarritoService();
  bool _agregando = false;

  Future<void> _agregarAlCarrito() async {
    setState(() {
      _agregando = true;
    });

    final respuesta = await _carritoService.agregarLibroAlCarrito(widget.libro.id);

    setState(() {
      _agregando = false;
    });

    final mensaje = respuesta["message"] ?? "Libro agregado al carrito.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final libro = widget.libro;
    final imagenUrl = libro.fotoUrlCompleta;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          libro.titulo,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imagenUrl != null
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 260,
                                  width: double.infinity,
                                  color: Colors.grey[100],
                                ),
                                Image.network(
                                  imagenUrl,
                                  height: 260,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return SizedBox(
                                      height: 260,
                                      child: Center(
                                        child: SizedBox(
                                          height: 32,
                                          width: 32,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.blueAccent.withOpacity(0.85),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => _PlaceholderImagen(
                                    height: 260,
                                    width: double.infinity,
                                  ),
                                ),
                              ],
                            )
                          : _PlaceholderImagen(
                              height: 260,
                              width: 180,
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    libro.titulo,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${libro.autor} | ${libro.editorial}",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "\$${libro.precio}",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _ChipInfo(texto: "Ano: ${libro.year}"),
                      _ChipInfo(texto: "Paginas: ${libro.numeroPaginas}"),
                      _ChipInfo(texto: "Stock: ${libro.stock}"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Descripcion",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    libro.descripcionLarga,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _agregando ? null : _agregarAlCarrito,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _agregando
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              "Agregar al carrito",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImagen extends StatelessWidget {
  final double? height;
  final double? width;

  const _PlaceholderImagen({this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.blueAccent.withOpacity(0.08),
      child: Center(
        child: Icon(
          Icons.menu_book_outlined,
          size: 64,
          color: Colors.blueAccent.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final String texto;

  const _ChipInfo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.blueAccent[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
