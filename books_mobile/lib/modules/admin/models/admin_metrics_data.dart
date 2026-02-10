import '../../../shared/models/order_model.dart';

class AdminMetricsOverview {
  const AdminMetricsOverview({
    required this.booksCount,
    required this.categoriesCount,
    required this.ordersCount,
    required this.pendingOrdersCount,
    required this.lowStockCount,
    required this.paidRevenueCents,
  });

  final int booksCount;
  final int categoriesCount;
  final int ordersCount;
  final int pendingOrdersCount;
  final int lowStockCount;
  final int paidRevenueCents;

  double get paidRevenue => paidRevenueCents / 100;

  factory AdminMetricsOverview.fromJson(Map<String, dynamic> json) {
    return AdminMetricsOverview(
      booksCount: (json['books_count'] as num? ?? 0).toInt(),
      categoriesCount: (json['categories_count'] as num? ?? 0).toInt(),
      ordersCount: (json['orders_count'] as num? ?? 0).toInt(),
      pendingOrdersCount: (json['pending_orders_count'] as num? ?? 0).toInt(),
      lowStockCount: (json['low_stock_count'] as num? ?? 0).toInt(),
      paidRevenueCents: (json['paid_revenue_cents'] as num? ?? 0).toInt(),
    );
  }
}

class AdminOrdersSeriesItem {
  const AdminOrdersSeriesItem({required this.date, required this.orders});

  final DateTime date;
  final int orders;

  factory AdminOrdersSeriesItem.fromJson(Map<String, dynamic> json) {
    return AdminOrdersSeriesItem(
      date: DateTime.tryParse((json['date'] ?? '') as String) ?? DateTime.now(),
      orders: (json['orders'] as num? ?? 0).toInt(),
    );
  }
}

class AdminStatusMetric {
  const AdminStatusMetric({required this.name, required this.count});

  final String name;
  final int count;

  factory AdminStatusMetric.fromJson(Map<String, dynamic> json) {
    return AdminStatusMetric(
      name: ((json['name'] ?? 'unknown') as String).trim(),
      count: (json['count'] as num? ?? json['value'] as num? ?? 0).toInt(),
    );
  }
}

class AdminTopCategoryMetric {
  const AdminTopCategoryMetric({required this.category, required this.count});

  final String category;
  final int count;

  factory AdminTopCategoryMetric.fromJson(Map<String, dynamic> json) {
    return AdminTopCategoryMetric(
      category: ((json['category'] ?? json['name'] ?? 'Unknown') as String)
          .trim(),
      count: (json['count'] as num? ?? json['value'] as num? ?? 0).toInt(),
    );
  }
}

class AdminLowStockItem {
  const AdminLowStockItem({
    required this.id,
    required this.title,
    required this.stockQuantity,
    required this.priceCents,
  });

  final int id;
  final String title;
  final int stockQuantity;
  final int priceCents;

  double get price => priceCents / 100;

  factory AdminLowStockItem.fromJson(Map<String, dynamic> json) {
    return AdminLowStockItem(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      stockQuantity: (json['stock_quantity'] as num? ?? 0).toInt(),
      priceCents: (json['price_cents'] as num? ?? 0).toInt(),
    );
  }
}

class AdminDashboardDataBundle {
  const AdminDashboardDataBundle({
    required this.overview,
    required this.ordersSeries,
    required this.orderStatusMetrics,
    required this.topCategories,
    required this.recentOrders,
    required this.lowStockBooks,
  });

  final AdminMetricsOverview overview;
  final List<AdminOrdersSeriesItem> ordersSeries;
  final List<AdminStatusMetric> orderStatusMetrics;
  final List<AdminTopCategoryMetric> topCategories;
  final List<OrderModel> recentOrders;
  final List<AdminLowStockItem> lowStockBooks;
}
