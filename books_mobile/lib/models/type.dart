class TipoLibro {
  final int id;
  final String nombre;
  final String? descripcion;

  TipoLibro({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory TipoLibro.desdeJson(Map<String, dynamic> json) {
    return TipoLibro(
      id: json["id"],
      nombre: json["name"],
      descripcion: json["descripccion"],
    );
  }
}
