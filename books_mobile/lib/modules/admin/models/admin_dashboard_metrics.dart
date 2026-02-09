class AdminDashboardMetrics {
  const AdminDashboardMetrics({
    required this.booksCount,
    required this.categoriesCount,
    required this.ordersCount,
    required this.pendingOrdersCount,
    required this.paidRevenueCents,
  });

  final int booksCount;
  final int categoriesCount;
  final int ordersCount;
  final int pendingOrdersCount;
  final int paidRevenueCents;

  double get paidRevenue => paidRevenueCents / 100;

  factory AdminDashboardMetrics.fromJson(Map<String, dynamic> json) {
    return AdminDashboardMetrics(
      booksCount: (json['books_count'] as num? ?? 0).toInt(),
      categoriesCount: (json['categories_count'] as num? ?? 0).toInt(),
      ordersCount: (json['orders_count'] as num? ?? 0).toInt(),
      pendingOrdersCount: (json['pending_orders_count'] as num? ?? 0).toInt(),
      paidRevenueCents: (json['paid_revenue_cents'] as num? ?? 0).toInt(),
    );
  }
}
