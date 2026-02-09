class Factura {
  final int id;
  final int carritoId;
  final int total;

  Factura({
    required this.id,
    required this.carritoId,
    required this.total,
  });

  factory Factura.desdeJson(Map<String, dynamic> json) {
    return Factura(
      id: json["id"],
      carritoId: json["shoppingCart_id"],
      total: json["total"],
    );
  }
}
