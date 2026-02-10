import '../../../core/network/api_client.dart';
import '../../../shared/models/order_model.dart';
import '../models/admin_dashboard_range.dart';
import '../models/admin_metrics_data.dart';

class AdminMetricsRepository {
  AdminMetricsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AdminMetricsOverview> fetchOverview(AdminDashboardRange range) async {
    final response = await _apiClient.get(
      '/admin/metrics/overview',
      queryParameters: {'range': range.apiValue},
    );

    return AdminMetricsOverview.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<List<AdminOrdersSeriesItem>> fetchOrdersSeries(
    AdminDashboardRange range,
  ) async {
    final response = await _apiClient.get(
      '/admin/metrics/orders-series',
      queryParameters: {'range': range.apiValue},
    );

    final series =
        (response.data['data'] as Map<String, dynamic>)['series']
            as List<dynamic>? ??
        const [];

    return series
        .map(
          (item) =>
              AdminOrdersSeriesItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<AdminStatusMetric>> fetchOrderStatusDistribution(
    AdminDashboardRange range,
  ) async {
    final response = await _apiClient.get(
      '/admin/metrics/order-status',
      queryParameters: {'range': range.apiValue},
    );

    final items =
        (response.data['data'] as Map<String, dynamic>)['status']
            as List<dynamic>? ??
        const [];

    return items
        .map((item) => AdminStatusMetric.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AdminTopCategoryMetric>> fetchTopCategories(
    AdminDashboardRange range,
  ) async {
    final response = await _apiClient.get(
      '/admin/metrics/top-categories',
      queryParameters: {'range': range.apiValue},
    );

    final items =
        (response.data['data'] as Map<String, dynamic>)['items']
            as List<dynamic>? ??
        const [];

    return items
        .map(
          (item) =>
              AdminTopCategoryMetric.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<OrderModel>> fetchRecentOrders({int limit = 10}) async {
    final response = await _apiClient.get(
      '/admin/metrics/recent-orders',
      queryParameters: {'limit': limit},
    );

    final items = response.data['data'] as List<dynamic>? ?? const [];
    return items
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AdminLowStockItem>> fetchLowStockBooks({
    int threshold = 5,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      '/admin/metrics/low-stock',
      queryParameters: {'threshold': threshold, 'limit': limit},
    );

    final items = response.data['data'] as List<dynamic>? ?? const [];
    return items
        .map((item) => AdminLowStockItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AdminDashboardDataBundle> fetchDashboardBundle(
    AdminDashboardRange range,
  ) async {
    final results = await Future.wait([
      fetchOverview(range),
      fetchOrdersSeries(range),
      fetchOrderStatusDistribution(range),
      fetchTopCategories(range),
      fetchRecentOrders(limit: 10),
      fetchLowStockBooks(threshold: 5, limit: 10),
    ]);

    return AdminDashboardDataBundle(
      overview: results[0] as AdminMetricsOverview,
      ordersSeries: results[1] as List<AdminOrdersSeriesItem>,
      orderStatusMetrics: results[2] as List<AdminStatusMetric>,
      topCategories: results[3] as List<AdminTopCategoryMetric>,
      recentOrders: results[4] as List<OrderModel>,
      lowStockBooks: results[5] as List<AdminLowStockItem>,
    );
  }
}
