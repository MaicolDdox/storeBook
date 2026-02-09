import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/book.dart';

/// Tarjeta de libro estilo Google Play Books.
/// Muestra imagen, titulo, autor y precio.
class TarjetaLibro extends StatelessWidget {
  final Libro libro;
  final VoidCallback onTap;

  const TarjetaLibro({
    super.key,
    required this.libro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagenUrl = libro.fotoUrlCompleta;
    final tema = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: imagenUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: Colors.grey[100]),
                          Image.network(
                            imagenUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blueAccent.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => const _PlaceholderImagen(),
                          ),
                        ],
                      )
                    : const _PlaceholderImagen(),
              ),
            ),

            // Informacion
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    libro.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    libro.autor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "\$${libro.precio}",
                    style: tema.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
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
  const _PlaceholderImagen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent.withOpacity(0.06),
      child: Center(
        child: Icon(
          Icons.menu_book_outlined,
          size: 48,
          color: Colors.blueAccent.withOpacity(0.5),
        ),
      ),
    );
  }
}
