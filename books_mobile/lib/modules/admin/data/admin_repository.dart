import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/book_model.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/genre_model.dart';
import '../../../shared/models/order_model.dart';
import '../models/admin_book_payload.dart';
import '../models/admin_dashboard_metrics.dart';
import '../models/admin_image_selection.dart';
import '../models/paginated_result.dart';
import '../models/pagination_meta.dart';

class AdminRepository {
  AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AdminDashboardMetrics> fetchDashboard() async {
    final response = await _apiClient.get('/admin/dashboard');
    return AdminDashboardMetrics.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<PaginatedResult<GenreModel>> fetchTypes({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get(
      '/admin/genres',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final items = (response.data['data'] as List<dynamic>)
        .map((item) => GenreModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return PaginatedResult(
      items: items,
      pagination: _paginationFromResponse(response),
    );
  }

  Future<GenreModel> createType({
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.post(
      '/admin/genres',
      data: {
        'name': name,
        'description': description?.trim().isNotEmpty == true
            ? description!.trim()
            : null,
      },
    );
    return GenreModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<GenreModel> updateType({
    required int typeId,
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.patch(
      '/admin/genres/$typeId',
      data: {
        'name': name,
        'description': description?.trim().isNotEmpty == true
            ? description!.trim()
            : null,
      },
    );
    return GenreModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteType(int typeId) async {
    await _apiClient.delete('/admin/genres/$typeId');
  }

  Future<PaginatedResult<CategoryModel>> fetchCategories({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get(
      '/admin/categories',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final items = (response.data['data'] as List<dynamic>)
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return PaginatedResult(
      items: items,
      pagination: _paginationFromResponse(response),
    );
  }

  Future<CategoryModel> createCategory({
    required int typeId,
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.post(
      '/admin/categories',
      data: {
        'genre_id': typeId,
        'name': name,
        'description': description?.trim().isNotEmpty == true
            ? description!.trim()
            : null,
      },
    );
    return CategoryModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<CategoryModel> updateCategory({
    required int categoryId,
    required int typeId,
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.patch(
      '/admin/categories/$categoryId',
      data: {
        'genre_id': typeId,
        'name': name,
        'description': description?.trim().isNotEmpty == true
            ? description!.trim()
            : null,
      },
    );
    return CategoryModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> deleteCategory(int categoryId) async {
    await _apiClient.delete('/admin/categories/$categoryId');
  }

  Future<PaginatedResult<BookModel>> fetchBooks({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get(
      '/admin/books',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final items = (response.data['data'] as List<dynamic>)
        .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return PaginatedResult(
      items: items,
      pagination: _paginationFromResponse(response),
    );
  }

  Future<BookModel> createBook(AdminBookPayload payload) async {
    final response = await _apiClient.post(
      '/admin/books',
      data: await _bookFormData(payload),
    );
    return BookModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<BookModel> updateBook(int bookId, AdminBookPayload payload) async {
    final response = await _apiClient.post(
      '/admin/books/$bookId',
      data: await _bookFormData(payload, asPatchRequest: true),
    );
    return BookModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteBook(int bookId) async {
    await _apiClient.delete('/admin/books/$bookId');
  }

  Future<PaginatedResult<OrderModel>> fetchOrders({
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    final response = await _apiClient.get(
      '/admin/orders',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final items = (response.data['data'] as List<dynamic>)
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return PaginatedResult(
      items: items,
      pagination: _paginationFromResponse(response),
    );
  }

  Future<OrderModel> fetchOrder(int orderId) async {
    final response = await _apiClient.get('/admin/orders/$orderId');
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<OrderModel> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final response = await _apiClient.patch(
      '/admin/orders/$orderId/status',
      data: {'status': status},
    );
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  PaginationMeta _paginationFromResponse(Response<dynamic> response) {
    final pagination =
        (response.data['meta'] as Map<String, dynamic>?)?['pagination']
            as Map<String, dynamic>?;

    if (pagination == null) {
      return const PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: 20,
        total: 0,
      );
    }

    return PaginationMeta.fromJson(pagination);
  }

  Future<FormData> _bookFormData(
    AdminBookPayload payload, {
    bool asPatchRequest = false,
  }) async {
    final data = <String, dynamic>{
      'category_id': payload.categoryId,
      'title': payload.title,
      'description': payload.description,
      'author': payload.author,
      'stock_quantity': payload.stockQuantity,
      'price_cents': payload.priceCents,
      'status': payload.status,
      if (payload.publisher != null && payload.publisher!.isNotEmpty)
        'publisher': payload.publisher,
      if (payload.publishedYear != null)
        'published_year': payload.publishedYear,
      if (payload.pageCount != null) 'page_count': payload.pageCount,
      if (payload.removeImage) 'remove_image': 1,
      if (asPatchRequest) '_method': 'PATCH',
    };

    final imageFile = await _resolveImage(payload.image);
    if (imageFile != null) {
      data['image'] = imageFile;
    }

    return FormData.fromMap(data);
  }

  Future<MultipartFile?> _resolveImage(AdminImageSelection? image) async {
    if (image == null) {
      return null;
    }

    if (image.hasBytes) {
      return MultipartFile.fromBytes(image.bytes!, filename: image.name);
    }

    if (image.hasFilePath) {
      return await MultipartFile.fromFile(image.path!, filename: image.name);
    }

    return null;
  }
}
