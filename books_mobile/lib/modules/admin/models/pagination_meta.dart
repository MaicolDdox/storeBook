class PaginationMeta {
  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: (json['current_page'] as num? ?? 1).toInt(),
      lastPage: (json['last_page'] as num? ?? 1).toInt(),
      perPage: (json['per_page'] as num? ?? 20).toInt(),
      total: (json['total'] as num? ?? 0).toInt(),
    );
  }
}
