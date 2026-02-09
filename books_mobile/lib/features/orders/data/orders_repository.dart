import '../../../core/network/api_client.dart';
import '../../../shared/models/address_model.dart';
import '../../../shared/models/order_model.dart';

class OrdersRepository {
  OrdersRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<OrderModel>> fetchOrders() async {
    final response = await _apiClient.get('/orders');
    final items = response.data['data'] as List<dynamic>;
    return items
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> fetchOrder(int orderId) async {
    final response = await _apiClient.get('/orders/$orderId');
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<AddressModel>> fetchAddresses() async {
    final response = await _apiClient.get(
      '/addresses',
      queryParameters: {'per_page': 100},
    );
    final items = response.data['data'] as List<dynamic>;
    return items
        .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AddressModel> createAddress({
    required String recipientName,
    required String line1,
    required String city,
    required String postalCode,
    required String country,
  }) async {
    final response = await _apiClient.post(
      '/addresses',
      data: {
        'type': 'shipping',
        'recipient_name': recipientName,
        'line1': line1,
        'city': city,
        'postal_code': postalCode,
        'country': country,
        'is_default': true,
      },
    );
    return AddressModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<OrderModel> checkout({
    required int addressId,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post(
      '/orders',
      data: {'address_id': addressId, 'payment_method': paymentMethod},
    );
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
