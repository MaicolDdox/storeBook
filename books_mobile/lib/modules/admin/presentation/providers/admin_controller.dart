import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/models/book_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/genre_model.dart';
import '../../../../shared/models/order_model.dart';
import '../../models/admin_book_payload.dart';
import '../../models/admin_dashboard_metrics.dart';
import '../../models/pagination_meta.dart';

class AdminState {
  const AdminState({
    this.dashboardMetrics,
    this.types = const [],
    this.categories = const [],
    this.books = const [],
    this.orders = const [],
    this.selectedOrder,
    this.typesPagination = const PaginationMeta(
      currentPage: 1,
      lastPage: 1,
      perPage: 20,
      total: 0,
    ),
    this.categoriesPagination = const PaginationMeta(
      currentPage: 1,
      lastPage: 1,
      perPage: 20,
      total: 0,
    ),
    this.booksPagination = const PaginationMeta(
      currentPage: 1,
      lastPage: 1,
      perPage: 20,
      total: 0,
    ),
    this.ordersPagination = const PaginationMeta(
      currentPage: 1,
      lastPage: 1,
      perPage: 20,
      total: 0,
    ),
    this.orderStatusFilter = '',
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.validationErrors = const {},
  });

  final AdminDashboardMetrics? dashboardMetrics;
  final List<GenreModel> types;
  final List<CategoryModel> categories;
  final List<BookModel> books;
  final List<OrderModel> orders;
  final OrderModel? selectedOrder;
  final PaginationMeta typesPagination;
  final PaginationMeta categoriesPagination;
  final PaginationMeta booksPagination;
  final PaginationMeta ordersPagination;
  final String orderStatusFilter;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final Map<String, List<String>> validationErrors;

  AdminState copyWith({
    AdminDashboardMetrics? dashboardMetrics,
    List<GenreModel>? types,
    List<CategoryModel>? categories,
    List<BookModel>? books,
    List<OrderModel>? orders,
    OrderModel? selectedOrder,
    PaginationMeta? typesPagination,
    PaginationMeta? categoriesPagination,
    PaginationMeta? booksPagination,
    PaginationMeta? ordersPagination,
    String? orderStatusFilter,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    Map<String, List<String>>? validationErrors,
    bool clearError = false,
    bool clearValidationErrors = false,
    bool clearSelectedOrder = false,
  }) {
    return AdminState(
      dashboardMetrics: dashboardMetrics ?? this.dashboardMetrics,
      types: types ?? this.types,
      categories: categories ?? this.categories,
      books: books ?? this.books,
      orders: orders ?? this.orders,
      selectedOrder: clearSelectedOrder
          ? null
          : selectedOrder ?? this.selectedOrder,
      typesPagination: typesPagination ?? this.typesPagination,
      categoriesPagination: categoriesPagination ?? this.categoriesPagination,
      booksPagination: booksPagination ?? this.booksPagination,
      ordersPagination: ordersPagination ?? this.ordersPagination,
      orderStatusFilter: orderStatusFilter ?? this.orderStatusFilter,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      validationErrors: clearValidationErrors
          ? const {}
          : validationErrors ?? this.validationErrors,
    );
  }
}

class AdminController extends StateNotifier<AdminState> {
  AdminController(this._ref) : super(const AdminState());

  final Ref _ref;

