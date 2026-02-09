import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../shared/models/cart_model.dart';

class CartState {
  const CartState({
    this.cart = const CartModel(
      id: null,
      itemCount: 0,
      subtotalCents: 0,
      items: [],
    ),
    this.isLoading = false,
    this.errorMessage,
  });

  final CartModel cart;
  final bool isLoading;
  final String? errorMessage;

  CartState copyWith({
    CartModel? cart,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class CartController extends StateNotifier<CartState> {
  CartController(this._ref) : super(const CartState());

  final Ref _ref;

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cart = await _ref.read(cartRepositoryProvider).fetchCart();
      state = state.copyWith(cart: cart, isLoading: false);
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
    }
  }

  Future<void> addItem(int bookId, {int quantity = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cart = await _ref
          .read(cartRepositoryProvider)
          .addItem(bookId: bookId, quantity: quantity);
      state = state.copyWith(cart: cart, isLoading: false);
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
    }
  }

  Future<void> updateItem(int itemId, int quantity) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cart = await _ref
          .read(cartRepositoryProvider)
          .updateItem(itemId: itemId, quantity: quantity);
      state = state.copyWith(cart: cart, isLoading: false);
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
    }
  }

  Future<void> removeItem(int itemId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cart = await _ref.read(cartRepositoryProvider).removeItem(itemId);
      state = state.copyWith(cart: cart, isLoading: false);
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
    }
  }

  Future<void> clear() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cart = await _ref.read(cartRepositoryProvider).clear();
      state = state.copyWith(cart: cart, isLoading: false);
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
    }
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, CartState>(
  (ref) {
    return CartController(ref);
  },
);
