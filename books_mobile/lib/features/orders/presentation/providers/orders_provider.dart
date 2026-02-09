import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../shared/models/address_model.dart';
import '../../../../shared/models/order_model.dart';

class OrdersState {
  const OrdersState({
    this.orders = const [],
    this.addresses = const [],
    this.selectedOrder,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<OrderModel> orders;
  final List<AddressModel> addresses;
  final OrderModel? selectedOrder;
  final bool isLoading;
  final String? errorMessage;

  OrdersState copyWith({
    List<OrderModel>? orders,
    List<AddressModel>? addresses,
    OrderModel? selectedOrder,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedOrder = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      addresses: addresses ?? this.addresses,
      selectedOrder: clearSelectedOrder
          ? null
          : selectedOrder ?? this.selectedOrder,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class OrdersController extends StateNotifier<OrdersState> {
  OrdersController(this._ref) : super(const OrdersState());

  final Ref _ref;

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orders = await _ref.read(ordersRepositoryProvider).fetchOrders();
      state = state.copyWith(orders: orders, isLoading: false);
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
    }
  }

  Future<void> loadOrder(int orderId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final order = await _ref
          .read(ordersRepositoryProvider)
          .fetchOrder(orderId);
      state = state.copyWith(selectedOrder: order, isLoading: false);
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
    }
  }

  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final addresses = await _ref
          .read(ordersRepositoryProvider)
          .fetchAddresses();
      state = state.copyWith(addresses: addresses, isLoading: false);
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
    }
  }

  Future<AddressModel?> createAddress({
    required String recipientName,
    required String line1,
    required String city,
    required String postalCode,
    required String country,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final address = await _ref
          .read(ordersRepositoryProvider)
          .createAddress(
            recipientName: recipientName,
            line1: line1,
            city: city,
            postalCode: postalCode,
            country: country,
          );
      final addresses = [address, ...state.addresses];
      state = state.copyWith(addresses: addresses, isLoading: false);
      return address;
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
      return null;
    }
  }

  Future<OrderModel?> checkout({
    required int addressId,
    required String paymentMethod,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final order = await _ref
          .read(ordersRepositoryProvider)
          .checkout(addressId: addressId, paymentMethod: paymentMethod);
      final orders = [order, ...state.orders];
      state = state.copyWith(
        selectedOrder: order,
        orders: orders,
        isLoading: false,
      );
      return order;
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
      return null;
    }
  }
}

final ordersControllerProvider =
    StateNotifierProvider<OrdersController, OrdersState>((ref) {
      return OrdersController(ref);
    });
