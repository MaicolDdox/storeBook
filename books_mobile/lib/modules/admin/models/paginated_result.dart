import 'pagination_meta.dart';

class PaginatedResult<T> {
  const PaginatedResult({required this.items, required this.pagination});

  final List<T> items;
  final PaginationMeta pagination;
}
