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
    this.userName,
    this.userEmail,
    this.createdAt,
    this.placedAt,
  });

  final int id;
  final String status;
  final String paymentStatus;
  final int totalCents;
  final List<OrderItemModel> items;
  final AddressModel? address;
  final String? userName;
  final String? userEmail;
  final DateTime? createdAt;
  final DateTime? placedAt;

  double get total => totalCents / 100;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;

    return OrderModel(
      id: (json['id'] as num).toInt(),
      status: (json['status'] ?? 'pending') as String,
      paymentStatus: (json['payment_status'] ?? 'pending') as String,
      totalCents: (json['total_cents'] as num? ?? 0).toInt(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      address: addressJson == null ? null : AddressModel.fromJson(addressJson),
      userName: userJson?['name'] as String?,
      userEmail: userJson?['email'] as String?,
      createdAt: _parseDateTime(json['created_at'] as String?),
      placedAt: _parseDateTime(json['placed_at'] as String?),
    );
  }

  static DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
