class Categoria {
  final int id;
  final int tipoId;
  final String nombre;
  final String? descripcion;

  Categoria({
    required this.id,
    required this.tipoId,
    required this.nombre,
    this.descripcion,
  });

  factory Categoria.desdeJson(Map<String, dynamic> json) {
    return Categoria(
      id: json["id"],
      tipoId: json["type_id"],
      nombre: json["name"],
      descripcion: json["descripccion"],
    );
  }
}
