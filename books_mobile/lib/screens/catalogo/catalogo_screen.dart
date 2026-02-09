import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../api/book_service.dart';
import '../../api/type_service.dart';
import '../../api/category_service.dart';
import '../../models/book.dart';
import '../../models/type.dart';
import '../../models/category.dart';
import 'detalle_libro_screen.dart';
import 'widgets/tarjeta_libro.dart';

/// Pantalla principal de catálogo de libros.
/// Muestra filtros por tipo y categoría, y un grid de tarjetas estilo Google Play Books.
class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final LibroService _libroService = LibroService();
  final TipoService _tipoService = TipoService();
  final CategoriaService _categoriaService = CategoriaService();

  List<Libro> _todosLosLibros = [];
  List<Libro> _librosFiltrados = [];
  List<TipoLibro> _tipos = [];
  List<Categoria> _categorias = [];
  List<Categoria> _categoriasFiltradas = [];

  TipoLibro? _tipoSeleccionado;
  Categoria? _categoriaSeleccionada;

  bool _cargando = true;
  String? _mensajeError;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  /// Carga libros, tipos y categorías desde la API.
  Future<void> _cargarDatosIniciales() async {
    try {
      final libros = await _libroService.obtenerLibros();
      final tipos = await _tipoService.obtenerTipos();
      final categorias = await _categoriaService.obtenerCategorias();

      setState(() {
        _todosLosLibros = libros;
        _librosFiltrados = List.from(libros);
        _tipos = tipos;
        _categorias = categorias;
        _categoriasFiltradas = categorias;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
        _mensajeError = "Ocurrió un error al cargar el catálogo.";
      });
    }
  }

  /// Aplica filtros según tipo y categoría seleccionados.
  void _aplicarFiltros() {
    List<Libro> libros = List.from(_todosLosLibros);

    if (_tipoSeleccionado != null) {
      final idsCategoriasDelTipo = _categorias
          .where((c) => c.tipoId == _tipoSeleccionado!.id)
          .map((c) => c.id)
          .toSet();

      libros = libros
          .where((l) => idsCategoriasDelTipo.contains(l.categoriaId))
          .toList();

      _categoriasFiltradas = _categorias
          .where((c) => c.tipoId == _tipoSeleccionado!.id)
          .toList();
    } else {
      _categoriasFiltradas = List.from(_categorias);
    }

    if (_categoriaSeleccionada != null) {
      libros = libros
          .where((l) => l.categoriaId == _categoriaSeleccionada!.id)
          .toList();
    }

    setState(() {
      _librosFiltrados = libros;
    });
  }

  /// Maneja la selección de un tipo.
  void _onTipoSeleccionado(TipoLibro? nuevoTipo) {
    setState(() {
      _tipoSeleccionado = nuevoTipo;
      _categoriaSeleccionada = null;
    });
    _aplicarFiltros();
  }

  /// Maneja la selección de una categoría.
  void _onCategoriaSeleccionada(Categoria? nuevaCategoria) {
    setState(() {
      _categoriaSeleccionada = nuevaCategoria;
    });
    _aplicarFiltros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Books Store",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _mensajeError != null
          ? Center(child: Text(_mensajeError!))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirFiltros(),
          const SizedBox(height: 8),
          Expanded(child: _construirGridLibros()),
        ],
      ),
    );
  }

  /// Construye la sección de filtros superiores.
  Widget _construirFiltros() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Explora nuestro catálogo",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TipoLibro>(
                  value: _tipoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: "Tipo",
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<TipoLibro>(
                      value: null,
                      child: Text("Todos"),
                    ),
                    ..._tipos.map(
                          (tipo) => DropdownMenuItem<TipoLibro>(
                        value: tipo,
                        child: Text(tipo.nombre),
                      ),
                    ),
                  ],
                  onChanged: _onTipoSeleccionado,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<Categoria>(
                  value: _categoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: "Categoría",
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<Categoria>(
                      value: null,
                      child: Text("Todas"),
                    ),
                    ..._categoriasFiltradas.map(
                          (categoria) => DropdownMenuItem<Categoria>(
                        value: categoria,
                        child: Text(
                          categoria.nombre,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: _onCategoriaSeleccionada,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye el grid de libros con tarjetas grandes.
  Widget _construirGridLibros() {
    if (_librosFiltrados.isEmpty) {
      return const Center(
        child: Text("No hay libros para mostrar con los filtros actuales."),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        itemCount: _librosFiltrados.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemBuilder: (context, index) {
          final libro = _librosFiltrados[index];
          return TarjetaLibro(
            libro: libro,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleLibroScreen(libro: libro),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
