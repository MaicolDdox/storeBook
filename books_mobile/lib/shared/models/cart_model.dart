import 'cart_item_model.dart';

class CartModel {
  const CartModel({
    required this.id,
    required this.itemCount,
    required this.subtotalCents,
    required this.items,
  });

  final int? id;
  final int itemCount;
  final int subtotalCents;
  final List<CartItemModel> items;

  double get subtotal => subtotalCents / 100;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: (json['id'] as num?)?.toInt(),
      itemCount: (json['item_count'] as num? ?? 0).toInt(),
      subtotalCents: (json['subtotal_cents'] as num? ?? 0).toInt(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory CartModel.empty() =>
      const CartModel(id: null, itemCount: 0, subtotalCents: 0, items: []);
}
