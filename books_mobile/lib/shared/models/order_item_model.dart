class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.title,
    required this.quantity,
    required this.totalPriceCents,
  });

  final int id;
  final String title;
  final int quantity;
  final int totalPriceCents;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] as num).toInt(),
      title: (json['title_snapshot'] ?? '') as String,
      quantity: (json['quantity'] as num? ?? 1).toInt(),
      totalPriceCents: (json['total_price_cents'] as num? ?? 0).toInt(),
    );
  }
}