  Future<void> loadDashboard() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearValidationErrors: true,
    );
    try {
      final metrics = await _ref.read(adminRepositoryProvider).fetchDashboard();
      state = state.copyWith(dashboardMetrics: metrics, isLoading: false);
    } on ApiException catch (exception) {
      _handleException(exception);
    }
  }

  Future<void> loadTypes({int page = 1}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearValidationErrors: true,
    );
    try {
      final response = await _ref
          .read(adminRepositoryProvider)
          .fetchTypes(page: page);

      state = state.copyWith(
        types: response.items,
        typesPagination: response.pagination,
        isLoading: false,
      );
    } on ApiException catch (exception) {
      _handleException(exception);
    }
  }

  Future<bool> saveType({
    int? typeId,
    required String name,
    String? description,
  }) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearValidationErrors: true,
    );
    try {
      if (typeId == null) {
        await _ref
            .read(adminRepositoryProvider)
            .createType(name: name, description: description);
      } else {
        await _ref
            .read(adminRepositoryProvider)
            .updateType(typeId: typeId, name: name, description: description);
      }

      await loadTypes(page: state.typesPagination.currentPage);
      state = state.copyWith(isSaving: false);
      return true;
    } on ApiException catch (exception) {
      _handleException(exception);
      return false;
    }
  }

  Future<bool> deleteType(int typeId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _ref.read(adminRepositoryProvider).deleteType(typeId);
      await loadTypes(page: state.typesPagination.currentPage);
      state = state.copyWith(isSaving: false);
      return true;
    } on ApiException catch (exception) {
      _handleException(exception);
      return false;
    }
  }

  Future<void> loadCategories({int page = 1}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearValidationErrors: true,
    );
    try {
      final response = await _ref
          .read(adminRepositoryProvider)
          .fetchCategories(page: page);

      state = state.copyWith(
        categories: response.items,
        categoriesPagination: response.pagination,
        isLoading: false,
      );
    } on ApiException catch (exception) {
      _handleException(exception);
    }
  }

  Future<bool> saveCategory({
    int? categoryId,
    required int typeId,
    required String name,
    String? description,
  }) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearValidationErrors: true,
    );
    try {
      if (categoryId == null) {
        await _ref
            .read(adminRepositoryProvider)
            .createCategory(
              typeId: typeId,
              name: name,
              description: description,
            );
      } else {
        await _ref
            .read(adminRepositoryProvider)
            .updateCategory(
              categoryId: categoryId,
              typeId: typeId,
              name: name,
              description: description,
            );
      }

      await loadCategories(page: state.categoriesPagination.currentPage);
      state = state.copyWith(isSaving: false);
      return true;
    } on ApiException catch (exception) {
      _handleException(exception);
      return false;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _ref.read(adminRepositoryProvider).deleteCategory(categoryId);
      await loadCategories(page: state.categoriesPagination.currentPage);
      state = state.copyWith(isSaving: false);
      return true;
    } on ApiException catch (exception) {
      _handleException(exception);
      return false;
    }
  }

  Future<void> loadBooks({int page = 1}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearValidationErrors: true,
    );
    try {
      final response = await _ref
          .read(adminRepositoryProvider)
          .fetchBooks(page: page);

      state = state.copyWith(
        books: response.items,
        booksPagination: response.pagination,
        isLoading: false,
      );
    } on ApiException catch (exception) {
      _handleException(exception);
    }
  }

  Future<bool> saveBook({
    int? bookId,
    required AdminBookPayload payload,
  }) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearValidationErrors: true,
    );
    try {
      if (bookId == null) {
        await _ref.read(adminRepositoryProvider).createBook(payload);
      } else {
        await _ref.read(adminRepositoryProvider).updateBook(bookId, payload);
      }

      await loadBooks(page: state.booksPagination.currentPage);
      state = state.copyWith(isSaving: false);
      return true;
    } on ApiException catch (exception) {
      _handleException(exception);
      return false;
    }
  }

  Future<bool> deleteBook(int bookId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _ref.read(adminRepositoryProvider).deleteBook(bookId);
      await loadBooks(page: state.booksPagination.currentPage);
      state = state.copyWith(isSaving: false);
      return true;
    } on ApiException catch (exception) {
      _handleException(exception);
      return false;
    }
  }

  Future<void> loadOrders({int page = 1, String? status}) async {
    final selectedStatus = status ?? state.orderStatusFilter;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearValidationErrors: true,
      orderStatusFilter: selectedStatus,
    );
    try {
      final response = await _ref
          .read(adminRepositoryProvider)
          .fetchOrders(page: page, status: selectedStatus);

      state = state.copyWith(
        orders: response.items,
        ordersPagination: response.pagination,
        isLoading: false,
      );
    } on ApiException catch (exception) {
      _handleException(exception);
    }
  }

  Future<void> loadOrder(int orderId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearValidationErrors: true,
    );
    try {
      final order = await _ref
          .read(adminRepositoryProvider)
          .fetchOrder(orderId);
      state = state.copyWith(selectedOrder: order, isLoading: false);
    } on ApiException catch (exception) {
      _handleException(exception);
    }
  }

  Future<bool> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearValidationErrors: true,
    );
    try {
      final updated = await _ref
          .read(adminRepositoryProvider)
          .updateOrderStatus(orderId: orderId, status: status);

      final updatedOrders = state.orders
          .map((order) => order.id == updated.id ? updated : order)
          .toList();

      state = state.copyWith(
        orders: updatedOrders,
        selectedOrder: state.selectedOrder?.id == updated.id
            ? updated
            : state.selectedOrder,
        isSaving: false,
      );

      return true;
    } on ApiException catch (exception) {
      _handleException(exception);
      return false;
    }
  }

  void clearValidationErrors() {
    state = state.copyWith(clearValidationErrors: true);
  }

  void _handleException(ApiException exception) {
    if (exception.statusCode == 401) {
      _ref.read(authControllerProvider.notifier).logout();
    }

    state = state.copyWith(
      isLoading: false,
      isSaving: false,
      errorMessage: exception.message,
      validationErrors: _normalizeValidationErrors(exception.validationErrors),
    );
  }

  Map<String, List<String>> _normalizeValidationErrors(
    Map<String, dynamic>? errors,
  ) {
    if (errors == null || errors.isEmpty) {
      return const {};
    }

    return errors.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.map((item) => item.toString()).toList());
      }
      return MapEntry(key, [value.toString()]);
    });
  }
}

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
      return AdminController(ref);
    });
