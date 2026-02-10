import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/models/order_model.dart';
import '../../models/admin_dashboard_range.dart';
import '../../models/admin_metrics_data.dart';

class AdminDashboardState {
  const AdminDashboardState({
    this.range = AdminDashboardRange.thirtyDays,
    this.overview,
    this.ordersSeries = const [],
    this.orderStatusMetrics = const [],
    this.topCategories = const [],
    this.recentOrders = const [],
    this.lowStockBooks = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final AdminDashboardRange range;
  final AdminMetricsOverview? overview;
  final List<AdminOrdersSeriesItem> ordersSeries;
  final List<AdminStatusMetric> orderStatusMetrics;
  final List<AdminTopCategoryMetric> topCategories;
  final List<OrderModel> recentOrders;
  final List<AdminLowStockItem> lowStockBooks;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  AdminDashboardState copyWith({
    AdminDashboardRange? range,
    AdminMetricsOverview? overview,
    List<AdminOrdersSeriesItem>? ordersSeries,
    List<AdminStatusMetric>? orderStatusMetrics,
    List<AdminTopCategoryMetric>? topCategories,
    List<OrderModel>? recentOrders,
    List<AdminLowStockItem>? lowStockBooks,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminDashboardState(
      range: range ?? this.range,
      overview: overview ?? this.overview,
      ordersSeries: ordersSeries ?? this.ordersSeries,
      orderStatusMetrics: orderStatusMetrics ?? this.orderStatusMetrics,
      topCategories: topCategories ?? this.topCategories,
      recentOrders: recentOrders ?? this.recentOrders,
      lowStockBooks: lowStockBooks ?? this.lowStockBooks,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AdminDashboardController extends StateNotifier<AdminDashboardState> {
  AdminDashboardController(this._ref) : super(const AdminDashboardState());

  final Ref _ref;

  Future<void> load({AdminDashboardRange? range}) async {
    final selectedRange = range ?? state.range;
    final hasData = state.overview != null;

    state = state.copyWith(
      range: selectedRange,
      isLoading: !hasData,
      isRefreshing: hasData,
      clearError: true,
    );

    try {
      final bundle = await _ref
          .read(adminMetricsRepositoryProvider)
          .fetchDashboardBundle(selectedRange);

      state = state.copyWith(
        range: selectedRange,
        overview: bundle.overview,
        ordersSeries: bundle.ordersSeries,
        orderStatusMetrics: bundle.orderStatusMetrics,
        topCategories: bundle.topCategories,
        recentOrders: bundle.recentOrders,
        lowStockBooks: bundle.lowStockBooks,
        isLoading: false,
        isRefreshing: false,
      );
    } on ApiException catch (exception) {
      if (exception.statusCode == 401) {
        _ref.read(authControllerProvider.notifier).logout();
      }

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: exception.message,
      );
    }
  }
}

final adminDashboardControllerProvider =
    StateNotifierProvider<AdminDashboardController, AdminDashboardState>((ref) {
      return AdminDashboardController(ref);
    });
