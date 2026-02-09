import 'book_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.quantity,
    required this.unitPriceCents,
    required this.totalPriceCents,
    required this.book,
  });

  final int id;
  final int quantity;
  final int unitPriceCents;
  final int totalPriceCents;
  final BookModel book;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: (json['id'] as num).toInt(),
      quantity: (json['quantity'] as num? ?? 1).toInt(),
      unitPriceCents: (json['unit_price_cents'] as num? ?? 0).toInt(),
      totalPriceCents: (json['total_price_cents'] as num? ?? 0).toInt(),
      book: BookModel.fromJson(json['book'] as Map<String, dynamic>),
    );
  }
}
