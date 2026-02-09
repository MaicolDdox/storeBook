import 'address_model.dart';
import 'order_item_model.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.totalCents,
    required this.items,
    this.address,
  });

  final int id;
  final String status;
  final String paymentStatus;
  final int totalCents;
  final List<OrderItemModel> items;
  final AddressModel? address;

  double get total => totalCents / 100;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'] as Map<String, dynamic>?;

    return OrderModel(
      id: (json['id'] as num).toInt(),
      status: (json['status'] ?? 'pending') as String,
      paymentStatus: (json['payment_status'] ?? 'pending') as String,
      totalCents: (json['total_cents'] as num? ?? 0).toInt(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      address: addressJson == null ? null : AddressModel.fromJson(addressJson),
    );
  }
}
