import '../../../core/network/api_client.dart';
import '../../../shared/models/cart_model.dart';

class CartRepository {
  CartRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<CartModel> fetchCart() async {
    final response = await _apiClient.get('/cart');
    return CartModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<CartModel> addItem({required int bookId, int quantity = 1}) async {
    final response = await _apiClient.post(
      '/cart/items',
      data: {'book_id': bookId, 'quantity': quantity},
    );
    return CartModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<CartModel> updateItem({
    required int itemId,
    required int quantity,
  }) async {
    final response = await _apiClient.patch(
      '/cart/items/$itemId',
      data: {'quantity': quantity},
    );
    return CartModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<CartModel> removeItem(int itemId) async {
    final response = await _apiClient.delete('/cart/items/$itemId');
    return CartModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<CartModel> clear() async {
    final response = await _apiClient.delete('/cart/items');
    return CartModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
